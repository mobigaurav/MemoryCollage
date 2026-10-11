"""World posts. DynamoDB when COMMUNITY_TABLE is set, memory only in tests.

A post is the author's until they delete it. Love is a public count.
Ignore is private to the viewer and does not remove the post for anyone else.
"""

from __future__ import annotations

import os
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone


def author_label(name: str | None, email: str | None) -> str:
    raw = (name or "").strip()
    if raw and "@" not in raw:
        return raw[:40]
    if email and "@" in email:
        return email.split("@", 1)[0][:40]
    return "Member"


def _now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")


@dataclass
class CommunityPost:
    id: str
    sub: str
    author: str
    title: str
    kind: str
    keys: list[str]
    created_at: str
    published: bool = False
    loved_by: set[str] = field(default_factory=set)

    def public(self, viewer: str) -> dict:
        return {
            "id": self.id,
            "title": self.title,
            "kind": self.kind,
            "author": self.author,
            "mine": bool(viewer) and viewer == self.sub,
            "loves": len(self.loved_by),
            "loved": viewer in self.loved_by,
            "createdAt": self.created_at,
            "keys": list(self.keys),
        }


class MemoryCommunity:
    def __init__(self) -> None:
        self.posts: dict[str, CommunityPost] = {}
        self.ignored: set[tuple[str, str]] = set()

    def reset(self) -> None:
        self.posts.clear()
        self.ignored.clear()

    def create(self, *, sub: str, author: str, title: str, kind: str, count: int) -> CommunityPost:
        post_id = str(uuid.uuid4())
        ext = "mp4" if kind == "reel" else "jpg"
        keys = [f"community/{post_id}/{index}.{ext}" for index in range(count)]
        post = CommunityPost(
            id=post_id,
            sub=sub,
            author=author,
            title=title,
            kind=kind,
            keys=keys,
            created_at=_now(),
            published=False,
        )
        self.posts[post_id] = post
        return post

    def publish(self, post_id: str, sub: str, keys: list[str]) -> CommunityPost | None:
        post = self.posts.get(post_id)
        if post is None or post.sub != sub:
            return None
        if keys != post.keys:
            raise ValueError("Those files do not belong to this post.")
        post.published = True
        return post

    def list_posts(self, viewer: str) -> list[CommunityPost]:
        hidden = {post_id for owner, post_id in self.ignored if owner == viewer}
        rows = [
            post
            for post in self.posts.values()
            if post.published and post.id not in hidden
        ]
        rows.sort(key=lambda post: post.created_at, reverse=True)
        return rows[:40]

    def love(self, post_id: str, sub: str) -> CommunityPost | None:
        post = self.posts.get(post_id)
        if post is None or not post.published:
            return None
        if sub in post.loved_by:
            post.loved_by.remove(sub)
        else:
            post.loved_by.add(sub)
        return post

    def ignore(self, post_id: str, sub: str) -> bool:
        post = self.posts.get(post_id)
        if post is None or not post.published:
            return False
        self.ignored.add((sub, post_id))
        return True

    def delete(self, post_id: str, sub: str) -> CommunityPost | None:
        post = self.posts.get(post_id)
        if post is None or post.sub != sub:
            return None
        del self.posts[post_id]
        self.ignored = {row for row in self.ignored if row[1] != post_id}
        return post


class DynamoCommunity:
    def __init__(self, table_name: str, bucket: str) -> None:
        self._table_name = table_name
        self._bucket = bucket

    def _dynamo(self):
        import boto3

        return boto3.resource("dynamodb").Table(self._table_name)

    def create(self, *, sub: str, author: str, title: str, kind: str, count: int) -> CommunityPost:
        post_id = str(uuid.uuid4())
        ext = "mp4" if kind == "reel" else "jpg"
        keys = [f"community/{post_id}/{index}.{ext}" for index in range(count)]
        created = _now()
        self._dynamo().put_item(
            Item={
                "pk": "POST",
                "sk": f"{created}#{post_id}",
                "id": post_id,
                "sub": sub,
                "author": author,
                "title": title,
                "kind": kind,
                "keys": keys,
                "createdAt": created,
                "published": False,
            }
        )
        return CommunityPost(
            id=post_id,
            sub=sub,
            author=author,
            title=title,
            kind=kind,
            keys=keys,
            created_at=created,
        )

    def _find(self, post_id: str) -> dict | None:
        from boto3.dynamodb.conditions import Attr, Key

        found = self._dynamo().query(
            KeyConditionExpression=Key("pk").eq("POST"),
            FilterExpression=Attr("id").eq(post_id),
        )
        items = found.get("Items") or []
        return items[0] if items else None

    def publish(self, post_id: str, sub: str, keys: list[str]) -> CommunityPost | None:
        item = self._find(post_id)
        if item is None or item.get("sub") != sub:
            return None
        if list(item.get("keys") or []) != keys:
            raise ValueError("Those files do not belong to this post.")
        self._dynamo().update_item(
            Key={"pk": item["pk"], "sk": item["sk"]},
            UpdateExpression="SET published = :yes",
            ExpressionAttributeValues={":yes": True},
        )
        item["published"] = True
        return _from_item(item)

    def list_posts(self, viewer: str) -> list[CommunityPost]:
        from boto3.dynamodb.conditions import Key

        found = self._dynamo().query(
            KeyConditionExpression=Key("pk").eq("POST"),
            ScanIndexForward=False,
            Limit=60,
        )
        hidden: set[str] = set()
        if viewer:
            ignored = self._dynamo().query(
                KeyConditionExpression=Key("pk").eq(f"USER#{viewer}")
                & Key("sk").begins_with("IGNORE#"),
            )
            hidden = {
                str(row.get("sk", "")).removeprefix("IGNORE#")
                for row in ignored.get("Items") or []
            }
        rows = []
        for item in found.get("Items") or []:
            if not item.get("published"):
                continue
            if str(item.get("id")) in hidden:
                continue
            rows.append(_from_item(item))
        return rows[:40]

    def love(self, post_id: str, sub: str) -> CommunityPost | None:
        item = self._find(post_id)
        if item is None or not item.get("published"):
            return None
        loved = set(item.get("lovedBy") or [])
        if sub in loved:
            self._dynamo().update_item(
                Key={"pk": item["pk"], "sk": item["sk"]},
                UpdateExpression="DELETE lovedBy :sub",
                ExpressionAttributeValues={":sub": {sub}},
            )
            loved.remove(sub)
        else:
            self._dynamo().update_item(
                Key={"pk": item["pk"], "sk": item["sk"]},
                UpdateExpression="ADD lovedBy :sub",
                ExpressionAttributeValues={":sub": {sub}},
            )
            loved.add(sub)
        item["lovedBy"] = loved
        return _from_item(item)

    def ignore(self, post_id: str, sub: str) -> bool:
        item = self._find(post_id)
        if item is None or not item.get("published"):
            return False
        self._dynamo().put_item(
            Item={"pk": f"USER#{sub}", "sk": f"IGNORE#{post_id}"}
        )
        return True

    def delete(self, post_id: str, sub: str) -> CommunityPost | None:
        item = self._find(post_id)
        if item is None or item.get("sub") != sub:
            return None
        self._dynamo().delete_item(Key={"pk": item["pk"], "sk": item["sk"]})
        _delete_objects(self._bucket, list(item.get("keys") or []))
        return _from_item(item)


def _from_item(item: dict) -> CommunityPost:
    loved = item.get("lovedBy") or set()
    return CommunityPost(
        id=str(item.get("id") or ""),
        sub=str(item.get("sub") or ""),
        author=str(item.get("author") or "Member"),
        title=str(item.get("title") or ""),
        kind=str(item.get("kind") or "album"),
        keys=list(item.get("keys") or []),
        created_at=str(item.get("createdAt") or ""),
        published=bool(item.get("published")),
        loved_by=set(loved),
    )


def _delete_objects(bucket: str, keys: list[str]) -> None:
    if not bucket or not keys:
        return
    import boto3

    boto3.client("s3").delete_objects(
        Bucket=bucket,
        Delete={"Objects": [{"Key": key} for key in keys], "Quiet": True},
    )


_memory = MemoryCommunity()


def get_community():
    table = os.environ.get("COMMUNITY_TABLE", "").strip()
    if table:
        from mb_api.config import get_settings

        return DynamoCommunity(table, get_settings().media_bucket)
    if os.environ.get("COMMUNITY_MEMORY") == "1":
        return _memory
    return None


def reset_memory() -> None:
    _memory.reset()
