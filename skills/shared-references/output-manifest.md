# Output Manifest Protocol (WorkBuddy Port)

After writing any output file, append an entry to `MANIFEST.md` in the project root.

## Format

If `MANIFEST.md` does not exist, create it with this header:

```markdown
# Research Output Manifest

> Auto-maintained by WorkBuddy research skills. Tracks all generated artifacts.

| Timestamp | Skill | File | Stage | Description |
|-----------|-------|------|-------|-------------|
```

Then append one row per output file written:

```
| 2025-06-15 14:30 | idea-creator | idea-stage/IDEA_REPORT_20250615_143022.md | idea-discovery | 12 ideas generated from direction |
| 2025-06-15 14:30 | idea-creator | idea-stage/IDEA_REPORT.md | idea-discovery | latest copy |
```

## Stage Values

| Stage | Skills |
|-------|--------|
| `idea-discovery` | idea-creator, idea-discovery, novelty-check, research-review |
| `implementation` | research-refine, experiment-plan |
| `review` | research-review |

## Pre-flight Check

Before writing output, if the skill depends on a prerequisite file from a previous stage:
1. Check if the prerequisite file exists at its expected stage-scoped path
2. If not found, check the legacy root-level path
3. If not found at either path, warn the user
4. Do not block — the user may have the file elsewhere or want to proceed anyway
