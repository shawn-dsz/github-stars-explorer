# GitHub Stars Explorer

Search your GitHub stars using any LLM.

## How it works

1. `fetch-stars.sh` pulls all your starred repos from GitHub and saves each as a local markdown file
2. `search-stars` pipes those files to an LLM with your query and returns the top matches

**Important:** This is not a chatbot. You run `search-stars` from your terminal. Do not ask an AI agent "find me a tool" - run the script instead.

## Setup

Requires the [GitHub CLI](https://cli.github.com/) and `jq`:

```bash
brew install gh jq
gh auth login
```

## Step 1: Sync your stars

```bash
# First run — fetches everything (~1070 repos)
./fetch-stars.sh

# Subsequent runs — only fetches new stars since last sync
./fetch-stars.sh

# Force a full refresh (updates descriptions, star counts, topics)
./fetch-stars.sh --full
```

## Step 2: Search

```bash
./search-stars "find me a tool for planning AI agent work"
./search-stars "CSS animation library"
./search-stars "markdown to PDF converter"
```

Use a different model with `--model`:

```bash
./search-stars --model codex "websocket library for Node"
./search-stars --model kimi "Rust CLI tools"
./search-stars --model gemini "machine learning explainability"
```

Or pipe manually for full control:

```bash
cat stars/*.md | claude "find me a good state machine library"
grep -ril "websocket" stars/
```

## What each star file looks like

```markdown
# react

**Owner**: facebook
**URL**: https://github.com/facebook/react
**Language**: JavaScript
**Stars**: 243865
**Topics**: declarative, frontend, javascript, library, react, ui

The library for web and native user interfaces.
```
