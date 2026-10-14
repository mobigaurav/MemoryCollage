"""A private family book. Not the public World feed.

One signed-in person starts it and gets a short code. People with the code
can add photos. Strangers cannot read the book.
"""

from __future__ import annotations

import os
import secrets
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone

_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
MAX_MEMBERS = 8
MAX_PHOTOS = 80


def _now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def _code() -> str:
    return "".join(secrets.choice(_ALPHABET) for _ in range(6))


@dataclass
class HouseholdPhoto:
    id: str
    key: str
    author_sub: str
    author: str
    created_at: str


@dataclass
class Household:
    code: str
    title: str
    owner: str
    owner_name: str
    created_at: str
    members: dict[str, str] = field(default_factory=dict)
    photos: list[HouseholdPhoto] = field(default_factory=list)

    def view(self, viewer: str) -> dict:
        return {
            "code": self.code,
            "title": self.title,
            "owner": self.owner == viewer,
            "members": [
                {"name": name, "you": sub == viewer}
                for sub, name in self.members.items()
            ],
            "photos": [
                {
                    "id": photo.id,
                    "key": photo.key,
                    "author": photo.author,
                    "yours": photo.author_sub == viewer,
                    "createdAt": photo.created_at,
                }
                for photo in self.photos
            ],
        }


class MemoryHouseholds:
    def __init__(self) -> None:
        self.books: dict[str, Household] = {}

    def reset(self) -> None:
        self.books.clear()

    def create(self, *, sub: str, name: str, title: str) -> Household:
        code = _code()
        while code in self.books:
            code = _code()
        book = Household(
            code=code,
            title=title,
            owner=sub,
            owner_name=name,
            created_at=_now(),
            members={sub: name},
        )
        self.books[code] = book
        return book

    def join(self, *, sub: str, name: str, code: str) -> Household | None:
        book = self.books.get(code.strip().upper())
        if book is None:
            return None
        if sub not in book.members:
            if len(book.members) >= MAX_MEMBERS:
                raise ValueError("This book already has eight people.")
            book.members[sub] = name
        return book

    def list_for(self, sub: str) -> list[Household]:
        return [book for book in self.books.values() if sub in book.members]

    def get(self, code: str, sub: str) -> Household | None:
        book = self.books.get(code.strip().upper())
        if book is None or sub not in book.members:
            return None
        return book

    def reserve(self, code: str, sub: str, count: int) -> list[str]:
        book = self.get(code, sub)
        if book is None:
            return []
        if len(book.photos) + count > MAX_PHOTOS:
            raise ValueError("This book already holds 80 photos.")
        photo_ids = [str(uuid.uuid4()) for _ in range(count)]
        return [f"households/{book.code}/{photo_id}.jpg" for photo_id in photo_ids]

    def commit(self, code: str, sub: str, name: str, keys: list[str]) -> Household | None:
        book = self.get(code, sub)
        if book is None:
            return None
        prefix = f"households/{book.code}/"
        known = {photo.key for photo in book.photos}
        fresh = []
        for key in keys:
            if not key.startswith(prefix) or key in known:
                raise ValueError("Those files do not belong to this book.")
            fresh.append(key)
        if len(book.photos) + len(fresh) > MAX_PHOTOS:
            raise ValueError("This book already holds 80 photos.")
        for key in fresh:
            book.photos.append(
                HouseholdPhoto(
                    id=key.rsplit("/", 1)[-1].split(".", 1)[0],
                    key=key,
                    author_sub=sub,
                    author=name,
                    created_at=_now(),
                )
            )
        return book


class DynamoHouseholds:
    def __init__(self, table: str) -> None:
        self._table = table

    def _dynamo(self):
        import boto3

        return boto3.resource("dynamodb").Table(self._table)

    def create(self, *, sub: str, name: str, title: str) -> Household:
        code = _code()
        created = _now()
        table = self._dynamo()
        for _ in range(5):
            existing = table.get_item(Key={"pk": f"HOUSE#{code}", "sk": "META"})
            if "Item" not in existing:
                break
            code = _code()
        table.put_item(
            Item={
                "pk": f"HOUSE#{code}",
                "sk": "META",
                "title": title,
                "owner": sub,
                "ownerName": name,
                "createdAt": created,
            }
        )
        self._member(code, sub, name, title)
        return Household(
            code=code,
            title=title,
            owner=sub,
            owner_name=name,
            created_at=created,
            members={sub: name},
        )

    def _member(self, code: str, sub: str, name: str, title: str) -> None:
        table = self._dynamo()
        table.put_item(
            Item={"pk": f"HOUSE#{code}", "sk": f"MEMBER#{sub}", "name": name}
        )
        table.put_item(
            Item={
                "pk": f"USER#{sub}",
                "sk": f"HOUSE#{code}",
                "title": title,
                "code": code,
            }
        )

    def _load(self, code: str) -> Household | None:
        from boto3.dynamodb.conditions import Key

        found = self._dynamo().query(
            KeyConditionExpression=Key("pk").eq(f"HOUSE#{code}"),
        )
        items = found.get("Items") or []
        meta = next((item for item in items if item.get("sk") == "META"), None)
        if meta is None:
            return None
        members = {
            str(item["sk"]).removeprefix("MEMBER#"): str(item.get("name") or "Member")
            for item in items
            if str(item.get("sk", "")).startswith("MEMBER#")
        }
        photos = [
            HouseholdPhoto(
                id=str(item.get("id") or ""),
                key=str(item.get("key") or ""),
                author_sub=str(item.get("authorSub") or ""),
                author=str(item.get("author") or "Member"),
                created_at=str(item.get("createdAt") or ""),
            )
            for item in items
            if str(item.get("sk", "")).startswith("PHOTO#")
        ]
        photos.sort(key=lambda photo: photo.created_at)
        return Household(
            code=code,
            title=str(meta.get("title") or "Family book"),
            owner=str(meta.get("owner") or ""),
            owner_name=str(meta.get("ownerName") or "Member"),
            created_at=str(meta.get("createdAt") or ""),
            members=members,
            photos=photos,
        )

    def join(self, *, sub: str, name: str, code: str) -> Household | None:
        book = self._load(code.strip().upper())
        if book is None:
            return None
        if sub not in book.members:
            if len(book.members) >= MAX_MEMBERS:
                raise ValueError("This book already has eight people.")
            self._member(book.code, sub, name, book.title)
            book.members[sub] = name
        return book

    def list_for(self, sub: str) -> list[Household]:
        from boto3.dynamodb.conditions import Key

        found = self._dynamo().query(
            KeyConditionExpression=Key("pk").eq(f"USER#{sub}")
            & Key("sk").begins_with("HOUSE#"),
        )
        books = []
        for item in found.get("Items") or []:
            loaded = self._load(str(item.get("code") or ""))
            if loaded is not None:
                books.append(loaded)
        return books

    def get(self, code: str, sub: str) -> Household | None:
        book = self._load(code.strip().upper())
        if book is None or sub not in book.members:
            return None
        return book

    def reserve(self, code: str, sub: str, count: int) -> list[str]:
        book = self.get(code, sub)
        if book is None:
            return []
        if len(book.photos) + count > MAX_PHOTOS:
            raise ValueError("This book already holds 80 photos.")
        return [
            f"households/{book.code}/{uuid.uuid4()}.jpg" for _ in range(count)
        ]

    def commit(self, code: str, sub: str, name: str, keys: list[str]) -> Household | None:
        book = self.get(code, sub)
        if book is None:
            return None
        prefix = f"households/{book.code}/"
        known = {photo.key for photo in book.photos}
        fresh = []
        for key in keys:
            if not str(key).startswith(prefix) or key in known:
                raise ValueError("Those files do not belong to this book.")
            fresh.append(key)
        if len(book.photos) + len(fresh) > MAX_PHOTOS:
            raise ValueError("This book already holds 80 photos.")
        table = self._dynamo()
        for key in fresh:
            created = _now()
            photo_id = key.rsplit("/", 1)[-1].split(".", 1)[0]
            table.put_item(
                Item={
                    "pk": f"HOUSE#{book.code}",
                    "sk": f"PHOTO#{created}#{photo_id}",
                    "id": photo_id,
                    "key": key,
                    "authorSub": sub,
                    "author": name,
                    "createdAt": created,
                }
            )
        return self.get(code, sub)


_memory = MemoryHouseholds()


def get_households():
    table = os.environ.get("HOUSEHOLD_TABLE", "").strip()
    if table:
        return DynamoHouseholds(table)
    if os.environ.get("HOUSEHOLD_MEMORY") == "1":
        return _memory
    return None


def reset_households() -> None:
    _memory.reset()
