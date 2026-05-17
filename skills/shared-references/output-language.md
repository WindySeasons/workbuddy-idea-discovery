# Output Language Protocol (WorkBuddy Port)

## Language Detection

Determine the output language using this priority:
1. If the user's most recent message is in Chinese, output in Chinese
2. Default: English

## What to Localize

- Section headings and labels
- Descriptions, analysis, commentary, recommendations
- Template boilerplate text
- Status messages and warnings

## What NOT to Localize

- Code, shell commands, file paths, directory names
- Paper titles, author names, venue names, BibTeX entries
- Technical terms with no standard Chinese translation (keep English, optionally annotate)
- JSON state files — keys and structure remain English
- **Machine-parsed markers** — never localize:
  - Markdown frontmatter keys
  - `MANIFEST.md` column headers and table structure
  - Any field that downstream tools or scripts read programmatically

## Skill-Specific Rules

| Skill | Language Support | Notes |
|-------|-----------------|-------|
| idea-creator | Full | IDEA_REPORT.md follows language setting |
| idea-discovery | Full | Inherits from sub-skills |
| experiment-plan | Full | EXPERIMENT_PLAN.md follows setting |
| research-refine | Full | FINAL_PROPOSAL.md follows setting |
| novelty-check | Full | NOVELTY_CHECK report follows setting |
| research-review | Full | REVIEW report follows setting |
