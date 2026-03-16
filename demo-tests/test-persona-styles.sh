#!/usr/bin/env bash
# Test: Persona Impact Demonstration
# Shows how different personas respond to the same question

set -e

API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
BASE_URL="http://127.0.0.1:8080"

QUESTION="Explain how binary search works"

echo "=== Persona Impact Demonstration ==="
echo
echo "Same Question to All Agents:"
echo "\"${QUESTION}\""
echo
echo "================================================"
echo

# Agent 1: Generic (baseline)
echo "AGENT 1: Generic Helper (Baseline)"
echo "-----------------------------------"
RESPONSE_1=$(curl -s -X POST "${BASE_URL}/api/v1/agents/1/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"task\": \"${QUESTION}\"}")
echo "Status: $(echo "$RESPONSE_1" | jq -r '.status')"
echo
echo "Retrieving response..."
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/1/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')
curl -s -X GET "${BASE_URL}/api/v1/agents/1/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.content' | head -15
echo "... (truncated)"
echo
echo "================================================"
echo

# Agent 2: Technical Writer
echo "AGENT 2: Formal Technical Writer"
echo "----------------------------------"
RESPONSE_2=$(curl -s -X POST "${BASE_URL}/api/v1/agents/2/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"task\": \"${QUESTION}\"}")
echo "Status: $(echo "$RESPONSE_2" | jq -r '.status')"
echo
echo "Retrieving response..."
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/2/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')
curl -s -X GET "${BASE_URL}/api/v1/agents/2/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.content' | head -15
echo "... (truncated)"
echo
echo "================================================"
echo

# Agent 3: Friendly Coder
echo "AGENT 3: Casual Friendly Coder"
echo "--------------------------------"
RESPONSE_3=$(curl -s -X POST "${BASE_URL}/api/v1/agents/3/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"task\": \"${QUESTION}\"}")
echo "Status: $(echo "$RESPONSE_3" | jq -r '.status')"
echo
echo "Retrieving response..."
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/3/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')
curl -s -X GET "${BASE_URL}/api/v1/agents/3/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.content' | head -15
echo "... (truncated)"
echo
echo "================================================"
echo

# Agent 4: Concise Expert
echo "AGENT 4: Concise Bullet-Point Expert"
echo "--------------------------------------"
RESPONSE_4=$(curl -s -X POST "${BASE_URL}/api/v1/agents/4/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"task\": \"${QUESTION}\"}")
echo "Status: $(echo "$RESPONSE_4" | jq -r '.status')"
echo
echo "Retrieving response..."
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/4/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')
curl -s -X GET "${BASE_URL}/api/v1/agents/4/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.content' | head -15
echo "... (truncated)"
echo
echo "================================================"
echo

# Agent 5: Socratic Teacher
echo "AGENT 5: Socratic Teacher"
echo "--------------------------"
RESPONSE_5=$(curl -s -X POST "${BASE_URL}/api/v1/agents/5/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"task\": \"${QUESTION}\"}")
echo "Status: $(echo "$RESPONSE_5" | jq -r '.status')"
echo
echo "Retrieving response..."
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/5/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')
curl -s -X GET "${BASE_URL}/api/v1/agents/5/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.content' | head -15
echo "... (truncated)"
echo
echo "================================================"
echo
echo "✅ Persona Impact Demonstrated"
echo
echo "Key Differences Observed:"
echo "  - Agent 1: Balanced, informative"
echo "  - Agent 2: Formal structure, technical precision"
echo "  - Agent 3: Casual tone, friendly language"
echo "  - Agent 4: Minimal words, bullet format"
echo "  - Agent 5: Question-driven, guides thinking"
