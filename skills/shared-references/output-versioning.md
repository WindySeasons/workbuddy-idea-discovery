# Output Versioning Protocol (WorkBuddy Port)

When writing any output file that would overwrite an existing file, use timestamped filename + fixed-name latest copy:

1. Write output to timestamped file: `{FILENAME}_{YYYYMMDD_HHmmss}.md` (or `.json` as appropriate)
   - Timestamp precision to seconds to reduce collisions. In the rare case of sub-second conflicts, append `_2`, `_3` etc.
   - Place the timestamped file in the same directory as the fixed-name file
2. Copy the same content to the fixed-name file: `{FILENAME}.md` (overwrites the previous latest copy)
3. Downstream skills always read the fixed-name file — they do not need to know about timestamps

## Directory Structure

```
project/
├── MANIFEST.md                            # Output tracking manifest (root)
│
├── idea-stage/                            # Idea Discovery
│   ├── IDEA_REPORT.md                     # Latest copy
│   ├── IDEA_REPORT_20250615_143022.md     # Timestamped version
│   ├── IDEA_CANDIDATES.md
│   ├── REF_PAPER_SUMMARY.md
│   ├── LITERATURE_SURVEY.md
│   └── NOVELTY_CHECK_*.md
│
├── refine-logs/                           # Refinement & Experiment Planning
│   ├── EXPERIMENT_PLAN.md
│   ├── EXPERIMENT_TRACKER.md
│   ├── FINAL_PROPOSAL.md
│   ├── REFINE_STATE.json
│   ├── REVIEW_SUMMARY.md
│   ├── REFINEMENT_REPORT.md
│   └── round_N_*.md
```

## What to Timestamp

Files that get overwritten on re-runs:
- `IDEA_REPORT.md`, `IDEA_CANDIDATES.md`, `REF_PAPER_SUMMARY.md`
- `EXPERIMENT_PLAN.md`, `EXPERIMENT_TRACKER.md`
- `FINAL_PROPOSAL.md`
- State files: `REFINE_STATE.json`

## What NOT to Timestamp

- **Per-round files**: `refine-logs/round_N_*.md` — already versioned by round number
- **MANIFEST.md** — append-only tracking file

Never delete timestamped files. They are the permanent history.

## Path Fallback Rule

Skills that **read** stage-scoped files must fall back to the old root-level location for backward compatibility:
```
Read from idea-stage/IDEA_REPORT.md
If not found → fall back to ./IDEA_REPORT.md
```

Skills that **write** always use the stage-scoped path (never write to root).

## Stale State Detection

Before reading a state file (`REFINE_STATE.json`):
1. Check the file's last modified time
2. Default staleness threshold: **24 hours**
3. If older than the threshold, warn the user and offer to start fresh
