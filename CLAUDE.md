# GitHub Stars Explorer

## What this is

A single bash script that syncs all GitHub starred repositories to local markdown files.
One file per repo. Query them by piping to any LLM CLI tool.

## Usage

```bash
# First run (fetches all ~1070 stars)
./fetch-stars.sh

# Incremental update (stops when it hits a repo already cached)
./fetch-stars.sh

# Full refresh (re-fetches everything, updates descriptions/star counts)
./fetch-stars.sh --full
```

## Querying

```bash
# Semantic search via Claude
cat stars/*.md | claude "find me repos related to PDF generation"

# Semantic search via Codex
cat stars/*.md | codex -p "which of these is a CSS animation library?"

# Semantic search via Kimi
cat stars/*.md | kimi -p "find tools for scraping websites"

# Quick keyword search (no LLM needed)
grep -ril "websocket" stars/

# Count stars by language
grep -h "^\*\*Language\*\*" stars/*.md | sort | uniq -c | sort -rn
```

## File format

Each file in `stars/` follows this structure:

```
stars/{owner}-{reponame}.md
```

```markdown
# {repo name}

**Owner**: {owner}
**URL**: https://github.com/{owner}/{repo}
**Language**: {language}
**Stars**: {stargazers_count}
**Topics**: {comma-separated topics}

{description}
```

## Dependencies

- `gh` CLI — must be installed and authenticated (`gh auth login`)
- `jq` — used for JSON parsing in the script

## Architecture

See `docs/ARCHITECTURE.md` for full design decisions and rationale.

## What this does NOT do

- No UI
- No database or vector store
- No automatic refresh (run the script manually when needed)
- No LLM-generated summaries (uses GitHub descriptions as-is)
