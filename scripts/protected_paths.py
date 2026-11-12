"""Protected paths for unattended agent builds (issue #35).

The automated build (agent-build.yml, Phase 3) must never change the files that define the agents,
their rules or the pipelines. A patch touching them stops with `agent:needs-human`; the owner makes
those changes. The workflow token also cannot push `.github/workflows/` files at all.

  python scripts/protected_paths.py --files changed.txt     # exit 1 and list the files if any match
"""
from __future__ import annotations

import argparse
import fnmatch
import sys

PROTECTED = [
    ".github/workflows/*",
    ".github/agents/*",
    ".github/skills/*",
    ".github/copilot-instructions.md",
    ".github/CODEOWNERS",
    "agent-platform/*",
    "AGENTS.md",
    "infra/*",
    ".cursor/rules/*",
    "memory_book/android/keystore.properties",
    "memory_book/android/key.properties",
    "memory_book/android/app/google-services.json",
    "memory_book/ios/Runner/GoogleService-Info.plist",
    "memory_book/ios/*.p12",
    "memory_book/ios/*.mobileprovision",
    "memory_book/ios/ExportOptions.plist",
    "memory_book/ios/Runner.xcodeproj/project.pbxproj",
    "memory_book/ios/Runner/Runner.entitlements",
    "memory_book/android/app/build.gradle.kts",
    "memory_book/store/credentials/*",
    "memory_book/store/*.json",
    "*.jks",
    "*.keystore",
    "*.p8",
    "*.p12",
    "*.pem",
    "*.mobileprovision",
    ".env",
    ".env.*",
    "*/.env",
    "*/.env.*",
]


def protected(files: list[str]) -> list[str]:
    """Changed files that an unattended build may not touch (fnmatch '*' also matches '/')."""
    out = []
    for f in (x.strip().removeprefix("./") for x in files):
        if f and any(fnmatch.fnmatch(f, p) for p in PROTECTED):
            out.append(f)
    return sorted(set(out))


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--files", required=True, help="file with one changed path per line")
    a = ap.parse_args(argv)
    hits = protected(open(a.files, encoding="utf-8").read().splitlines())
    for f in hits:
        print(f"::error::Protected path changed by an unattended build: {f}")
    if not hits:
        print("No protected paths changed.")
    return 1 if hits else 0


if __name__ == "__main__":
    sys.exit(main())
