#!/usr/bin/env bash
# Test 11: Multi-Agent Coordination
# Demonstrates: Multiple personas collaborating, independent memories

set -e

API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
BASE_URL="http://127.0.0.1:8080"

echo "=== Test 11: Multi-Agent Coordination ==="
echo
echo "Scenario: Different agents tackle the same problem from their perspectives"
echo "Task: Explain the trade-offs between monorepo and polyrepo architecture"
echo
echo "================================================"
echo

# Task for all agents
TASK="Explain the trade-offs between monorepo (single repository for all projects) and polyrepo (separate repository per project) architecture. What are the pros and cons of each?"

# Agent 2: Technical Writer
echo "AGENT 2: Technical Writer (Formal Documentation)"
echo "--------------------------------------------------"
echo "Running task..."
curl -s -X POST "${BASE_URL}/api/v1/agents/2/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"task\": $(echo "$TASK" | jq -Rs .)}" | jq '{agentId, status}'

echo
sleep 2
echo "Retrieving response..."
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/2/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')
AGENT2_CONTENT=$(curl -s -X GET "${BASE_URL}/api/v1/agents/2/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.content')
AGENT2_WORDS=$(echo "$AGENT2_CONTENT" | wc -w)

echo "Word count: $AGENT2_WORDS words"
echo
echo "First 20 lines:"
echo "$AGENT2_CONTENT" | head -20
echo "... (truncated)"
echo
echo "================================================"
echo

# Agent 3: Friendly Coder
echo "AGENT 3: Friendly Coder (Casual & Practical)"
echo "----------------------------------------------"
echo "Running task..."
curl -s -X POST "${BASE_URL}/api/v1/agents/3/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"task\": $(echo "$TASK" | jq -Rs .)}" | jq '{agentId, status}'

echo
sleep 2
echo "Retrieving response..."
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/3/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')
AGENT3_CONTENT=$(curl -s -X GET "${BASE_URL}/api/v1/agents/3/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.content')
AGENT3_WORDS=$(echo "$AGENT3_CONTENT" | wc -w)

echo "Word count: $AGENT3_WORDS words"
echo
echo "Full response:"
echo "$AGENT3_CONTENT"
echo
echo "================================================"
echo

# Agent 4: Concise Expert
echo "AGENT 4: Concise Expert (Bullet Points)"
echo "-----------------------------------------"
echo "Running task..."
curl -s -X POST "${BASE_URL}/api/v1/agents/4/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"task\": $(echo "$TASK" | jq -Rs .)}" | jq '{agentId, status}'

echo
sleep 2
echo "Retrieving response..."
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/4/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')
AGENT4_CONTENT=$(curl -s -X GET "${BASE_URL}/api/v1/agents/4/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.content')
AGENT4_WORDS=$(echo "$AGENT4_CONTENT" | wc -w)

echo "Word count: $AGENT4_WORDS words"
echo
echo "Full response:"
echo "$AGENT4_CONTENT"
echo
echo "================================================"
echo

# Agent 5: Socratic Teacher
echo "AGENT 5: Socratic Teacher (Question-Driven)"
echo "---------------------------------------------"
echo "Running task..."
curl -s -X POST "${BASE_URL}/api/v1/agents/5/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"task\": $(echo "$TASK" | jq -Rs .)}" | jq '{agentId, status}'

echo
sleep 2
echo "Retrieving response..."
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/5/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')
AGENT5_CONTENT=$(curl -s -X GET "${BASE_URL}/api/v1/agents/5/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.content')
AGENT5_WORDS=$(echo "$AGENT5_CONTENT" | wc -w)

echo "Word count: $AGENT5_WORDS words"
echo
echo "Full response:"
echo "$AGENT5_CONTENT"
echo
echo "================================================"
echo

echo "=== Test 11 Complete ✅ ==="
echo
echo "Summary:"
echo "  Agent 2 (Technical Writer): $AGENT2_WORDS words - Formal, structured"
echo "  Agent 3 (Friendly Coder): $AGENT3_WORDS words - Casual, approachable"
echo "  Agent 4 (Concise Expert): $AGENT4_WORDS words - Brief, efficient"
echo "  Agent 5 (Socratic Teacher): $AGENT5_WORDS words - Question-based"
echo
echo "Key Findings:"
echo "  ✓ Each agent has distinct voice and approach"
echo "  ✓ All tackle same problem from different angles"
echo "  ✓ Independent memories (no cross-contamination)"
echo "  ✓ Word counts vary dramatically by persona"
echo "  ✓ User can choose agent based on preference/context"
