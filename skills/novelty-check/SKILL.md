---
name: novelty-check
description: "Verify research idea novelty against recent literature. Use when user says '查新', 'novelty check', '有没有人做过', 'check novelty', or wants to verify a research idea is novel before implementing. Triggered by idea-discovery workflow Phase 3."
argument-hint: "[method-or-idea-description]"
allowed-tools: Bash, Read, Write, Grep, Glob, WebSearch, WebFetch
---

# Novelty Check Skill (WorkBuddy Port)

Check whether a proposed method/idea has already been done in the literature: **$ARGUMENTS**

## Constants

- **REVIEWER_MODEL = built-in** — WorkBuddy uses the configured model (built-in or DeepSeek V4) for all reasoning. No external API or MCP needed.
- **SEARCH_YEAR_RANGE = 2023-2026** — Default year range for literature search. Adjust if the field moves slower/faster.
- **MIN_SEARCH_QUERIES = 3** — Minimum number of different query formulations per core claim.
- **TOP_VENUES** — ICLR 2025/2026, NeurIPS 2024/2025, ICML 2024/2025, CVPR 2024/2025, ECCV 2024, AAAI 2025, IJCAI 2025. Add domain-specific venues as needed.

## Instructions

Given a method description, systematically verify its novelty:

### Phase A: Extract Key Claims

1. Read the user's method description (from `$ARGUMENTS` or from `idea-stage/IDEA_REPORT.md`)
2. Identify **3-5 core technical claims** that would need to be novel:
   - What is the method?
   - What problem does it solve?
   - What is the mechanism / key innovation?
   - What makes it different from obvious baselines?

Output a structured claims list before proceeding.

### Phase B: Multi-Source Literature Search

For **EACH** core claim, search using ALL available sources:

#### 1. Web Search (via `WebSearch`)

For each claim, run at least **3 different query formulations**:
- Query 1: Exact technical terms + "paper" / "arXiv" / "2024 2025"
- Query 2: Problem-level query (what problem does this solve) + recent venue names
- Query 3: Broader area + key mechanism name + "novel" / "proposed" / "method"

Include year filters for recent work (default 2023-2026).

#### 2. arXiv Search (via `WebFetch`)

For the most promising search terms, directly query arXiv:
```
WebFetch: https://arxiv.org/search/?query=[URL-encoded terms]&searchtype=all&start=0
```

Extract titles and abstracts from the top 10 results.

#### 3. Semantic Scholar (via `WebFetch`)

```
WebFetch: https://api.semanticscholar.org/graph/v1/paper/search?query=[terms]&limit=10&fields=title,year,venue,abstract,citationCount
```

#### 4. Read Abstracts

For each potentially overlapping paper found:
- Use `WebFetch` to fetch the full abstract page (arXiv, Semantic Scholar, or publisher)
- Focus on: title, abstract, and "related work" or "we differ from" sections
- Note the exact overlap level: identical method / similar idea / same problem different solution / tangential

### Phase C: Deep Novelty Analysis

After gathering all search results, perform a thorough novelty analysis using the WorkBuddy configured model. This replaces the original Codex MCP cross-model verification.

For each core claim, evaluate:

1. **Direct hit**: Is there a paper that does exactly this?
2. **Near miss**: Is there a paper that does something very close? What's the delta?
3. **Implicit existence**: Even if no paper does exactly this, is the idea an "obvious next step" that reviewers would consider incremental?
4. **Concurrent risk**: Based on recent trends (last 6 months of arXiv), is someone likely working on this right now?

For the overall method:
- Is the **combination** of components novel, even if individual parts exist?
- Is the **experimental setting** or **application domain** novel?
- Would a NeurIPS/ICML reviewer consider this a "clear contribution" or "incremental extension"?

### Phase D: Novelty Report

Write a structured report to `idea-stage/NOVELTY_CHECK_[idea_short_name].md`:

```markdown
# Novelty Check Report

## Proposed Method
[1-2 sentence description]

## Core Claims Analysis

### Claim 1: [claim text]
- **Novelty**: HIGH / MEDIUM / LOW / NONE
- **Closest prior work**: [Paper title, year, venue]
- **Key difference**: [what distinguishes the proposed method]
- **Search evidence**: [which queries, how many overlapping papers found]

### Claim 2: [claim text]
- ...

## Closest Prior Work

| # | Paper | Year | Venue | Overlap Level | Key Difference | Confidence |
|---|-------|------|-------|--------------|----------------|-----------|
| 1 | [title] | [year] | [venue] | Identical / High / Medium / Low | [what's different] | High / Medium / Low |

## Overall Novelty Assessment

- **Score**: X/10
- **Recommendation**: PROCEED / PROCEED WITH CAUTION / ABANDON
- **Key differentiator**: [what makes this unique, if anything]
- **Biggest risk**: [what a reviewer would cite as prior work]
- **Concurrent work risk**: HIGH / MEDIUM / LOW
- **Positioning suggestion**: [how to frame the contribution to maximize novelty perception]

## Search Queries Used
[Log all queries run, with source and date, for reproducibility]
```

### Important Rules

- **Be BRUTALLY honest** — false novelty claims waste months of research time
- **"Applying X to Y" is NOT novel** unless the application reveals surprising insights or the combination is non-trivial
- **Check both the method AND the experimental setting** for novelty
- **If the method is not novel but the FINDING would be**, say so explicitly
- **Always check the most recent 6 months** of arXiv — the field moves fast
- **Anti-hallucination**: Every paper in the prior-work table must be verified via WebSearch or WebFetch. Never fabricate arXiv IDs, DOIs, or titles from memory. If you cannot verify a paper's existence, tag it `[UNVERIFIED]` and note the uncertainty
- **Granular assessment**: Don't give a single "novel" or "not novel" — break it down by claim. A method can have 2 novel claims and 1 incremental claim
- **Consider the reviewer's perspective**: Even if technically novel, would a reviewer at your target venue consider this contribution sufficient?
