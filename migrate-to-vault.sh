#!/usr/bin/env bash
# migrate-to-vault.sh
# Converts all stars/*.md files into vault Weblink notes under
# Resources/Weblinks/Tech/GitHub-Stars/

STARS_DIR="/Users/shawn/proj/github-stars-explorer/stars"
VAULT_DIR="/Users/shawn/Documents/Obsidian Vault/Resources/Weblinks/Tech/GitHub-Stars"

count=0

for src in "$STARS_DIR"/*.md; do
  filename=$(basename "$src")
  dest="$VAULT_DIR/$filename"

  # Parse fields from the star file
  repo_name=$(awk 'NR==1{sub(/^# /,""); print}' "$src")
  owner=$(grep '^\*\*Owner\*\*' "$src" | sed 's/\*\*Owner\*\*: //')
  url=$(grep '^\*\*URL\*\*' "$src" | sed 's/\*\*URL\*\*: //')
  language=$(grep '^\*\*Language\*\*' "$src" | sed 's/\*\*Language\*\*: //')
  stars=$(grep '^\*\*Stars\*\*' "$src" | sed 's/\*\*Stars\*\*: //')
  starred=$(grep '^\*\*Starred\*\*' "$src" | sed 's/\*\*Starred\*\*: //')
  topics=$(grep '^\*\*Topics\*\*' "$src" | sed 's/\*\*Topics\*\*: //')

  # Description: first non-empty line after the Topics line
  description=$(awk '/^\*\*Topics\*\*/{found=1; next} found && /^$/{skip=1; next} skip && NF{print; exit}' "$src")
  # Fallback: if no topics line, get description after Starred line
  if [ -z "$description" ]; then
    description=$(awk '/^\*\*Starred\*\*/{found=1; next} found && /^$/{skip=1; next} skip && NF{print; exit}' "$src")
  fi

  # Sanitize description for YAML (escape quotes, strip leading/trailing whitespace)
  description=$(echo "$description" | sed "s/'/\\'\\'/g" | xargs)

  # Language tag (lowercase, hyphenated)
  lang_tag=""
  if [ -n "$language" ] && [ "$language" != "N/A" ] && [ "$language" != "null" ]; then
    lang_lower=$(echo "$language" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    lang_tag="  - $lang_lower"$'\n'
  fi

  # Convert comma-separated topics into yaml list items
  topic_tags=""
  if [ -n "$topics" ]; then
    IFS=',' read -ra tlist <<< "$topics"
    for t in "${tlist[@]}"; do
      t=$(echo "$t" | xargs) # trim whitespace
      [ -n "$t" ] && topic_tags="${topic_tags}  - ${t}"$'\n'
    done
  fi

  cat > "$dest" <<FRONTMATTER
---
type: Weblink
title: "$owner/$repo_name"
description: "$description"
url: $url
date: $starred
tags:
  - github-star
${lang_tag}${topic_tags}---

# $owner/$repo_name

**Owner**: $owner
**Language**: $language
**Stars**: $stars
**Starred**: $starred
**Topics**: $topics

$description
FRONTMATTER

  count=$((count + 1))
done

echo "Done. Migrated $count repos."
