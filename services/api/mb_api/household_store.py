"""A private family book or collage. Not the public World feed.

One signed-in person starts it and gets a short code. People with the code
can add photos. Strangers cannot read it. A collage has frames; each photo
lands in an empty one.
"""

from __future__ import annotations

import os
import secrets
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone
from decimal import Decimal

_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
MAX_MEMBERS = 8
MAX_PHOTOS = 80


def _now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def _code() -> str:
    return "".join(secrets.choice(_ALPHABET) for _ in range(6))


def _plain(value):
    """Dynamo returns numbers as Decimal. JSON wants int."""
    if isinstance(value, Decimal):
        return int(value) if value % 1 == 0 else float(value)
    if isinstance(value, dict):
        return {str(key): _plain(item) for key, item in value.items()}
    if isinstance(value, list):
        return [_plain(item) for item in value]
    return value


@dataclass
class HouseholdPhoto:
    id: str
    key: str
    author_sub: str
    author: str
    created_at: str
    slot: int | None = None


@dataclass
class Household:
    code: str
    title: str
    owner: str
    owner_name: str
    created_at: str
    kind: str = "book"
    layout: dict | None = None
    members: dict[str, str] = field(default_factory=dict)
    photos: list[HouseholdPhoto] = field(default_factory=list)

    def view(self, viewer: str) -> dict:
        return {
            "code": self.code,
            "title": self.title,
            "kind": self.kind,
            "layout": self.layout,
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
                    **({} if photo.slot is None else {"slot": photo.slot}),
                }
                for photo in self.photos
            ],
        }

    def open_slots(self) -> list[int] | None:
        if self.kind != "collage" or not self.layout:
            return None
        frames = int(self.layout.get("frames") or 0)
        used = {photo.slot for photo in self.photos if photo.slot is not None}
        return [slot for slot in range(frames) if slot not in used]

    def place_slot(self, wanted: int | None) -> int:
        open_slots = self.open_slots()
        if open_slots is None:
            raise ValueError("This is a family book, not a collage.")
        if not open_slots:
            raise ValueError("Every frame of this collage is full.")
        if wanted is not None and int(wanted) in open_slots:
            return int(wanted)
        return open_slots[0]


class MemoryHouseholds:
    def __init__(self) -> None:
        self.books: dict[str, Household] = {}

    def reset(self) -> None:
        self.books.clear()

    def create(
        self,
        *,
        sub: str,
        name: str,
        title: str,
        kind: str = "book",
        layout: dict | None = None,
    ) -> Household:
        code = _code()
        while code in self.books:
            code = _code()
        book = Household(
            code=code,
            title=title,
            owner=sub,
            owner_name=name,
            created_at=_now(),
            kind=kind,
            layout=layout if kind == "collage" else None,
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

    def delete_owned(self, sub: str) -> list[str]:
        keys: list[str] = []
        for code, book in list(self.books.items()):
            if book.owner != sub:
                continue
            keys.extend(photo.key for photo in book.photos if photo.key)
            self.books.pop(code, None)
        return keys

    def get(self, code: str, sub: str) -> Household | None:
        book = self.books.get(code.strip().upper())
        if book is None or sub not in book.members:
            return None
        return book

    def set_layout(self, code: str, sub: str, layout: dict) -> Household | None:
        book = self.get(code, sub)
        if book is None:
            return None
        if book.kind != "collage":
            raise ValueError("This is a family book, not a collage.")
        frames = int(layout.get("frames") or 0)
        if any(photo.slot is not None and photo.slot >= frames for photo in book.photos):
            raise ValueError("A photo is sitting in a frame this layout does not have.")
        book.layout = layout
        return book

    def reserve(self, code: str, sub: str, count: int) -> list[str]:
        book = self.get(code, sub)
        if book is None:
            return []
        room_for(book, count)
        photo_ids = [str(uuid.uuid4()) for _ in range(count)]
        return [f"households/{book.code}/{photo_id}.jpg" for photo_id in photo_ids]

    def commit(
        self,
        code: str,
        sub: str,
        name: str,
        keys: list[str],
        slots: list[int] | None = None,
    ) -> Household | None:
        book = self.get(code, sub)
        if book is None:
            return None
        fresh = fresh_keys(book, keys)
        room_for(book, len(fresh))
        for index, key in enumerate(fresh):
            wanted = slots[index] if slots else None
            book.photos.append(
                HouseholdPhoto(
                    id=key.rsplit("/", 1)[-1].split(".", 1)[0],
                    key=key,
                    author_sub=sub,
                    author=name,
                    created_at=_now(),
                    slot=book.place_slot(wanted) if book.kind == "collage" else None,
                )
            )
        return book

def room_for(book: Household, count: int) -> None:
    if len(book.photos) + count > MAX_PHOTOS:
        raise ValueError("This book already holds 80 photos.")
    open_slots = book.open_slots()
    if open_slots is not None and count > len(open_slots):
        left = len(open_slots)
        raise ValueError(
            "Every frame of this collage is full."
            if left == 0
            else f"This collage has {left} empty frames."
        )


def fresh_keys(book: Household, keys: list[str]) -> list[str]:
    prefix = f"households/{book.code}/"
    known = {photo.key for photo in book.photos}
    fresh = []
    for key in keys:
        if not str(key).startswith(prefix) or key in known:
            raise ValueError("Those files do not belong to this book.")
        fresh.append(key)
    return fresh


class DynamoHouseholds:
    def __init__(self, table: str) -> None:
        self._table = table

    def _dynamo(self):
        import boto3

        return boto3.resource("dynamodb").Table(self._table)

    def create(
        self,
        *,
        sub: str,
        name: str,
        title: str,
        kind: str = "book",
        layout: dict | None = None,
    ) -> Household:
        code = _code()
        created = _now()
        table = self._dynamo()
        for _ in range(5):
            existing = table.get_item(Key={"pk": f"HOUSE#{code}", "sk": "META"})
            if "Item" not in existing:
                break
            code = _code()
        item = {
            "pk": f"HOUSE#{code}",
            "sk": "META",
            "title": title,
            "kind": kind,
            "owner": sub,
            "ownerName": name,
            "createdAt": created,
        }
        if kind == "collage" and layout:
            item["layout"] = layout
        table.put_item(Item=item)
        self._member(code, sub, name, title)
        return Household(
            code=code,
            title=title,
            owner=sub,
            owner_name=name,
            created_at=created,
            kind=kind,
            layout=layout if kind == "collage" else None,
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
                slot=_slot(item.get("slot")),
            )
            for item in items
            if str(item.get("sk", "")).startswith("PHOTO#")
        ]
        photos.sort(key=lambda photo: photo.created_at)
        layout = meta.get("layout")
        return Household(
            code=code,
            title=str(meta.get("title") or "Family book"),
            owner=str(meta.get("owner") or ""),
            owner_name=str(meta.get("ownerName") or "Member"),
            created_at=str(meta.get("createdAt") or ""),
            kind=str(meta.get("kind") or "book"),
            layout=_plain(layout) if isinstance(layout, dict) else None,
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

    def delete_owned(self, sub: str) -> list[str]:
        from boto3.dynamodb.conditions import Key

        keys: list[str] = []
        table = self._dynamo()
        for book in self.list_for(sub):
            if book.owner != sub:
                continue
            keys.extend(photo.key for photo in book.photos if photo.key)
            found = table.query(KeyConditionExpression=Key("pk").eq(f"HOUSE#{book.code}"))
            for item in found.get("Items") or []:
                table.delete_item(Key={"pk": item["pk"], "sk": item["sk"]})
            for member in book.members:
                table.delete_item(Key={"pk": f"USER#{member}", "sk": f"HOUSE#{book.code}"})
        return keys

    def get(self, code: str, sub: str) -> Household | None:
        book = self._load(code.strip().upper())
        if book is None or sub not in book.members:
            return None
        return book

    def set_layout(self, code: str, sub: str, layout: dict) -> Household | None:
        book = self.get(code, sub)
        if book is None:
            return None
        if book.kind != "collage":
            raise ValueError("This is a family book, not a collage.")
        frames = int(layout.get("frames") or 0)
        if any(photo.slot is not None and photo.slot >= frames for photo in book.photos):
            raise ValueError("A photo is sitting in a frame this layout does not have.")
        self._dynamo().update_item(
            Key={"pk": f"HOUSE#{book.code}", "sk": "META"},
            UpdateExpression="SET layout = :layout",
            ExpressionAttributeValues={":layout": layout},
        )
        return self.get(code, sub)

    def reserve(self, code: str, sub: str, count: int) -> list[str]:
        book = self.get(code, sub)
        if book is None:
            return []
        room_for(book, count)
        return [
            f"households/{book.code}/{uuid.uuid4()}.jpg" for _ in range(count)
        ]

    def commit(
        self,
        code: str,
        sub: str,
        name: str,
        keys: list[str],
        slots: list[int] | None = None,
    ) -> Household | None:
        book = self.get(code, sub)
        if book is None:
            return None
        fresh = fresh_keys(book, keys)
        room_for(book, len(fresh))
        table = self._dynamo()
        for index, key in enumerate(fresh):
            created = _now()
            photo_id = key.rsplit("/", 1)[-1].split(".", 1)[0]
            wanted = slots[index] if slots else None
            item = {
                "pk": f"HOUSE#{book.code}",
                "sk": f"PHOTO#{created}#{photo_id}",
                "id": photo_id,
                "key": key,
                "authorSub": sub,
                "author": name,
                "createdAt": created,
            }
            if book.kind == "collage":
                slot = book.place_slot(wanted)
                item["slot"] = slot
                book.photos.append(
                    HouseholdPhoto(
                        id=photo_id,
                        key=key,
                        author_sub=sub,
                        author=name,
                        created_at=created,
                        slot=slot,
                    )
                )
            table.put_item(Item=item)
        return self.get(code, sub)


def _slot(value) -> int | None:
    if value is None:
        return None
    return int(_plain(value))


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
