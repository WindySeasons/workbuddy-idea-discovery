# sync-upstream-check.py
"""
ARIS upstream sync checker for WorkBuddy automation.
This script:
1. Fetches latest upstream ARIS commit info via GitHub API
2. Compares with last known upstream commit
3. If changes detected, clones upstream, diffs skill files, and reports findings
4. If no conflicts, attempts auto-merge and commits+p pushes to origin
5. If conflicts found, reports them for manual review

State file: .sync-state.json stores last synced upstream commit hash
"""
import json
import os
import sys
import subprocess
import shutil
from datetime import datetime

REPO_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATE_FILE = os.path.join(REPO_DIR, ".sync-state.json")
LOCAL_SKILLS = os.path.join(REPO_DIR, "skills")
ARIS_CLONE = os.path.join(REPO_DIR, ".aris-upstream-check")
UPSTREAM_REPO = "wanshuiyin/Auto-claude-code-research-in-sleep"

# Map ARIS skill dir names to our local dir names
SKILL_MAP = {
    "research-lit": "research-lit",
    "idea-creator": "idea-creator",
    "idea-discovery": "idea-discovery",
    "novelty-check": "novelty-check",
    "research-review": "research-review",
    "research-refine": "research-refine",
    "experiment-plan": "experiment-plan",
}

def run(cmd, cwd=None):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=cwd)
    return result.stdout.strip(), result.returncode

def load_state():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    return {"last_upstream_commit": None, "last_check": None, "sync_count": 0}

def save_state(state):
    state["last_check"] = datetime.now().isoformat()
    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)

def get_upstream_commit():
    """Get latest commit hash from upstream via gh CLI"""
    out, rc = run('gh api repos/{}/commits/main --jq ".sha"'.format(UPSTREAM_REPO))
    if rc == 0 and out:
        return out[:12]
    return None

def clone_upstream():
    """Shallow clone upstream for diffing"""
    if os.path.exists(ARIS_CLONE):
        shutil.rmtree(ARIS_CLONE)
    _, rc = run(
        "git clone --depth 1 --branch main https://github.com/{}.git {}".format(
            UPSTREAM_REPO, ARIS_CLONE
        )
    )
    return rc == 0

def diff_skills():
    """Compare upstream skills with local, return changes and conflicts"""
    changes = []
    conflicts = []

    for aris_dir, local_dir in SKILL_MAP.items():
        aris_skill = os.path.join(ARIS_CLONE, aris_dir)
        local_skill = os.path.join(LOCAL_SKILLS, local_dir)

        if not os.path.isdir(aris_skill):
            continue
        if not os.path.isdir(local_skill):
            continue

        # Find SKILL.md in both
        aris_md = os.path.join(aris_skill, "SKILL.md")
        local_md = os.path.join(local_skill, "SKILL.md")

        if not os.path.exists(aris_md) or not os.path.exists(local_md):
            continue

        with open(aris_md, "r", encoding="utf-8") as f:
            aris_content = f.read()
        with open(local_md, "r", encoding="utf-8") as f:
            local_content = f.read()

        if aris_content == local_content:
            continue

        # Check for potential conflicts (WorkBuddy-specific content in upstream)
        wb_markers = ["WorkBuddy", "workbuddy", "Tencent", "mcp__", "allowed-tools"]
        has_wb = any(m in aris_content for m in wb_markers)

        changes.append(local_dir)
        if has_wb:
            conflicts.append(local_dir)

    return changes, conflicts

def auto_merge(changes, conflicts):
    """Merge non-conflicting changes"""
    merged = []
    for skill_dir in changes:
        if skill_dir in conflicts:
            continue

        # Find corresponding ARIS dir
        aris_dir = skill_dir
        for ad, ld in SKILL_MAP.items():
            if ld == skill_dir:
                aris_dir = ad
                break

        aris_md = os.path.join(ARIS_CLONE, aris_dir, "SKILL.md")
        local_md = os.path.join(LOCAL_SKILLS, skill_dir, "SKILL.md")

        if not os.path.exists(aris_md):
            continue

        # Backup
        shutil.copy2(local_md, local_md + ".bak")
        shutil.copy2(aris_md, local_md)
        merged.append(skill_dir)

    return merged

def commit_and_push(message):
    """Commit and push changes"""
    os.chdir(REPO_DIR)
    run("git add -A")
    run('git commit -m "{}"'.format(message))
    out, rc = run("git push origin main")
    return rc == 0

def cleanup():
    if os.path.exists(ARIS_CLONE):
        try:
            shutil.rmtree(ARIS_CLONE)
        except PermissionError:
            # Windows git packs can be locked; use rd command as fallback
            run('rd /s /q "{}"'.format(ARIS_CLONE.replace("/", "\\")))

def main():
    print("=" * 50)
    print("  ARIS Upstream Sync Check")
    print("  {}".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
    print("=" * 50)

    state = load_state()
    current_commit = get_upstream_commit()

    if not current_commit:
        print("[ERROR] Cannot fetch upstream commit. gh CLI may not be authenticated.")
        sys.exit(1)

    print("[INFO] Current upstream commit: {}".format(current_commit))
    print("[INFO] Last synced commit:      {}".format(state.get("last_upstream_commit") or "never"))

    if state.get("last_upstream_commit") == current_commit:
        print("[OK] Already up to date. No action needed.")
        save_state(state)
        cleanup()
        return

    print("[INFO] New upstream changes detected! Cloning for diff...")
    if not clone_upstream():
        print("[ERROR] Failed to clone upstream")
        sys.exit(1)

    changes, conflicts = diff_skills()
    print("[INFO] Skills with changes: {}".format(len(changes)))
    print("[INFO] Skills with conflicts: {}".format(len(conflicts)))

    if not changes:
        print("[OK] No skill file changes. Upstream changes are in other files.")
        state["last_upstream_commit"] = current_commit
        save_state(state)
        cleanup()
        return

    if conflicts:
        print("[WARN] Conflicts in: {}".format(", ".join(conflicts)))
        print("[WARN] Manual review required. Not auto-merging conflicting skills.")

    # Auto-merge non-conflicting
    if len(changes) > len(conflicts):
        merged = auto_merge(changes, conflicts)
        if merged:
            print("[OK] Auto-merged: {}".format(", ".join(merged)))
            ts = datetime.now().strftime("%Y-%m-%d %H:%M")
            msg = "sync: merge upstream ARIS changes ({})\n\nMerged: {}\nConflicts (manual review): {}".format(
                current_commit, ", ".join(merged), ", ".join(conflicts) if conflicts else "none"
            )
            if commit_and_push(msg):
                print("[OK] Pushed to GitHub")
            else:
                print("[ERROR] Push failed")
    elif conflicts:
        print("[WARN] All changed skills have conflicts. Manual review needed.")
        print("[INFO] Upstream clone available at: {}".format(ARIS_CLONE))
        # Don't cleanup so user can review
        return

    state["last_upstream_commit"] = current_commit
    state["sync_count"] = state.get("sync_count", 0) + 1
    save_state(state)
    cleanup()
    print("[DONE] Sync complete.")

if __name__ == "__main__":
    main()
