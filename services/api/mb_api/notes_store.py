"""A short voice note behind a printed QR mark.

The person who records it is signed in. Anyone who has the page can hear it,
because a printed QR cannot ask them to sign in. The id is unguessable, and
the page names nobody.
"""

from __future__ import annotations

import os
import uuid
from dataclasses import dataclass

MAX_BYTES = 1_500_000
MIN_BYTES = 800


@dataclass
class VoiceNote:
    id: str
    owner: str
    audio: bytes


class MemoryNotes:
    def __init__(self) -> None:
        self.notes: dict[str, VoiceNote] = {}

    def reset(self) -> None:
        self.notes.clear()

    def create(self, *, sub: str, audio: bytes) -> VoiceNote:
        note = VoiceNote(id=str(uuid.uuid4()), owner=sub, audio=audio)
        self.notes[note.id] = note
        return note

    def get(self, note_id: str) -> VoiceNote | None:
        return self.notes.get(note_id)


class S3Notes:
    """The audio lives in the media bucket. The id is the only way to find it."""

    def __init__(self, bucket: str) -> None:
        self._bucket = bucket

    def _s3(self):
        import boto3

        return boto3.client("s3")

    def create(self, *, sub: str, audio: bytes) -> VoiceNote:
        note_id = str(uuid.uuid4())
        self._s3().put_object(
            Bucket=self._bucket,
            Key=f"notes/{note_id}.m4a",
            Body=audio,
            ContentType="audio/mp4",
        )
        return VoiceNote(id=note_id, owner=sub, audio=b"")

    def get(self, note_id: str) -> VoiceNote | None:
        try:
            found = self._s3().get_object(Bucket=self._bucket, Key=f"notes/{note_id}.m4a")
        except Exception:
            return None
        return VoiceNote(id=note_id, owner="", audio=found["Body"].read())


_memory = MemoryNotes()


def get_notes():
    if os.environ.get("HOUSEHOLD_MEMORY") == "1":
        return _memory
    bucket = os.environ.get("MEDIA_BUCKET", "").strip()
    if bucket:
        return S3Notes(bucket)
    return None


def reset_notes() -> None:
    _memory.reset()
