from scripts.protected_paths import main, protected


def test_protected_files_detected():
    files = [".github/workflows/ci.yml", ".github/agents/planner.agent.md",
             ".github/skills/x/SKILL.md", "agent-platform/registry.yaml", "AGENTS.md",
             "infra/lite/template.yaml", "memory_book/android/keystore.properties",
             "memory_book/android/app/build.gradle.kts", "memory_book/ios/Runner/Runner.entitlements",
             "memory_book/store/credentials/play.json", "AuthKey_ABC.p8", "services/api/.env",
             "./AGENTS.md", "./.github/workflows/x.yml"]
    assert protected(files) == sorted(set(f.removeprefix("./") for f in files))


def test_normal_files_pass():
    assert protected(["services/api/mb_api/main.py", "docs/SYSTEM_DESIGN.md", "memory_book/lib/app.dart",
                      "memory_book/pubspec.yaml", "memory_book/android/keystore.properties.template",
                      "apps/web/src/app/page.tsx", "tests/test_x.py", "README.md", ""]) == []


def test_cli(tmp_path):
    f = tmp_path / "files.txt"
    f.write_text("docs/a.md\n.github/workflows/ci.yml\n")
    assert main(["--files", str(f)]) == 1
    f.write_text("docs/a.md\n")
    assert main(["--files", str(f)]) == 0
