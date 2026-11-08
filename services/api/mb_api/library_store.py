"""The signed-in shelf. Books and reels live here so a new install can bring them back.

Photos and videos sit in the media bucket under library/{user}/. The index is
the list of books and reels. A key that does not start with that prefix is refused.
"""

from __future__ import annotations

import json
import os
import uuid
from dataclasses import dataclass, field


def owned_prefix(sub: str) -> str:
    return f"library/{sub}/"


def accepts_key(sub: str, key: str) -> bool:
    prefix = owned_prefix(sub)
    return key.startswith(prefix) and ".." not in key


@dataclass
class Shelf:
    books: list[dict] = field(default_factory=list)
    reels: list[dict] = field(default_factory=list)
    blobs: dict[str, bytes] = field(default_factory=dict)


class MemoryLibrary:
    def __init__(self) -> None:
        self.shelves: dict[str, Shelf] = {}

    def reset(self) -> None:
        self.shelves.clear()

    def _shelf(self, sub: str) -> Shelf:
        return self.shelves.setdefault(sub, Shelf())

    def read(self, sub: str) -> Shelf:
        shelf = self._shelf(sub)
        return Shelf(books=list(shelf.books), reels=list(shelf.reels), blobs=dict(shelf.blobs))

    def write(self, sub: str, books: list[dict], reels: list[dict]) -> None:
        _reject_foreign(sub, books, reels)
        shelf = self._shelf(sub)
        shelf.books = books
        shelf.reels = reels

    def reserve(self, sub: str, count: int, content_type: str) -> list[dict]:
        uploads = []
        for _ in range(count):
            ext = ".mp4" if content_type.startswith("video/") else ".jpg"
            folder = "reels" if content_type.startswith("video/") else "photos"
            key = f"{owned_prefix(sub)}{folder}/{uuid.uuid4()}{ext}"
            uploads.append({"key": key, "url": f"https://memory.invalid/{key}", "contentType": content_type})
        return uploads

    def wipe(self, sub: str) -> None:
        self.shelves.pop(sub, None)


class S3Library:
    def __init__(self, bucket: str) -> None:
        self._bucket = bucket

    def _s3(self):
        import boto3

        return boto3.client("s3")

    def _index_key(self, sub: str) -> str:
        return f"{owned_prefix(sub)}index.json"

    def read(self, sub: str) -> Shelf:
        try:
            found = self._s3().get_object(Bucket=self._bucket, Key=self._index_key(sub))
        except Exception:
            return Shelf()
        raw = json.loads(found["Body"].read().decode("utf-8"))
        return Shelf(
            books=list(raw.get("books") or []),
            reels=list(raw.get("reels") or []),
        )

    def write(self, sub: str, books: list[dict], reels: list[dict]) -> None:
        _reject_foreign(sub, books, reels)
        body = json.dumps({"books": books, "reels": reels}).encode("utf-8")
        self._s3().put_object(
            Bucket=self._bucket,
            Key=self._index_key(sub),
            Body=body,
            ContentType="application/json",
        )

    def reserve(self, sub: str, count: int, content_type: str) -> list[dict]:
        import boto3

        client = boto3.client("s3")
        uploads = []
        for _ in range(count):
            ext = ".mp4" if content_type.startswith("video/") else ".jpg"
            folder = "reels" if content_type.startswith("video/") else "photos"
            key = f"{owned_prefix(sub)}{folder}/{uuid.uuid4()}{ext}"
            url = client.generate_presigned_url(
                "put_object",
                Params={"Bucket": self._bucket, "Key": key, "ContentType": content_type},
                ExpiresIn=900,
            )
            uploads.append({"key": key, "url": url, "contentType": content_type})
        return uploads

    def sign_get(self, key: str) -> str:
        import boto3

        return boto3.client("s3").generate_presigned_url(
            "get_object",
            Params={"Bucket": self._bucket, "Key": key},
            ExpiresIn=3600,
        )

    def wipe(self, sub: str) -> None:
        client = self._s3()
        prefix = owned_prefix(sub)
        token = None
        while True:
            kwargs = {"Bucket": self._bucket, "Prefix": prefix}
            if token:
                kwargs["ContinuationToken"] = token
            found = client.list_objects_v2(**kwargs)
            keys = [{"Key": item["Key"]} for item in found.get("Contents") or []]
            if keys:
                client.delete_objects(Bucket=self._bucket, Delete={"Objects": keys})
            if not found.get("IsTruncated"):
                return
            token = found.get("NextContinuationToken")


def _reject_foreign(sub: str, books: list[dict], reels: list[dict]) -> None:
    for book in books:
        cover = book.get("coverKey")
        if cover and not accepts_key(sub, str(cover)):
            raise ValueError("A book photo is outside this account.")
        for page in book.get("pages") or []:
            for slot in page.get("slots") or []:
                key = slot.get("photoKey")
                if key and not accepts_key(sub, str(key)):
                    raise ValueError("A book photo is outside this account.")
    for reel in reels:
        key = reel.get("videoKey")
        if key and not accepts_key(sub, str(key)):
            raise ValueError("A reel is outside this account.")


_memory = MemoryLibrary()


def get_library():
    if os.environ.get("HOUSEHOLD_MEMORY") == "1":
        return _memory
    bucket = os.environ.get("MEDIA_BUCKET", "").strip()
    if bucket:
        return S3Library(bucket)
    return None


def reset_library() -> None:
    _memory.reset()
