# GitHub Stars Explorer

<p align="center">
  <b>Find the needle in your GitHub stars haystack</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/AI-LLM_Powered-FF6F61?logo=openai&logoColor=white" alt="LLM Powered">
  <img src="https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-000000?logo=apple&logoColor=white" alt="Platform">
</p>

---

## The Problem

You have hundreds (or thousands) of starred repositories on GitHub. You remember starring that perfect tool last month, but good luck finding it again.

GitHub's built-in search is limited. Your stars are a graveyard of forgotten gems.

## The Solution

GitHub Stars Explorer lets you **search your stars with natural language** using any LLM you prefer. No more scrolling through pages of stars or trying to remember exact repository names.

```bash
$ ./search-stars "find me a tool for planning AI agent work"

| repo-name        | brief description                | stars | key tags                    |
|------------------|----------------------------------|-------|-----------------------------|
| gsd              | Goal-oriented project management | 1.2k  | ai, agents, planning        |
| claude-task-master | Task management for Claude     | 890   | claude, ai, workflow        |
| supercog         | AI agent orchestration           | 2.1k  | agents, llm, automation     |
```

---

## Use Cases

| Scenario | Example Query |
|----------|---------------|
| **Finding tools by purpose** | `"CLI tool for JSON processing"` |
| **Discovering libraries** | `"React component library for charts"` |
| **Learning resources** | `"Rust tutorial for beginners"` |
| **Specific tech stack** | `"Python async web framework"` |
| **Problem solving** | `"fix my git history"` |
| **Exploring topics** | `"machine learning explainability"` |

---

## How It Works

1. **Fetch** — `fetch-stars.sh` pulls all your starred repos from GitHub and saves each as a local markdown file
2. **Search** — `search-stars` pipes those files to an LLM with your natural language query
3. **Results** — Get a ranked table of the most relevant matches

> **Important:** This is not a chatbot. You run `search-stars` from your terminal. Do not ask an AI agent "find me a tool" — run the script instead.

---

## Quick Start

### Prerequisites

Requires the [GitHub CLI](https://cli.github.com/) and `jq`:

```bash
brew install gh jq
gh auth login
```

### Step 1: Sync Your Stars

```bash
# First run — fetches everything (~1070 repos)
./fetch-stars.sh

# Subsequent runs — only fetches new stars since last sync
./fetch-stars.sh

# Force a full refresh (updates descriptions, star counts, topics)
./fetch-stars.sh --full
```

### Step 2: Search

```bash
./search-stars "find me a tool for planning AI agent work"
./search-stars "CSS animation library"
./search-stars "markdown to PDF converter"
```

### Choose Your AI Model

Use `--model` to switch between LLM providers:

```bash
./search-stars --model claude "websocket library for Node"   # Default
./search-stars --model codex "Rust CLI tools"                 # OpenAI Codex
./search-stars --model kimi "Python data validation"          # Moonshot Kimi
./search-stars --model gemini "machine learning explainability"  # Google Gemini
```

### Manual Control

For power users who want full control:

```bash
# Pipe directly to your LLM
cat stars/*.md | claude "find me a good state machine library"

# Or use grep for simple text search
grep -ril "websocket" stars/
```

---

## Data Format

Each starred repository is saved as a markdown file with structured metadata:

```markdown
# react

**Owner**: facebook
**URL**: https://github.com/facebook/react
**Language**: JavaScript
**Stars**: 243865
**Topics**: declarative, frontend, javascript, library, react, ui

The library for web and native user interfaces.
```

This format is both human-readable and LLM-friendly, giving the AI rich context about each repository.

---

## Why This Approach?

| Approach | Pros | Cons |
|----------|------|------|
| **GitHub's native search** | Fast, official | Limited to exact matches, no semantic understanding |
| **Third-party star managers** | Nice UI, web-based | Requires account, may not respect privacy |
| **GitHub Stars Explorer** | Private (local), semantic search, works offline, choose your LLM | Requires initial sync, terminal-based |

Your stars stay on your machine. No external service gets access to your GitHub data.

---

## Tips for Better Searches

- **Be specific:** `"React table library with sorting"` beats `"table"`
- **Mention use case:** `"tool for cleaning up git branches"` works better than `"git tool"`
- **Include tech stack:** `"Python async web framework"` narrows results effectively
- **Try synonyms:** If "authentication" does not work, try "auth" or "login"

---

## Requirements

- Bash 4.0+
- [GitHub CLI](https://cli.github.com/) (`gh`) — authenticated
- `jq` — JSON processor
- At least one LLM CLI tool: [Claude Code](https://claude.ai/code), [Codex](https://github.com/openai/codex), [Kimi](https://github.com/MoonshotAI/kimi-cli), or [Gemini CLI](https://github.com/google-gemini/gemini-cli)

---

## License

MIT
