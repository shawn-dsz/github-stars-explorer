# Architecture: GitHub Stars Explorer

## Overview

A single bash script that syncs your GitHub starred repositories to local
markdown files. Each repo becomes one `.md` file. You query them by piping
to any LLM CLI tool.

---

## Components

```
github-stars-explorer/
├── fetch-stars.sh        # Sync script (the only component)
├── docs/
│   └── ARCHITECTURE.md   # This file
├── tasks/
│   └── todo.md           # Build plan and task tracking
└── stars/                # Generated output (git-ignored)
    ├── vercel-next.js.md
    ├── facebook-react.md
    └── ...
```

---

## Data Flow

```
GitHub API (/user/starred)
        │
        │  gh api (authenticated, paginated)
        ▼
fetch-stars.sh
        │
        │  writes one file per repo
        ▼
stars/{owner}-{repo}.md  ×1069
        │
        │  cat stars/*.md | claude "..."
        ▼
LLM CLI (Claude / Codex / Kimi / Gemini)
        │
        ▼
Answer in terminal
```

---

## Sync Modes

| Mode | Trigger | Behaviour |
|------|---------|-----------|
| Incremental (default) | `./fetch-stars.sh` | Fetches newest-first, stops when an existing file is encountered |
| Full refresh | `./fetch-stars.sh --full` | Re-fetches and overwrites all files |

The incremental mode works because the API returns stars sorted by `starred_at`
descending. The moment we encounter a repo whose file already exists, we know
all subsequent results are already cached.

---

## API Details

- **Endpoint**: `GET /user/starred?per_page=100&sort=created&direction=desc`
- **Auth**: via `gh` CLI (OAuth token, no manual token management)
- **Rate limit**: 5000 requests/hr (authenticated) — well within budget for ~11 pages
- **Pagination**: Link header (`rel="next"`) or `gh api --paginate`
- **Your star count**: ~1069 repos (~11 pages at 100 per page)

---

## Markdown File Format

**Filename:** `{owner}-{reponame}.md`

```markdown
# {repo name}

**Owner**: {owner}
**URL**: https://github.com/{owner}/{repo}
**Language**: {language}
**Stars**: {stargazers_count}
**Topics**: {comma-separated topics}

{description}
```

---

## Query Pattern

No additional tooling required. Examples:

```bash
# Semantic search via LLM
cat stars/*.md | claude "find me repos related to PDF generation"

# Keyword search
grep -ril "animation" stars/

# Count by language
grep -h "^\*\*Language\*\*" stars/*.md | sort | uniq -c | sort -rn
```

---

## Technology Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Language | Bash | No dependencies beyond `gh` CLI |
| Auth | `gh` CLI | Already installed, already authenticated |
| Storage | Markdown files | Human-readable, grep-able, LLM-friendly |
| Search | LLM CLI (external) | Zero extra code, works with any model |
| Pagination | Newest-first + stop | Enables fast incremental syncs |

---

## What This Deliberately Excludes

- No UI (CLI piping is sufficient)
- No database or vector store
- No embeddings or semantic indexing
- No scheduled refresh (run manually when needed)
- No separate search binary

---

## Decisions Log

A record of choices made and the reasoning behind them.

| Decision | Options Considered | Choice Made | Reason |
|----------|--------------------|-------------|--------|
| UI vs CLI | Web UI, CLI | CLI | Simpler; piping to LLM CLI is sufficient and requires no extra code |
| Live API vs local cache | Query API on every search, local markdown files | Local files | 1069 stars = large context on every query; local is instant and works offline |
| Blurb generation | LLM-generated summaries, GitHub description | GitHub description | No API cost; descriptions are sufficient for search |
| Search mechanism | Fuzzy text matching, LLM semantic search, embeddings | LLM CLI (external) | Zero extra code; user already has multiple LLM CLIs installed |
| Refresh strategy | Fetch all every time, incremental (stop on known file), date-based | Incremental stop | Fast; no dates needed; works naturally with newest-first sort order |
| Script language | Node.js, Python, Bash | Bash | No dependencies; `gh` CLI already handles auth and pagination |
| Auth method | Personal access token, `gh` CLI OAuth | `gh` CLI | Already installed and authenticated; no token management needed |
| One file per repo vs single file | Single combined file, one file per repo | One file per repo | Easy to check existence for incremental sync; grep-able individually |

## Change Log

| Date | Change |
|------|--------|
| 2026-03-10 | Initial architecture defined, all key decisions captured |
