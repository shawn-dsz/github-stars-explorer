#!/bin/bash
#
# add-star.sh - Add a GitHub repository to stars locally and on GitHub
#
# Usage:
#   ./add-star.sh https://github.com/owner/repo
#   ./add-star.sh owner/repo
#
# Dependencies: gh CLI must be installed and authenticated

set -euo pipefail

# Parse input
INPUT="${1:-}"

if [[ -z "$INPUT" ]]; then
    echo "Usage: $0 <github-url-or-repo>"
    echo "Examples:"
    echo "  $0 https://github.com/owner/repo"
    echo "  $0 owner/repo"
    exit 1
fi

# Extract owner and repo from input
if [[ "$INPUT" =~ ^https://github.com/([^/]+)/([^/]+)/?$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
elif [[ "$INPUT" =~ ^([^/]+)/([^/]+)$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
else
    echo "Error: Invalid input format. Use 'owner/repo' or a GitHub URL."
    exit 1
fi

# Remove .git suffix if present
REPO="${REPO%.git}"

echo "Adding ${OWNER}/${REPO}..."

# Check if already starred locally
FILENAME="stars/${OWNER}-${REPO}.md"
if [[ -f "$FILENAME" ]]; then
    echo "Already starred locally: ${FILENAME}"
    exit 0
fi

# Star on GitHub
echo "Starring on GitHub..."
if ! gh api --method PUT "/user/starred/${OWNER}/${REPO}" 2>/dev/null; then
    echo "Error: Failed to star on GitHub. Make sure 'gh' is installed and authenticated."
    exit 1
fi

# Fetch repo details
echo "Fetching repository details..."
REPO_DATA=$(gh api "/repos/${OWNER}/${REPO}" 2>/dev/null) || {
    echo "Error: Failed to fetch repository details."
    exit 1
}

# Extract fields
NAME=$(echo "$REPO_DATA" | jq -r '.name')
HTML_URL=$(echo "$REPO_DATA" | jq -r '.html_url')
LANGUAGE=$(echo "$REPO_DATA" | jq -r '.language // "N/A"')
STARGAZERS_COUNT=$(echo "$REPO_DATA" | jq -r '.stargazers_count')
TOPICS=$(echo "$REPO_DATA" | jq -r '.topics | join(", ")')
DESCRIPTION=$(echo "$REPO_DATA" | jq -r '.description // ""')
TODAY=$(date +%Y-%m-%d)

# Create stars directory if needed
mkdir -p stars

# Write markdown file
cat > "$FILENAME" << EOF
# ${NAME}

**Owner**: ${OWNER}
**URL**: ${HTML_URL}
**Language**: ${LANGUAGE}
**Stars**: ${STARGAZERS_COUNT}
**Starred**: ${TODAY}
**Topics**: ${TOPICS}

${DESCRIPTION}
EOF

echo "Done! Starred ${OWNER}/${REPO} and saved to ${FILENAME}"
