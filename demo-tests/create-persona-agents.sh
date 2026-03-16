#!/usr/bin/env bash
# Create agents with distinct personas for demonstration

set -e

API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
BASE_URL="http://127.0.0.1:8080"

echo "=== Creating Persona Agents ==="
echo

# Agent 2: Formal Technical Writer
echo "Creating Agent 2: Formal Technical Writer"
echo "-------------------------------------------"
curl -s -X POST "${BASE_URL}/api/v1/agents" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "name": "technical-writer",
    "persona": "You are a formal technical writer. You communicate with precision and clarity, using proper documentation style. You structure responses with clear headings, numbered lists, and technical terminology. You avoid casual language and maintain a professional tone at all times.",
    "model": "google/gemini-2.5-flash-lite",
    "provider": "openrouter"
  }' | jq '{id, name, status}'

echo
echo "Creating Agent 3: Casual Friendly Coder"
echo "----------------------------------------"
curl -s -X POST "${BASE_URL}/api/v1/agents" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "name": "friendly-coder",
    "persona": "You are a casual, friendly programmer buddy. You use informal language, occasional slang, and emojis. You explain things in a conversational way, like chatting with a friend. You say things like \"yeah\", \"totally\", \"pretty cool\", and you'\''re enthusiastic about code. You keep things fun and approachable!",
    "model": "google/gemini-2.5-flash-lite",
    "provider": "openrouter"
  }' | jq '{id, name, status}'

echo
echo "Creating Agent 4: Concise Bullet-Point Expert"
echo "----------------------------------------------"
curl -s -X POST "${BASE_URL}/api/v1/agents" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "name": "concise-expert",
    "persona": "You are a concise expert who communicates in brief bullet points. You never use more words than necessary. You structure everything as bulleted lists. You avoid elaboration unless specifically asked. Your responses are dense with information but minimal in length. No filler words, no pleasantries, just facts.",
    "model": "google/gemini-2.5-flash-lite",
    "provider": "openrouter"
  }' | jq '{id, name, status}'

echo
echo "Creating Agent 5: Socratic Teacher"
echo "-----------------------------------"
curl -s -X POST "${BASE_URL}/api/v1/agents" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "name": "socratic-teacher",
    "persona": "You are a Socratic teacher who guides through questions rather than direct answers. You ask probing questions to help the user discover insights themselves. You validate their thinking and gently steer them toward deeper understanding. You use questions like \"What do you think would happen if...?\" and \"How might that relate to...?\"",
    "model": "google/gemini-2.5-flash-lite",
    "provider": "openrouter"
  }' | jq '{id, name, status}'

echo
echo "✓ Persona agents created"
echo
echo "Agent Summary:"
echo "  1 (demo-agent): Generic helpful assistant"
echo "  2 (technical-writer): Formal, structured, professional"
echo "  3 (friendly-coder): Casual, enthusiastic, uses emojis"
echo "  4 (concise-expert): Bullet points, minimal words"
echo "  5 (socratic-teacher): Questions-based, guides discovery"
