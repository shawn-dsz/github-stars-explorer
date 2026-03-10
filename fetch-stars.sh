#!/bin/bash
#
# fetch-stars.sh - Fetch GitHub starred repositories and save as markdown files
#
# Usage:
#   ./fetch-stars.sh        # Incremental mode: fetch only new stars
#   ./fetch-stars.sh --full # Full mode: re-fetch and overwrite all files
#
# Dependencies: gh CLI (https://cli.github.com/) must be installed and authenticated

set -e

# Parse arguments
FULL_MODE=false
for arg in "$@"; do
    case $arg in
        --full)
            FULL_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--full]"
            echo "  --full  Re-fetch and overwrite all files regardless"
            exit 0
            ;;
    esac
done

# Create stars/ directory if it doesn't exist
mkdir -p stars

# Initialize counters
PAGE=1
NEW_COUNT=0
UP_TO_DATE=false

# Temp file for tracking
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Pagination loop
while true; do
    # Fetch a page of starred repos (with starred_at timestamp)
    RESPONSE=$(gh api -H "Accept: application/vnd.github.star+json" "/user/starred?per_page=100&sort=created&direction=desc&page=$PAGE" 2>/dev/null) || {
        echo "Error: Failed to fetch from GitHub API. Make sure 'gh' is installed and authenticated."
        exit 1
    }

    # Check if we got any repos
    REPO_COUNT=$(echo "$RESPONSE" | jq 'length')
    if [ "$REPO_COUNT" -eq 0 ]; then
        break
    fi

    # Process each repo
    PAGE_NEW_COUNT=0
    for i in $(seq 0 $((REPO_COUNT - 1))); do
        item=$(echo "$RESPONSE" | jq -c ".[$i]")

        # Extract fields (API returns repo under .repo with star+json header)
        NAME=$(echo "$item" | jq -r '.repo.name')
        OWNER=$(echo "$item" | jq -r '.repo.owner.login')
        HTML_URL=$(echo "$item" | jq -r '.repo.html_url')
        LANGUAGE=$(echo "$item" | jq -r '.repo.language // "N/A"')
        STARGAZERS_COUNT=$(echo "$item" | jq -r '.repo.stargazers_count')
        TOPICS=$(echo "$item" | jq -r '.repo.topics | join(", ")')
        DESCRIPTION=$(echo "$item" | jq -r '.repo.description // ""')
        STARRED_AT=$(echo "$item" | jq -r '.starred_at // ""' | cut -d'T' -f1)

        # Generate filename
        FILENAME="stars/${OWNER}-${NAME}.md"

        # Incremental mode: stop if file exists
        if [ "$FULL_MODE" = false ] && [ -f "$FILENAME" ]; then
            echo "Up to date."
            UP_TO_DATE=true
            break 2
        fi

        # Write markdown file
        cat > "$FILENAME" << EOF
# ${NAME}

**Owner**: ${OWNER}
**URL**: ${HTML_URL}
**Language**: ${LANGUAGE}
**Stars**: ${STARGAZERS_COUNT}
**Starred**: ${STARRED_AT}
**Topics**: ${TOPICS}

${DESCRIPTION}
EOF

        PAGE_NEW_COUNT=$((PAGE_NEW_COUNT + 1))
    done

    NEW_COUNT=$((NEW_COUNT + PAGE_NEW_COUNT))
    echo "Fetched ${NEW_COUNT} repos..."

    # Move to next page
    PAGE=$((PAGE + 1))
done

# Final summary
echo "Done. ${NEW_COUNT} new repos saved to stars/"
