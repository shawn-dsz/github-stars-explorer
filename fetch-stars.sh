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
    # Fetch a page of starred repos
    RESPONSE=$(gh api "/user/starred?per_page=100&sort=created&direction=desc&page=$PAGE" 2>/dev/null) || {
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
        repo=$(echo "$RESPONSE" | jq -c ".[$i]")

        # Extract fields
        NAME=$(echo "$repo" | jq -r '.name')
        OWNER=$(echo "$repo" | jq -r '.owner.login')
        HTML_URL=$(echo "$repo" | jq -r '.html_url')
        LANGUAGE=$(echo "$repo" | jq -r '.language // "N/A"')
        STARGAZERS_COUNT=$(echo "$repo" | jq -r '.stargazers_count')
        TOPICS=$(echo "$repo" | jq -r '.topics | join(", ")')
        DESCRIPTION=$(echo "$repo" | jq -r '.description // ""')

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
