---
name: research-review
description: "Get a deep critical review of research ideas or proposals. Use when user says 'review my research', 'help me review', 'get external review', '评审我的想法', or wants critical feedback on research ideas, papers, or experimental results. Triggered by idea-discovery workflow Phase 4."
argument-hint: "[topic-or-scope]"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, WebSearch, WebFetch
---

# Research Review Skill (WorkBuddy Port)

Get a multi-round critical review of research work with maximum reasoning depth.

## Constants

- **REVIEWER_MODEL = built-in** — WorkBuddy uses the configured model (built-in or DeepSeek V4) for all review reasoning. No external API or MCP needed.
- **MAX_REVIEW_ROUNDS = 3** — Maximum number of review iterations. Each round addresses previous feedback and deepens analysis.
- **REVIEW_DEPTH = thorough** — Review style: "quick" (surface-level) or "thorough" (deep analysis with specific suggestions). Default: thorough.

## Context: $ARGUMENTS

## Workflow

### Step 1: Gather Research Context

Before performing the review, compile a comprehensive briefing from available materials:

1. **Read project documents** (if they exist):
   - `idea-stage/IDEA_REPORT.md` — ranked ideas and novelty check results
   - `idea-stage/NOVELTY_CHECK_*.md` — detailed novelty reports
   - `idea-stage/REF_PAPER_SUMMARY.md` — reference paper analysis
   - `idea-stage/LITERATURE_SURVEY.md` — literature landscape
   - Any experiment logs, pilot results, or preliminary data

2. **Extract key information**:
   - Core claims and hypotheses
   - Methodology description
   - Key results (if any)
   - Known weaknesses or limitations
   - Target venue (NeurIPS, ICML, ICLR, etc.)

3. **If $ARGUMENTS is a specific idea or topic**, focus the review on that. Otherwise, review the top-ranked idea from IDEA_REPORT.md.

### Step 2: Initial Review (Round 1)

Perform a deep critical review acting as a **senior ML reviewer** (NeurIPS/ICML level). Address:

#### 2.1 Strengths
- What is the core contribution?
- Why might this matter to the community?
- What are the strongest aspects of the approach?

#### 2.2 Weaknesses
- **Logical gaps or unjustified claims**: Are there claims that lack sufficient evidence or reasoning?
- **Missing experiments**: What experiments would a reviewer expect to see?
- **Baseline comparison**: Are the right baselines included? Are they fairly implemented?
- **Novelty concerns**: Is the contribution sufficiently differentiated from prior work?
- **Scalability / generalization**: Does the method scale beyond the shown setting?
- **Reproducibility**: Could another researcher reproduce this from the description?

#### 2.3 Questions for Authors
- Generate 3-5 specific, answerable questions a reviewer would ask

#### 2.4 Scoring
- **Overall score**: X/10
- **Confidence**: High / Medium / Low
- **Recommendation**: Strong Accept / Accept / Weak Accept / Borderline / Weak Reject / Reject

#### 2.5 What Would Move Toward Accept
- Specific, actionable improvements that would increase the score

### Step 3: Iterative Refinement (Rounds 2-N)

For each subsequent round (up to MAX_REVIEW_ROUNDS):

1. **Address previous feedback**: For each weakness identified in the previous round, evaluate:
   - Can this be fixed? How?
   - Is it a fatal flaw or a fixable issue?
   - What's the minimum effort to address it?

2. **Targeted follow-ups**:
   - "If we reframe X as Y, does that change the assessment?"
   - "What's the minimum experiment to satisfy concern Z?"
   - "What baselines are absolutely required vs. nice-to-have?"

3. **Concrete deliverables** (as appropriate):
   - Experiment design with specific configurations
   - Paper outline with section-by-section claims
   - Claims matrix: what claim is allowed under each possible experimental outcome
   - Ablation study priorities (highest acceptance lift per GPU hour)

### Step 4: Convergence

Stop iterating when:
- All major weaknesses have been addressed with concrete plans
- A clear experiment roadmap is established
- The narrative structure is settled
- OR MAX_REVIEW_ROUNDS is reached

### Step 5: Document Everything

Save the complete review to `idea-stage/REVIEW_[idea_short_name].md`:

```markdown
# Research Review: [Idea Title]

**Reviewer**: WorkBuddy Configured Model (Thorough Review)
**Date**: [today]
**Rounds**: [N]

---

## Round 1: Initial Review

### Summary
[2-3 paragraph summary of the research]

### Strengths
1. [Strength 1]
2. [Strength 2]
...

### Weaknesses
1. [Weakness 1] — Severity: Major / Minor
   - Concern: [description]
   - Suggested fix: [concrete suggestion]
2. [Weakness 2] — ...
...

### Questions for Authors
1. [Question 1]
2. [Question 2]
...

### Scores
| Criterion | Score (1-10) | Notes |
|-----------|-------------|-------|
| Novelty | X | |
| Significance | X | |
| Soundness | X | |
| Clarity | X | |
| Overall | X | |

### Recommendation
- **Verdict**: [Accept/Reject/Borderline]
- **Confidence**: [High/Medium/Low]
- **Key reason**: [one sentence]

### What Would Move Toward Accept
1. [Actionable improvement 1]
2. [Actionable improvement 2]
...

---

## Round 2: Refinement
[If applicable — updated assessment after addressing Round 1 feedback]

### Updated Scores
| Criterion | Previous | Updated | Notes |
|-----------|----------|---------|-------|
| Novelty | X | X | |
| Overall | X | X | |

### Remaining Concerns
[What's still not resolved]

---

## Final Consensus

### Verdict: [Final recommendation]
### Must-do before submission:
1. [Critical item 1]
2. [Critical item 2]
### Nice-to-have:
1. [Optional improvement 1]
2. [Optional improvement 2]

### Minimal Experiment Package
[If experiments were discussed: concrete plan with configurations, baselines, metrics, compute estimate]

### Claims Matrix
| Experiment | Expected Outcome | Claim Allowed | If Fails |
|-----------|-----------------|--------------|----------|
| [Exp 1] | [result] | [claim] | [fallback claim] |
| [Exp 2] | [result] | [claim] | [fallback claim] |
```

## Key Rules

- **Be brutally honest** — hiding weaknesses leads to worse feedback and wasted research time
- **Send comprehensive context in Round 1** — include all available materials
- **Push back on criticisms you disagree with**, but accept valid ones — use reasoning, not defensiveness
- **Focus on ACTIONABLE feedback** — every weakness should come with a concrete suggestion for how to fix it
- **The review document must be self-contained** — readable without the conversation
- **Don't inflate scores** — a realistic 6/10 with honest weaknesses is more useful than a false 9/10
- **Consider the target venue's bar** — what's acceptable at a workshop differs from NeurIPS
