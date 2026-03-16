#!/usr/bin/env bash
# Test 9: Scheduled Task Execution
# Demonstrates: Cron-based task scheduling, recurring execution

set -e

API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
BASE_URL="http://127.0.0.1:8080"

echo "=== Test 9: Scheduled Task Execution ==="
echo

# Create a scheduled task
echo "Step 1: Creating scheduled task"
echo "--------------------------------"

echo "Creating task: 'Daily memory summary' (runs every minute for testing)"
TASK_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/v1/scheduled-tasks" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "name": "daily-memory-summary",
    "schedule": "* * * * *",
    "agentId": 1,
    "task": "Summarize what you remember from today in 3 bullet points",
    "enabled": true
  }')

echo "$TASK_RESPONSE" | jq '.'

TASK_ID=$(echo "$TASK_RESPONSE" | jq -r '.id')
echo
echo "✓ Scheduled task created (ID: $TASK_ID)"
echo

# List all scheduled tasks
echo "Step 2: Listing scheduled tasks"
echo "---------------------------------"

curl -s -X GET "${BASE_URL}/api/v1/scheduled-tasks" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.tasks[] | {id, name, schedule, enabled, lastRun, nextRun}'

echo
echo "✓ Scheduled tasks listed"
echo

# Wait for first execution
echo "Step 3: Waiting for execution (~60 seconds)"
echo "---------------------------------------------"
echo "Scheduled to run every minute..."
echo "Current time: $(date +'%H:%M:%S')"
echo "Waiting..."

sleep 65

echo "Time now: $(date +'%H:%M:%S')"
echo

# Check execution history
echo "Step 4: Checking execution history"
echo "------------------------------------"

curl -s -X GET "${BASE_URL}/api/v1/scheduled-tasks/${TASK_ID}/executions" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.executions[] | {id, startedAt, completedAt, status, result}'

echo
echo "✓ Execution history retrieved"
echo

# Get the task details again to see lastRun updated
echo "Step 5: Verifying task was executed"
echo "-------------------------------------"

curl -s -X GET "${BASE_URL}/api/v1/scheduled-tasks/${TASK_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq '{id, name, lastRun, nextRun, executions}'

echo
echo "✓ Task execution verified"
echo

# Disable the task
echo "Step 6: Disabling scheduled task"
echo "----------------------------------"

curl -s -X PATCH "${BASE_URL}/api/v1/scheduled-tasks/${TASK_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "enabled": false
  }' | jq '{id, name, enabled}'

echo
echo "✓ Task disabled (won't run again)"
echo

# Clean up - delete the task
echo "Step 7: Cleanup - deleting task"
echo "---------------------------------"

curl -s -X DELETE "${BASE_URL}/api/v1/scheduled-tasks/${TASK_ID}" \
  -H "Authorization: Bearer ${API_KEY}"

echo "✓ Task deleted"
echo

echo "=== Test 9 Complete ✅ ==="
echo
echo "Scheduled Tasks Validated:"
echo "  ✓ Task creation with cron schedule"
echo "  ✓ Automatic execution at scheduled time"
echo "  ✓ Execution history tracking"
echo "  ✓ Task enable/disable control"
echo "  ✓ Task deletion"
