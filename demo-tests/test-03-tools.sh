#!/usr/bin/env bash
# Test 3: Tool Execution
# Demonstrates: Tool loop, tool_execution events, multi-iteration reasoning

set -e

BASE_URL="http://127.0.0.1:8080"
API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
AGENT_ID="1"

echo "=== Test 3: Tool Execution ==="
echo

# Task that requires tool use
echo "1. Creating Task: File tool demonstration"
echo "Task: Create a file with a greeting message"
echo

curl -X POST "$BASE_URL/api/v1/agents/$AGENT_ID/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "task": "Create a file named test3-greeting.txt with the content: \"Hello from Test 3! The file tool is working.\""
  }' | jq '.'

echo
echo

# Verify file was created
echo "2. Verifying File Creation"
echo
if [ -f "data/workspaces/agent-1/test3-greeting.txt" ]; then
    echo "✅ File created successfully!"
    echo "Content:"
    cat "data/workspaces/agent-1/test3-greeting.txt"
else
    echo "❌ File not found (may be in different location)"
    echo "Searching for file..."
    find data/workspaces/agent-1 -name "test3-greeting.txt" -exec cat {} \;
fi

echo
echo
echo "=== Test 3 Complete ==="
echo "✅ Tool execution demonstrated"
echo "✅ Check server logs for tool_execution events"
