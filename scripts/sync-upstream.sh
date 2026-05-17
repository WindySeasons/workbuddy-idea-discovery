#!/bin/bash
# sync-upstream.sh
# Sync migrated skills with upstream ARIS repository
# Usage: bash scripts/sync-upstream.sh [--dry-run]
#
# This script:
# 1. Fetches latest upstream ARIS changes
# 2. Compares upstream skill files with our migrated versions
# 3. If conflicts detected, reports them without auto-merging
# 4. If no conflicts, attempts auto-merge of non-WorkBuddy-specific changes

set -euo pipefail

UPSTREAM_REPO="wanshuiyin/Auto-claude-code-research-in-sleep"
UPSTREAM_BRANCH="main"
LOCAL_SKILLS_DIR="./skills"
ARIS_CLONE_DIR="./.aris-upstream"
SYNC_LOG="./.sync-log"
DRY_RUN="${1:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[sync]${NC} $1"; }
ok() { echo -e "${GREEN}[ok]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
err() { echo -e "${RED}[error]${NC} $1"; }

# Map ARIS skill directories to our migrated skill names
declare -A SKILL_MAP=(
  ["research-lit"]="research-lit"
  ["idea-creator"]="idea-creator"
  ["idea-discovery"]="idea-discovery"
  ["novelty-check"]="novelty-check"
  ["research-review"]="research-review"
  ["research-refine"]="research-refine"
  ["experiment-plan"]="experiment-plan"
)

# WorkBuddy-specific patterns that should NOT be overwritten
WB_PATTERNS=(
  "allowed-tools"
  "WorkBuddy"
  "workbuddy"
  "Tencent"
  "mcp__"
  "Bash("
  "WebSearch"
  "WebFetch"
)

echo "========================================"
echo "  ARIS Upstream Sync"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
echo ""

# Step 1: Clone/fetch upstream
log "Fetching upstream: $UPSTREAM_REPO ($UPSTREAM_BRANCH)"

if [ -d "$ARIS_CLONE_DIR/.git" ]; then
  git -C "$ARIS_CLONE_DIR" fetch origin "$UPSTREAM_BRANCH" 2>/dev/null
  git -C "$ARIS_CLONE_DIR" reset --hard "origin/$UPSTREAM_BRANCH" 2>/dev/null
  ok "Updated existing clone"
else
  git clone --depth 1 --branch "$UPSTREAM_BRANCH" \
    "https://github.com/$UPSTREAM_REPO.git" "$ARIS_CLONE_DIR" 2>/dev/null
  ok "Cloned upstream (shallow)"
fi

# Step 2: Check for upstream changes
log "Checking for skill file changes..."
CHANGES_FOUND=0
CONFLICTS_FOUND=0
SKIPPED=()

for aris_dir in "${!SKILL_MAP[@]}"; do
  local_dir="${SKILL_MAP[$aris_dir]}"
  aris_skill="$ARIS_CLONE_DIR/$aris_dir"
  local_skill="$LOCAL_SKILLS_DIR/$local_dir"

  if [ ! -d "$aris_skill" ]; then
    warn "Upstream skill not found: $aris_dir"
    continue
  fi

  if [ ! -d "$local_skill" ]; then
    warn "Local skill not found: $local_dir"
    continue
  fi

  # Find the SKILL.md in upstream (might be at root or in subdirectory)
  aris_skill_md=$(find "$aris_skill" -name "SKILL.md" -type f 2>/dev/null | head -1)
  local_skill_md="$local_skill/SKILL.md"

  if [ -z "$aris_skill_md" ]; then
    warn "No SKILL.md in upstream: $aris_dir"
    continue
  fi

  if [ ! -f "$local_skill_md" ]; then
    warn "No SKILL.md in local: $local_dir"
    continue
  fi

  # Compare file contents
  if diff -q "$aris_skill_md" "$local_skill_md" > /dev/null 2>&1; then
    # Files are identical
    continue
  fi

  CHANGES_FOUND=$((CHANGES_FOUND + 1))
  log "Changes detected in: $local_dir"

  # Check for potential conflicts
  # If upstream has WorkBuddy-specific patterns, our local version already has them
  # The key risk is upstream changing workflow/logic that conflicts with our adaptations

  # Get upstream commit hash for reference
  UPSTREAM_COMMIT=$(git -C "$ARIS_CLONE_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")

  # Check if changes are only in Claude-specific sections (if any)
  aris_has_wb=$(grep -l -E "$(IFS='|'; echo "${WB_PATTERNS[*]}")" "$aris_skill_md" 2>/dev/null || true)

  if [ -n "$aris_has_wb" ]; then
    # Upstream now has WorkBuddy patterns - possible convergence
    warn "  Upstream $local_dir may have WorkBuddy adaptations - manual review needed"
    CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
    SKIPPED+=("$local_dir (possible conflict)")
  else
    # Upstream changes are Claude-specific, safe to review for merge
    ok "  Upstream $local_dir has upstream-only changes"
  fi

  # Show a brief diff summary
  added=$(diff "$local_skill_md" "$aris_skill_md" 2>/dev/null | grep "^>" | wc -l)
  removed=$(diff "$local_skill_md" "$aris_skill_md" 2>/dev/null | grep "^<" | wc -l)
  log "  Diff summary: +$added lines upstream, -$removed lines local"
done

echo ""
echo "========================================"
echo "  Sync Summary"
echo "========================================"
echo "Skills with changes: $CHANGES_FOUND"
echo "Potential conflicts:  $CONFLICTS_FOUND"

if [ $CHANGES_FOUND -eq 0 ]; then
  ok "Everything is up to date!"
  echo "$(date '+%Y-%m-%d %H:%M:%S') | no-changes" >> "$SYNC_LOG"
  exit 0
fi

if [ $CONFLICTS_FOUND -gt 0 ]; then
  warn "Conflicts detected in ${#SKIPPED[@]} skill(s):"
  for s in "${SKIPPED[@]}"; do
    warn "  - $s"
  done
  echo ""
  warn "Manual review required. Upstream changes saved in: $ARIS_CLONE_DIR"
  echo "$(date '+%Y-%m-%d %H:%M:%S') | conflicts: ${SKIPPED[*]}" >> "$SYNC_LOG"
  exit 1
fi

# Step 3: If no conflicts, report what can be auto-merged
if [ "$DRY_RUN" = "--dry-run" ]; then
  ok "Dry run complete. No files modified."
  echo "$(date '+%Y-%m-%d %H:%M:%S') | dry-run | changes: $CHANGES_FOUND" >> "$SYNC_LOG"
  exit 0
fi

# Step 4: Auto-merge non-conflicting changes
log "Attempting auto-merge..."
MERGED=0
for aris_dir in "${!SKILL_MAP[@]}"; do
  local_dir="${SKILL_MAP[$aris_dir]}"
  aris_skill_md=$(find "$ARIS_CLONE_DIR/$aris_dir" -name "SKILL.md" -type f 2>/dev/null | head -1)
  local_skill_md="$LOCAL_SKILLS_DIR/$local_dir/SKILL.md"

  if [ -z "$aris_skill_md" ] || ! diff -q "$aris_skill_md" "$local_skill_md" > /dev/null 2>&1; then
    continue
  fi

  # Skip if already in skipped list
  skip=false
  for s in "${SKIPPED[@]}"; do
    if [[ "$s" == "$local_dir"* ]]; then skip=true; break; fi
  done
  $skip && continue

  # Backup before merge
  cp "$local_skill_md" "${local_skill_md}.bak"
  # Copy upstream version
  cp "$aris_skill_md" "$local_skill_md"
  MERGED=$((MERGED + 1))
  ok "  Merged: $local_dir (backup: ${local_skill_md}.bak)"
done

echo ""
ok "Auto-merged $MERGED skill(s)"
echo "$(date '+%Y-%m-%d %H:%M:%S') | merged: $MERGED | conflicts: $CONFLICTS_FOUND" >> "$SYNC_LOG"
echo ""
warn "Note: Merged files replace local versions. Check .bak files if issues arise."
echo "Upstream reference: $ARIS_CLONE_DIR"
