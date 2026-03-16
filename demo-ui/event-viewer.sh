#!/usr/bin/env bash
# Simple event viewer - polls for task execution and displays progress
# This demonstrates event-driven UI without requiring WebSockets

API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
BASE_URL="http://127.0.0.1:8080"
AGENT_ID=${1:-1}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "╔══════════════════════════════════════════════════╗"
echo "║        Bommalata Event Viewer (Agent $AGENT_ID)       ║"
echo "╚══════════════════════════════════════════════════╝"
echo

# Track last seen file ID
LAST_FILE_ID=0

# Get initial file count
INITIAL_COUNT=$(curl -s "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.files | length')

echo "📊 Initial state:"
echo "   Memory files: $INITIAL_COUNT"
echo

echo "👀 Watching for new events... (Ctrl+C to stop)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Poll loop
while true; do
  # Get latest file
  LATEST=$(curl -s "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files" \
    -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0] | "\(.id)|\(.path)|\(.wordCount)|\(.createdAt)"')
  
  if [ "$LATEST" != "null||||" ]; then
    FILE_ID=$(echo "$LATEST" | cut -d'|' -f1)
    FILE_PATH=$(echo "$LATEST" | cut -d'|' -f2)
    WORD_COUNT=$(echo "$LATEST" | cut -d'|' -f3)
    CREATED_AT=$(echo "$LATEST" | cut -d'|' -f4)
    
    # New file detected
    if [ "$FILE_ID" != "$LAST_FILE_ID" ] && [ "$FILE_ID" -gt "$LAST_FILE_ID" ]; then
      TIMESTAMP=$(date +'%H:%M:%S')
      
      echo -e "${GREEN}[$TIMESTAMP] NEW EVENT${NC}"
      echo "   📄 File: $FILE_PATH"
      echo "   📝 Words: $WORD_COUNT"
      echo "   🕐 Created: $(date -d "$CREATED_AT" +'%H:%M:%S' 2>/dev/null || echo $CREATED_AT)"
      
      # Show preview
      CONTENT=$(curl -s "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files/${FILE_ID}" \
        -H "Authorization: Bearer ${API_KEY}" | jq -r '.content')
      
      echo -e "${BLUE}   Preview:${NC}"
      echo "$CONTENT" | head -3 | sed 's/^/     /'
      echo "     ..."
      echo
      
      LAST_FILE_ID=$FILE_ID
    fi
  fi
  
  sleep 2
done
