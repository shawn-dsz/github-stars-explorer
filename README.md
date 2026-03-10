# GitHub Stars Explorer

Search your GitHub stars using any LLM CLI tool.

## How it works

Fetches all your starred repos from GitHub and saves each one as a local markdown file. You then pipe those files to whichever LLM you have handy to find what you're looking for.

```
stars/
├── vercel-next.js.md
├── facebook-react.md
└── ... (~1070 files)
```

## Setup

Requires the [GitHub CLI](https://cli.github.com/) and `jq`:

```bash
brew install gh jq
gh auth login
```

## Sync your stars

```bash
# First run — fetches everything
./fetch-stars.sh

# Subsequent runs — only fetches new stars since last sync
./fetch-stars.sh

# Force a full refresh (updates descriptions, star counts, topics)
./fetch-stars.sh --full
```

## Search

Pipe the files to any LLM CLI:

```bash
cat stars/*.md | claude "find me a good markdown to PDF converter"
cat stars/*.md | codex -p "which of these is a CSS animation library?"
cat stars/*.md | kimi -p "find tools for scraping websites"
cat stars/*.md | gemini "find me Rust CLI tools"
```

Or use grep for quick keyword lookups:

```bash
grep -ril "websocket" stars/
grep -ril "rust" stars/
```

## What each file looks like

```markdown
# react

**Owner**: facebook
**URL**: https://github.com/facebook/react
**Language**: JavaScript
**Stars**: 243865
**Topics**: declarative, frontend, javascript, library, react, ui

The library for web and native user interfaces.
```
