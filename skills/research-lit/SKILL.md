---
name: research-lit
description: "Search and analyze research papers, find related work, summarize key ideas. Use when user says '找文献', '文献调研', 'related work', 'literature review', or needs to understand academic papers. Triggered by idea-discovery workflow Phase 1."
argument-hint: [paper-topic-or-url]
allowed-tools: Bash, Read, Write, Glob, Grep, WebSearch, WebFetch, Skill
---

# Research Literature Review (WorkBuddy Port)

Research topic: $ARGUMENTS

## Constants

- **ARXIV_DOWNLOAD = false** — When `true`, download top 3-5 most relevant arXiv PDFs. When `false` (default), only fetch metadata (title, abstract, authors) via arXiv API.
- **MAX_LOCAL_PAPERS = 10** — Maximum number of local PDFs to scan (read first 3 pages each). If more are found, prioritize by filename relevance to the topic.
- **MAX_WEB_RESULTS = 15** — Maximum number of web search results to process.

> 💡 Overrides (parse from $ARGUMENTS):
> - `--arxiv-download` or `--arxiv-download:true` — download arXiv PDFs
> - `--max-download:N` — download at most N PDFs
> - `--local-only` — only search local PDFs, skip web
> - `--web-only` — only search web (skip local)

---

## Workflow

### Step 0: Parse Arguments

Extract from `$ARGUMENTS`:
1. The research topic or paper URL
2. Any override flags (`--arxiv-download`, `--local-only`, etc.)

If the argument is a URL (arXiv, paper page, etc.), set it as `TARGET_PAPER` and extract its metadata first.

---

### Step 1: Scan Local Paper Library

Before searching online, check if the user already has relevant papers locally:

1. **Locate library**: Check these paths in order:
   ```
   Glob: papers/**/*.pdf
   Glob: literature/**/*.pdf
   Glob: pdfs/**/*.pdf
   ```

2. **Filter by relevance**: Match filenames and (if possible) first-page content against the research topic.

3. **Summarize relevant papers** (up to MAX_LOCAL_PAPERS):
   - Use `Read` tool to read the first 3 pages of each relevant PDF
   - Extract: title, authors, year, core contribution, relevance to topic
   - Flag papers that are directly related vs tangentially related

4. **Build local knowledge base**: Compile summaries into `idea-stage/LITERATURE_LOCAL_SUMMARY.md`

> 📚 If no local papers are found, skip to Step 2. If the user has a comprehensive local collection, the external search can be more targeted (focus on what's missing).

---

### Step 2: Search External Sources

Use **WebSearch** and **WebFetch** to find recent papers on the topic.

#### 2a: arXiv Search (Primary)

Search arXiv via WebFetch (arXiv API is publicly accessible):

```
Use WebFetch to fetch:
  URL: https://export.arxiv.org/api/query?search_query=all:[QUERY]&max_results=10&sortBy=submittedDate&sortOrder=descending
  Prompt: Extract paper titles, arXiv IDs, authors, abstracts, and submission dates from this XML response. Return as a structured list.
```

For each relevant paper found:
- Record: arXiv ID, title, authors, abstract, submitted date
- If `ARXIV_DOWNLOAD = true`, use WebFetch to download the PDF from `https://arxiv.org/pdf/[ARXIV_ID].pdf` and save to `papers/` directory

#### 2b: WebSearch for Broader Discovery

Use WebSearch to find:
- Recent papers on the topic (last 2 years unless studying foundational work)
- Survey papers (especially valuable for landscape mapping)
- Open review discussions (Papers with Code, Reddit r/MachineLearning)

Extract from WebSearch results:
- Paper titles and URLs
- Conference/journal names if available
- Brief snippets about contributions

#### 2c: De-duplicate

Merge results from Step 1 (local) and Step 2a-2b (external):
- Match by title similarity
- Remove duplicates
- Prioritize: local PDF > arXiv > web snippet

---

### Step 3: Analyze Each Paper

For **each unique paper** found (up to 15 total, prioritize by relevance):

1. **If local PDF available**: Read first 3 pages (title, abstract, intro, method overview)
2. **If arXiv only**: Use WebFetch to read the arXiv abstract page for full abstract
3. **If web-only**: Use WebFetch to read the paper page or abstract

Extract for each paper:
- **Problem**: What gap does it address?
- **Method**: Core technical contribution (1-2 sentences)
- **Results**: Key numbers/claims
- **Relevance**: How does it relate to our research direction? (High/Medium/Low)
- **Year/Venue**: For prioritization

---

### Step 4: Synthesize

After analyzing all papers:

1. **Group papers by approach/theme**
   - Identify clusters of similar methods
   - Note which approaches are most popular / most effective

2. **Identify structural gaps**
   - What problems are unsolved?
   - What approaches have been tried but failed?
   - What are the limitations acknowledged by authors?

3. **Build landscape map**
   - Core problem → existing approaches → their limitations → open gaps

---

### Step 5: Output

Write `idea-stage/LITERATURE_SURVEY.md`:

```markdown
# Literature Survey: $ARGUMENTS

**Date**: [today]
**Sources**: Local PDFs ([N]), arXiv ([N]), Web ([N])

---

## Landscape Overview

[2-3 paragraphs: what are the main approaches, which are promising, what are the open problems?]

---

## Papers Analyzed

### Directly Related

| # | Title | Venue/Year | Core Contribution | Relevance |
|---|-------|-------------|-------------------|-----------|
| 1 | [title] | [venue], [year] | [1 sentence] | High |

### Tangentially Related

| # | Title | Venue/Year | Core Contribution | Relevance |
|---|-------|-------------|-------------------|-----------|
| 1 | [title] | [venue], [year] | [1 sentence] | Medium |

---

## Structural Gaps & Open Problems

1. [Gap 1]: [why is it a gap? what papers acknowledge it?]
2. [Gap 2]: ...
3. [Gap 3]: ...

---

## Promising Directions

Based on the literature, the most promising research directions are:

1. [Direction 1]: [why promising? which papers point to this?]
2. [Direction 2]: ...
3. [Direction 3]: ...

---

## Local Papers (Already Have)

[Papers found in local `papers/` or `literature/` directories]
```

---

### Step 5.5: Update Research Wiki (Optional)

**Skip entirely if `research-wiki/` directory does not exist.**

If the user has a Research Wiki set up:
1. For each top paper, add an entry to the wiki
2. Link papers by relationship (extends, contradicts, uses-same-method-as)
3. This builds a persistent knowledge graph across sessions

---

## Output Protocols

> Follow these shared protocols for all output files:
> - **[Output Versioning Protocol](../shared-references/output-versioning.md)** — write timestamped file first, then copy to fixed name
> - **[Output Manifest Protocol](../shared-references/output-manifest.md)** — log every output to MANIFEST.md
> - **[Output Language Protocol](../shared-references/output-language.md)** — respect the project's language setting

---

## Key Rules

- **De-duplicate aggressively** — don't analyze the same paper twice
- **Prioritize recent work** (last 2 years) unless foundational
- **Distinguish preprint from published** — note if a paper is under review, accepted, or published
- **Be honest about limitations** — if the literature is sparse, say so; don't fabricate gaps
- **Save everything** — `LITERATURE_SURVEY.md` is the foundation for idea generation in Phase 2
- **Large file handling**: If the Write tool fails due to file size, immediately use Bash (`cat << 'EOF' > file`) to write in chunks. Do NOT ask the user for permission.

---

## Checkpoint: Present to User

After completing the survey, use AskUserQuestion to present a summary:

```
📚 Literature survey complete. Here's what I found:

**Sources consulted**:
- Local PDFs: [N] papers
- arXiv: [N] papers
- Web: [N] papers

**Landscape summary**:
[2-3 sentence summary of the field, main approaches, and open problems]

**Most promising directions**:
1. [Direction 1]
2. [Direction 2]

Does this match your understanding? Should I adjust the scope before generating ideas?
```

**Options**:
- `["Proceed", "Adjust scope", "Regenerate with different focus"]`

- **User approves** (or no response + AUTO_PROCEED=true) → proceed to next phase.
- **User requests changes** (e.g., "focus more on X", "ignore Y") → refine the search with updated queries, re-run relevant parts of Step 2, and present again.
- **User wants different focus** → update the research direction and re-run Step 2 with new queries.
