#!/bin/bash
set -e

echo "🚢 Starting Tugboat base preview health check..."
echo "Repository ID: $TUGBOAT_REPO_ID"

# Authenticate with Tugboat
if [ -z "$TUGBOAT_API_TOKEN" ]; then
  echo "❌ Error: TUGBOAT_API_TOKEN environment variable is not set"
  exit 1
fi

if [ -z "$TUGBOAT_REPO_ID" ]; then
  echo "❌ Error: TUGBOAT_REPO_ID environment variable is not set"
  exit 1
fi

# Get all base previews for the repository with anchor=true
echo "📋 Fetching base previews with anchor=true from repository..."

# Use tugboat CLI to get previews - we'll need to parse the JSON output
previews_json=$(tugboat ls previews repo="$TUGBOAT_REPO_ID" --json)

if [ $? -ne 0 ]; then
  echo "❌ Error: Failed to fetch previews from Tugboat API"
  exit 1
fi

echo "🔍 Checking preview states..."

# Use jq to directly find failed base previews
failed_previews_json=$(echo "$previews_json" | jq -c '.[] | select(.anchor == true and (.state == "failed" or (.state == "suspended" and .suspended == "failed"))) | {id: .id, name: .name, state: .state, suspended: .suspended}')

# Check if any failed previews were found
if [ -n "$failed_previews_json" ]; then
  echo ""
  echo "🚨 HEALTH CHECK FAILED!"
  echo "The following base previews are in a failed state:"
  echo "================================================"
  
  # Process and display each failed preview
  echo "$failed_previews_json" | while read -r preview_json; do
    preview_name=$(echo "$preview_json" | jq -r '.name')
    state=$(echo "$preview_json" | jq -r '.state')
    suspended=$(echo "$preview_json" | jq -r '.suspended')
    
    if [ "$state" = "failed" ]; then
      echo "❌ $preview_name (state: failed)"
    elif [ "$state" = "suspended" ] && [ "$suspended" = "failed" ]; then
      echo "❌ $preview_name (suspended due to failure)"
    fi
  done
  
  echo "================================================"
  echo ""
  echo "❌ Pipeline failing due to failed base previews"
  exit 1
else
  echo ""
  echo "✅ All base previews are healthy!"
  echo "🎉 Health check passed successfully"
fi 