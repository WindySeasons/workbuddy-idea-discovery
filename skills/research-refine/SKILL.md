---
name: research-refine
description: "Turn a vague research direction into a problem-anchored, elegant, frontier-aware, implementation-oriented method plan via iterative model review. Use when the user says 'refine my approach', '帮我细化方案', 'decompose this problem', '打磨idea', 'refine research plan', '细化研究方案', or wants a concrete research method that stays simple, focused, and top-venue ready."
argument-hint: "[problem | approach]"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, WebSearch, WebFetch
---

# Research Refine: Problem-Anchored, Elegant, Frontier-Aware Plan Refinement

Refine and concretize: **$ARGUMENTS**

## Overview

Use this skill when the research problem is already visible but the technical route is still fuzzy. The goal is not to produce a bloated proposal or a benchmark shopping list. The goal is to turn a vague direction into a **problem -> focused method -> minimal validation** document that is concrete enough to implement, elegant enough to feel paper-worthy, and current enough to resonate in the foundation-model era.

Four principles dominate this skill:

1. **Do not lose the original problem.** Freeze an immutable **Problem Anchor** and reuse it in every round.
2. **The smallest adequate mechanism wins.** Prefer the minimal intervention that directly fixes the bottleneck.
3. **One paper, one dominant contribution.** Prefer one sharp thesis plus at most one supporting contribution.
4. **Modern leverage is a prior, not a decoration.** When LLM / VLM / Diffusion / RL / distillation / inference-time scaling naturally fit the bottleneck, use them concretely. Do not bolt them on as buzzwords.

```
User input (PROBLEM + vague APPROACH)
  -> Phase 0: Freeze Problem Anchor
  -> Phase 1: Scan grounding papers -> identify technical gap -> choose sharpest route -> write focused proposal
  -> Phase 2: Self-review for fidelity, specificity, contribution quality, and frontier leverage
  -> Phase 3: Anchor check + simplicity check -> revise method -> rewrite full proposal
  -> Phase 4: Re-evaluate revised proposal (same review rubric)
  -> Repeat Phase 3-4 until OVERALL SCORE >= 9 or MAX_ROUNDS reached
  -> Phase 5: Save full history to refine-logs/
  -> Optional handoff: /experiment-plan for detailed execution-ready experiment roadmap
```

## Constants

- **REVIEWER_MODEL = built-in** — WorkBuddy uses the configured model (built-in or DeepSeek V4) for all reasoning. No external API or MCP needed.
- **MAX_ROUNDS = 5** — Maximum review-revise rounds.
- **SCORE_THRESHOLD = 9** — Minimum overall score to stop.
- **OUTPUT_DIR = `refine-logs/`** — Directory for round files and final report.
- **MAX_LOCAL_PAPERS = 15** — Maximum local papers/notes to scan for grounding.
- **MAX_CORE_EXPERIMENTS = 3** — Default cap for core validation blocks inside this skill.
- **MAX_PRIMARY_CLAIMS = 2** — Soft cap for paper-level claims. Prefer one dominant claim plus one supporting claim.
- **MAX_NEW_TRAINABLE_COMPONENTS = 2** — Soft cap for genuinely new trainable pieces. Exceed only if the paper breaks otherwise.

## State Persistence (Checkpoint Recovery)

Long-running refinement sessions may fail mid-way (e.g., context compaction, or session interruption). To avoid losing completed work, persist state to `refine-logs/REFINE_STATE.json` after each phase boundary:

```json
{
  "phase": "review",
  "round": 1,
  "last_score": 6.5,
  "last_verdict": "REVISE",
  "status": "in_progress",
  "timestamp": "2026-03-22T20:00:00"
}
```

**Field definitions:**

| Field | Values | Meaning |
|-------|--------|---------|
| `phase` | `"anchor"` / `"proposal"` / `"review"` / `"refine"` / `"done"` | Last **completed** phase |
| `round` | 0–MAX_ROUNDS | Current round number |
| `last_score` | number or null | Most recent overall score from review |
| `last_verdict` | string or null | Most recent verdict (READY / REVISE / RETHINK) |
| `status` | `"in_progress"` / `"completed"` | Loop status |
| `timestamp` | ISO 8601 | When state was last written |

**Write rules:**
- **Write after each phase completes** (not before). Overwrite each time — only the latest state matters.
- **On completion** (Phase 5 finished), set `"status": "completed"`.

## Output Structure

```
refine-logs/
├── REFINE_STATE.json
├── round-0-initial-proposal.md
├── round-1-review.md
├── round-1-refinement.md
├── round-2-review.md
├── round-2-refinement.md
├── ...
├── REVIEW_SUMMARY.md
├── FINAL_PROPOSAL.md
├── REFINEMENT_REPORT.md
└── score-history.md
```

Every `round-N-refinement.md` must contain a **full anchored proposal**, not just incremental fixes.

## Workflow

### Initialization (Checkpoint Recovery)

Before starting any phase, check whether a previous run left a checkpoint:

1. **Check for `refine-logs/REFINE_STATE.json`**:
   - If it **does not exist** → **fresh start** (proceed to Phase 0 normally)
   - If it exists AND `status` is `"completed"` → **fresh start** (delete state file, previous run finished)
   - If it exists AND `status` is `"in_progress"` AND `timestamp` is **older than 24 hours** → **fresh start** (stale state — delete the file)
   - If it exists AND `status` is `"in_progress"` AND `timestamp` is **within 24 hours** → **resume**

2. **On resume**, read the state file and recover context:
   - Read all existing `refine-logs/round-*.md` files to restore prior work
   - Read `refine-logs/score-history.md` if it exists
   - Log to the user: `"Checkpoint found. Resuming after phase: {phase}, round: {round}."`
   - **Jump to the next phase** based on the saved `phase` value:

   | Saved `phase` | What was completed | Resume from |
   |---------------|-------------------|-------------|
   | `"anchor"` | Phase 0 done | Phase 1 (read anchor from round-0 context) |
   | `"proposal"` | Phase 1 done | Phase 2 (read `round-0-initial-proposal.md`) |
   | `"review"` | Phase 2 or 4 done | Phase 3 (read latest `round-N-review.md`) |
   | `"refine"` | Phase 3 done | Phase 4 (read latest `round-N-refinement.md`) |

3. **On fresh start**, ensure `refine-logs/` directory exists and proceed to Phase 0.

### Phase 0: Freeze the Problem Anchor

Before proposing anything, extract the user's immutable bottom-line problem. This anchor must be copied verbatim into every proposal and every refinement round.

Write:

- **Bottom-line problem**: What technical problem must be solved?
- **Must-solve bottleneck**: What specific weakness in current methods is unacceptable?
- **Non-goals**: What is explicitly *not* the goal of this project?
- **Constraints**: Compute, data, time, tooling, venue, deployment limits.
- **Success condition**: What evidence would make the user say "yes, this method addresses the actual problem"?

If later reviewer feedback would change the problem being solved, mark that as **drift** and push back or adapt carefully.

**Checkpoint:** Write `refine-logs/REFINE_STATE.json` with `{"phase": "anchor", "round": 0, "last_score": null, "last_verdict": null, "status": "in_progress", "timestamp": "<now>"}`.

### Phase 1: Build the Initial Proposal

#### Step 1.1: Scan Grounding Material

Check `papers/`, `literature/`, `idea-stage/` first. Read only the relevant parts needed to answer:

- What mechanism do current methods use?
- Where exactly do they fail for this problem?
- Which recent LLM / VLM / Diffusion / RL era techniques are actually relevant here?
- What training objectives, representations, or interfaces are reusable?
- What details distinguish a real method from a renamed high-level idea?

If local material is insufficient, search recent top-venue/arXiv work online via WebSearch/WebFetch. Focus on **method sections, training setup, and failure modes**, not just abstracts.

#### Step 1.2: Identify the Technical Gap

Do not stop at generic research questions. Make the gap operational:

1. **Current pipeline failure point**: where does the baseline break?
2. **Why naive fixes are insufficient**: larger context, more data, prompting, memory bank, or stacking more modules.
3. **Smallest adequate intervention**: what is the least additional mechanism that could plausibly fix the bottleneck?
4. **Frontier-native alternative**: is there a more current route using foundation-model-era primitives that better matches the bottleneck?
5. **Core technical claim**: what exact mechanism claim could survive top-venue scrutiny?
6. **Required evidence**: what minimum proof is needed to defend that claim?

#### Step 1.3: Choose the Sharpest Route

Before locking the method, compare two candidate routes if both are plausible:

- **Route A: Elegant minimal route** — the smallest mechanism that directly targets the bottleneck.
- **Route B: Frontier-native route** — a more modern route that uses LLM / VLM / Diffusion / RL / distillation / inference-time scaling *only if* it gives a cleaner or stronger story.

Then decide:
- Which route is more likely to become a strong paper under the stated constraints?
- Which route has the cleaner novelty story relative to the closest work?
- Which route avoids contribution sprawl?

If both routes are weak, rethink the framing instead of combining them into a larger system by default.

#### Step 1.4: Concretize the Method First

The proposal must answer "how would we actually build this?" Prefer method detail over broad experimentation and prefer reuse over invention.

Cover:

1. **One-sentence method thesis**: the single strongest mechanism claim.
2. **Contribution focus**: one dominant contribution and at most one supporting contribution.
3. **Complexity budget**: what is frozen or reused, what is new, and what tempting additions are intentionally excluded.
4. **System graph**: modules, data flow, inputs, outputs.
5. **Representation design**: what latent, embedding, plan token, reward signal, memory state, or alignment space is used?
6. **Training recipe**: data source, supervision, pseudo-labeling, negatives, curriculum, losses, weighting, stagewise vs joint training.
7. **Inference path**: how the trained components are used at test time.
8. **Why the mechanism stays small**: why a larger stack is unnecessary.
9. **Exact role of any frontier primitive**: if you use an LLM / VLM / Diffusion / RL component, specify its exact role.
10. **Failure handling**: what could go wrong and what fallback or diagnostic exists?
11. **Novelty and elegance argument**: why this is more than naming a module and why the paper still looks focused.

If the method is still only described as "add a module" or "use a planner," it is not concrete enough.

#### Step 1.5: Design Minimal Claim-Driven Validation

Experiments exist to validate the method, not to dominate the document.

For each core claim, define the **smallest strong experiment** that can validate it:
- the claim being tested
- the necessary baseline or ablation
- the decisive metric
- the expected directional outcome

Additional rules:
- Ensure one experiment block directly supports the **Problem Anchor**.
- If complexity risk exists, include one **simplification or deletion check**.
- If a frontier primitive is central, include one **necessity check**.
- Default to **1-3 core experiment blocks** and leave the full execution roadmap to `/experiment-plan`.

#### Step 1.6: Write the Initial Proposal

Save to `refine-logs/round-0-initial-proposal.md` using the standard proposal structure (Problem Anchor, Technical Gap, Method Thesis, Contribution Focus, Proposed Method, Claim-Driven Validation Sketch, Compute & Timeline Estimate).

**Checkpoint:** Update `refine-logs/REFINE_STATE.json` with `{"phase": "proposal", "round": 0, ...}`.

### Phase 2: Self-Review (Round 1)

Perform a rigorous **elegance-first, frontier-aware, method-first** review of the full proposal. The review should stress-test whether the proposed method:

1. still solves the original anchored problem,
2. is concrete enough to implement,
3. presents a focused, elegant contribution,
4. uses foundation-model-era techniques appropriately when they are the natural fit.

**Review principles:**
- Prefer the smallest adequate mechanism over a larger system.
- Penalize parallel contributions that make the paper feel unfocused.
- If a modern LLM / VLM / Diffusion / RL route would clearly produce a better paper, say so concretely.
- If the proposal is already modern enough, do NOT force trendy components.
- Do not ask for extra experiments unless they are needed to prove the core claims.

**Read the Problem Anchor first.** If a suggested fix would change the problem being solved, call that out explicitly as drift.

**Score these 7 dimensions from 1-10:**

1. **Problem Fidelity**: Does the method still attack the original bottleneck, or has it drifted?
2. **Method Specificity**: Are the interfaces, representations, losses, training stages, and inference path concrete enough?
3. **Contribution Quality**: Is there one dominant mechanism-level contribution with real novelty and no contribution sprawl?
4. **Frontier Leverage**: Does the proposal use foundation-model-era primitives appropriately?
5. **Feasibility**: Can this be trained and integrated with the stated resources?
6. **Validation Focus**: Are the experiments minimal but sufficient?
7. **Venue Readiness**: Would this feel sharp and timely enough for a top venue?

**OVERALL SCORE** (1-10): Weighted — Problem Fidelity 15%, Method Specificity 25%, Contribution Quality 25%, Frontier Leverage 15%, Feasibility 10%, Validation Focus 5%, Venue Readiness 5%.

For each dimension scoring < 7, provide:
- The specific weakness
- A concrete fix at the method level
- Priority: CRITICAL / IMPORTANT / MINOR

Then add:
- **Simplification Opportunities**: 1-3 concrete ways to delete, merge, or reuse components while preserving the main claim.
- **Modernization Opportunities**: 1-3 concrete ways to replace old-school pieces with more natural foundation-model-era primitives if genuinely better.
- **Drift Warning**: "NONE" if the proposal still solves the anchored problem; otherwise explain the drift.
- **Verdict**: READY / REVISE / RETHINK

Verdict rule:
- READY: overall score >= 9, no meaningful drift, one focused dominant contribution, no obvious complexity bloat
- REVISE: the direction is promising but not yet at READY bar
- RETHINK: the core mechanism or framing is still fundamentally off

Save review to `refine-logs/round-1-review.md`.

**Checkpoint:** Update `refine-logs/REFINE_STATE.json` with `{"phase": "review", "round": 1, "last_score": <parsed>, "last_verdict": "<parsed>", ...}`.

### Phase 3: Parse Feedback and Revise the Method

#### Step 3.1: Parse the Review

Extract all scores, verdict, drift warning, simplification opportunities, modernization opportunities, and action items.

Update `refine-logs/score-history.md`:

```markdown
# Score Evolution

| Round | Problem Fidelity | Method Specificity | Contribution Quality | Frontier Leverage | Feasibility | Validation Focus | Venue Readiness | Overall | Verdict |
|-------|------------------|--------------------|----------------------|-------------------|-------------|------------------|-----------------|---------|---------|
| 1     | X                | X                  | X                    | X                 | X           | X                | X               | X       | REVISE  |
```

**STOP CONDITION**: If overall score >= SCORE_THRESHOLD, verdict is READY, and there is no unresolved drift warning, skip to Phase 5.

#### Step 3.2: Revise With an Anchor Check and a Simplicity Check

Before changing anything:

1. Copy the **Problem Anchor verbatim**.
2. Write an **Anchor Check**:
   - What is the original bottleneck?
   - Does the current method still solve it?
   - Which review suggestions would cause drift if followed blindly?
3. Write a **Simplicity Check**:
   - What is the dominant contribution now?
   - What components can be removed, merged, or kept frozen?
   - Which review suggestions add unnecessary complexity?
   - If a frontier primitive is central, is its role still crisp and justified?

Then process reviewer feedback:
- If **valid**: sharpen the mechanism, simplify if possible, or modernize if the paper really improves.
- If **debatable**: revise, but explain reasoning with evidence.
- If **wrong, drifting, or over-complicating**: push back with evidence from local papers and the Problem Anchor.

Save to `refine-logs/round-N-refinement.md` (must contain the full revised proposal, not just incremental fixes).

**Checkpoint:** Update `refine-logs/REFINE_STATE.json` with `{"phase": "refine", "round": N, ...}`.

### Phase 4: Re-evaluation (Round 2+)

Re-review the revised proposal using the **same 7-dimension rubric** from Phase 2. Compare with previous round:
- Did scores improve?
- Is the Problem Anchor preserved?
- Is the dominant contribution sharper?
- Is the method simpler?
- Is the frontier leverage appropriate?

Save review to `refine-logs/round-N-review.md`.

**Checkpoint:** Update `refine-logs/REFINE_STATE.json`.

Then return to Phase 3 until:
- **Overall score >= SCORE_THRESHOLD** and verdict is READY and no unresolved drift
- or **MAX_ROUNDS reached**

### Phase 5: Final Report and Logs

#### Step 5.1: Write `refine-logs/REVIEW_SUMMARY.md`
#### Step 5.2: Write `refine-logs/FINAL_PROPOSAL.md` (clean final version, no review chatter)
#### Step 5.3: Write `refine-logs/REFINEMENT_REPORT.md` (full history with raw reviews)
#### Step 5.4: Finalize `refine-logs/score-history.md`
#### Step 5.5: Present a Brief Summary to the User

```
Refinement complete after N rounds.

Final score: X/10 (Verdict: READY / REVISE / RETHINK)

Anchor status: [preserved / drift corrected / unresolved concern]
Focus status: [tight / slightly broad / still diffuse]
Modernity status: [appropriately frontier-aware / intentionally conservative / still old-school]

Key method upgrades:
- [method change 1]
- [method change 2]

Remaining concerns: [if any]

Files: REVIEW_SUMMARY.md | REFINEMENT_REPORT.md | FINAL_PROPOSAL.md
Suggested next step: /experiment-plan
```

**Checkpoint:** Update `refine-logs/REFINE_STATE.json` with `{"phase": "done", "status": "completed", ...}`.

## Key Rules

- **Anchor first, every round.** Always carry forward the same Problem Anchor.
- **One paper, one dominant contribution.** Avoid multiple parallel contributions unless truly needed.
- **The smallest adequate mechanism wins.** Bigger is not automatically better.
- **Prefer reuse over invention.** Start from strong existing backbones.
- **Modern techniques are a prior, not a decoration.** Use them when they sharpen the method.
- **Minimal experiments.** Inside this skill, experiments only need to prove core claims.
- **Pushback is encouraged.** If feedback causes drift or unnecessary complexity, argue back with evidence.
- **Do not fabricate results.** Only describe expected evidence and planned experiments.
- **Be specific about compute and data assumptions.**
- **Document everything.** Save every review, anchor check, simplicity check, and major method change.
- **Large file handling**: If Write tool fails due to file size, use Bash (`cat << 'EOF' > file`) to write in chunks silently.

## Composing with Other Skills

```
/idea-creator "direction"       -> candidate ideas
/research-refine "PROBLEM: ... | APPROACH: ..."  <- you are here
/experiment-plan                -> detailed experiment roadmap
```
