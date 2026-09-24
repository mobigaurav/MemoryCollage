"""In-memory ledger and jobs.

Lambda will forget this on a cold start. schema.sql is the Neon shape
for the next pass.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass, field

WELCOME_CREDITS = 3


@dataclass
class Job:
    id: str
    sub: str
    status: str
    style: str
    video_url: str | None = None
    error: str | None = None


@dataclass
class MemoryStore:
    users: dict[str, str | None] = field(default_factory=dict)
    events: list[tuple[str, int, str]] = field(default_factory=list)
    jobs: dict[str, Job] = field(default_factory=dict)

    def reset(self) -> None:
        self.users.clear()
        self.events.clear()
        self.jobs.clear()

    def ensure_user(self, sub: str, email: str | None) -> int:
        if sub not in self.users:
            self.users[sub] = email
            self.events.append((sub, WELCOME_CREDITS, "welcome"))
        elif email and not self.users[sub]:
            self.users[sub] = email
        return self.balance(sub)

    def balance(self, sub: str) -> int:
        return sum(delta for owner, delta, _reason in self.events if owner == sub)

    def spend(self, sub: str, amount: int, reason: str) -> bool:
        if self.balance(sub) < amount:
            return False
        self.events.append((sub, -amount, reason))
        return True

    def grant(self, sub: str, amount: int, reason: str) -> None:
        self.events.append((sub, amount, reason))

    def create_job(self, sub: str, style: str, status: str) -> Job:
        job = Job(id=str(uuid.uuid4()), sub=sub, status=status, style=style)
        self.jobs[job.id] = job
        return job


store = MemoryStore()
