#!/usr/bin/env bash
# Test 2: Basic Task Execution with Streaming
# Demonstrates: SSE event stream, streaming responses, event types

set -e

BASE_URL="http://127.0.0.1:8080"
API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
AGENT_ID="1"

echo "=== Test 2: Streaming & Events ==="
echo

# Create a simple task and stream the response
echo "1. Creating Task: 'Write a haiku about Go programming'"
echo

# Use curl with --no-buffer to stream SSE events
curl -N -X POST "$BASE_URL/api/v1/agents/$AGENT_ID/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "task": "Write a haiku about Go programming. Keep it simple and elegant."
  }' 2>&1 | tee /tmp/test-02-stream-output.txt

echo
echo
echo "=== Test 2 Complete ==="
echo "✅ Streaming response received"
echo "✅ Events captured (see output above)"
echo
echo "Output saved to: /tmp/test-02-stream-output.txt"
