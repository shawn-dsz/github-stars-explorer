# GitHub Stars Explorer - Plan

## What we're building

A bash script that fetches all GitHub starred repositories and saves each one
as a local markdown file. The local files can then be queried by piping them
to any LLM CLI tool (Claude, Codex, Kimi, Gemini, etc.).

---

## Architecture

```
github-stars-explorer/
├── fetch-stars.sh        # the script
├── tasks/
│   └── todo.md           # this file
└── stars/                # generated - one .md file per starred repo
    ├── vercel-next.js.md
    ├── facebook-react.md
    └── ... (~1069 files)
```

---

## The Script: fetch-stars.sh

**Language:** Bash
**Dependency:** `gh` CLI (already installed and authenticated)

### Modes

| Mode | Behaviour |
|------|-----------|
| Default (incremental) | Fetch newest-first, stop when a file already exists |
| `--full` flag | Re-fetch and overwrite all files regardless |

### Logic

1. Create `stars/` directory if it does not exist
2. Call `GET /user/starred?per_page=100&sort=created&direction=desc`
3. For each repo in the response:
   - Generate filename: `{owner}-{reponame}.md`
   - **Incremental mode**: if file exists, stop and exit
   - **Full mode**: always write/overwrite
4. Write markdown file (see format below)
5. Fetch next page, repeat from step 3

### Markdown file format

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

## How to query

No extra tooling needed. Pipe to any LLM CLI:

```bash
# Search with Claude
cat stars/*.md | claude "find me repos related to PDF generation"

# Search with Codex
cat stars/*.md | codex -p "which of these is a CSS animation library?"

# Grep for quick keyword search
grep -l "markdown" stars/*.md
```

---

## What we are NOT building

- No UI
- No database or vector store
- No embeddings or semantic indexing
- No scheduled/automatic refresh
- No separate search binary

---

## Tasks

Tasks are grouped by wave. Within each wave, tasks marked [P] can run in parallel.

---

### Wave 1 — Foundation (sequential, everything depends on this)

- [ ] T01: Create `stars/` directory inside the project
- [ ] T02: Write `fetch-stars.sh` with all of the following:
  - Shebang + usage comment at the top
  - Argument parsing: `--full` flag support
  - `stars/` directory creation if it does not exist
  - Pagination loop using `gh api /user/starred?per_page=100&sort=created&direction=desc`
  - For each repo: generate filename as `{owner}-{reponame}.md`
  - Incremental mode: if file already exists, print "Up to date." and exit
  - Full mode (`--full`): overwrite all files regardless
  - Write markdown file in this exact format:
    ```
    # {name}

    **Owner**: {owner.login}
    **URL**: {html_url}
    **Language**: {language}
    **Stars**: {stargazers_count}
    **Topics**: {topics joined by ", "}

    {description}
    ```
  - Progress output after each page: `Fetched N repos...`
  - Final summary: `Done. N new repos saved to stars/`
- [ ] T03: `chmod +x fetch-stars.sh`
- [ ] T04: Add a `.gitignore` — ignore nothing (stars/ is intentionally tracked), but exclude any OS noise:
  ```
  .DS_Store
  ```

---

### Wave 2 — Verification (can run in parallel once Wave 1 is done)

- [ ] T05 [P]: Dry-run test — run `./fetch-stars.sh` and confirm it paginates and creates files in `stars/`
- [ ] T06 [P]: Spot-check 3 generated files — verify they contain correct owner, URL, language, topics, description
- [ ] T07 [P]: Incremental test — run the script a second time, confirm it exits early with "Up to date."
- [ ] T08 [P]: Full refresh test — run `./fetch-stars.sh --full`, confirm it overwrites without stopping early

---

### Notes for Kimi

- T05, T06, T07, T08 are all read/verify tasks — run them as parallel agents after Wave 1 completes
- T02 is the core task — all logic lives in one file, no external dependencies beyond `gh` CLI
- Do not split T02 across agents; write the whole script in one pass to avoid partial state
