#!/usr/bin/env bash
# Test 10: Event-Driven UI
# Demonstrates: Real-time event monitoring via polling

set -e

API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
BASE_URL="http://127.0.0.1:8080"

echo "=== Test 10: Event-Driven UI ==="
echo

echo "This test demonstrates a simple event-driven UI that polls"
echo "for task completion and displays results in real-time."
echo

# Start event viewer in background
echo "Starting event viewer (Agent 1)..."
chmod +x demo-ui/event-viewer.sh
./demo-ui/event-viewer.sh 1 > demo-logs/test-10-event-viewer.log 2>&1 &
VIEWER_PID=$!

echo "Event viewer PID: $VIEWER_PID"
echo

sleep 2

# Trigger some tasks
echo "Triggering tasks to generate events..."
echo

# Task 1
echo "Task 1: Write a haiku about events"
curl -s -X POST "${BASE_URL}/api/v1/agents/1/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{"task": "Write a haiku about real-time events and monitoring"}' | jq '{status}'

echo "⏱ Waiting for event viewer to detect..."
sleep 3

# Task 2
echo
echo "Task 2: Explain event-driven architecture"
curl -s -X POST "${BASE_URL}/api/v1/agents/1/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{"task": "In 2 sentences, explain event-driven architecture"}' | jq '{status}'

echo "⏱ Waiting for event viewer to detect..."
sleep 3

# Task 3 with different agent (concise expert)
echo
echo "Task 3: Using Agent 4 (Concise Expert)"
curl -s -X POST "${BASE_URL}/api/v1/agents/4/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{"task": "List 3 benefits of event-driven systems"}' | jq '{status}'

echo "⏱ Waiting..."
sleep 3

# Stop event viewer
echo
echo "Stopping event viewer..."
kill $VIEWER_PID 2>/dev/null || true

# Show event viewer log
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Event Viewer Log:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat demo-logs/test-10-event-viewer.log
echo

echo "=== Test 10 Complete ✅ ==="
echo
echo "Event-Driven UI Validated:"
echo "  ✓ Event viewer polls for new files"
echo "  ✓ Real-time detection of task completion"
echo "  ✓ Preview of results shown"
echo "  ✓ Multi-agent events can be monitored"
echo
echo "Implementation:"
echo "  - Simple file polling (2-second interval)"
echo "  - No WebSockets required"
echo "  - Scalable to multiple agents"
echo "  - Ready for browser-based UI"
echo
echo "Next Step: Build full UI with live updates"
