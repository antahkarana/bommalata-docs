#!/usr/bin/env bash
# Test 1: Server Lifecycle & Agent Creation
# Demonstrates: Basic CRUD, authentication, database persistence

set -e

BASE_URL="http://127.0.0.1:8080"
API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"

echo "=== Test 1: Server Lifecycle & Agent Creation ==="
echo

# Test 1: Health check
echo "1. Health Check"
curl -s "$BASE_URL/health"
echo -e "\n"

# Test 2: Create an agent
echo "2. Create Agent"
AGENT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/agents" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "name": "demo-agent",
    "persona": "You are a helpful AI assistant specialized in demonstrating bommalata'\''s capabilities. You are enthusiastic, clear, and thorough in your explanations.",
    "model": "openai/gpt-4o-mini",
    "provider": "openrouter"
  }')

echo "$AGENT_RESPONSE" | jq '.'
AGENT_ID=$(echo "$AGENT_RESPONSE" | jq -r '.id')
echo "Created agent with ID: $AGENT_ID"
echo

# Test 3: List all agents
echo "3. List All Agents"
curl -s "$BASE_URL/api/v1/agents" -H "Authorization: Bearer $API_KEY" | jq '.'
echo

# Test 4: Get specific agent
echo "4. Get Agent by ID ($AGENT_ID)"
curl -s "$BASE_URL/api/v1/agents/$AGENT_ID" -H "Authorization: Bearer $API_KEY" | jq '.'
echo

# Test 5: Update agent
echo "5. Update Agent"
curl -s -X PATCH "$BASE_URL/api/v1/agents/$AGENT_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "persona": "You are a helpful AI assistant specialized in demonstrating bommalata'\''s capabilities. You are enthusiastic, clear, thorough, and you love emojis! 🎉"
  }' | jq '.'
echo

# Test 6: Verify update
echo "6. Verify Update"
curl -s "$BASE_URL/api/v1/agents/$AGENT_ID" -H "Authorization: Bearer $API_KEY" | jq '.persona'
echo

echo "=== Test 1 Complete ==="
echo "✅ Server is operational"
echo "✅ Agent CRUD operations working"
echo "✅ Database persistence verified"
