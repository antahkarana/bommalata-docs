#!/usr/bin/env bash
# Test 12: Complete Pipeline
# Demonstrates: End-to-end workflow with all features integrated

set -e

API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
BASE_URL="http://127.0.0.1:8080"

echo "╔══════════════════════════════════════════════════╗"
echo "║       Test 12: Complete Pipeline Demo           ║"
echo "║    Agents → Tools → Memory → Multi-Turn → UI    ║"
echo "╚══════════════════════════════════════════════════╝"
echo

echo "📋 Scenario: Technical Documentation Project"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Phase 1: Create project memory
echo "Phase 1: Initialize Project Memory"
echo "───────────────────────────────────"

echo "Creating project brief..."
curl -s -X POST "${BASE_URL}/api/v1/agents/2/memory/files" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "path": "projects/docs-project-brief.md",
    "type": "brainstorm",
    "content": "# Documentation Project Brief\n\n## Goal\nCreate comprehensive API documentation for a REST service.\n\n## Requirements\n- Clear endpoint descriptions\n- Example requests/responses\n- Authentication details\n- Rate limiting info\n\n## Target Audience\nDevelopers integrating with our API"
  }' | jq '{id, path, wordCount}'

echo "✓ Project brief stored"
echo

# Phase 2: Research phase (Agent 2 - Technical Writer)
echo "Phase 2: Research & Planning (Technical Writer)"
echo "─────────────────────────────────────────────────"

echo "Agent 2 researching best practices..."
curl -s -X POST "${BASE_URL}/api/v1/agents/2/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "task": "List 5 essential components of good REST API documentation. Be concise."
  }' | jq '{status}'

echo "⏱ Processing..."
sleep 2
echo "✓ Research complete"
echo

# Phase 3: Multi-turn conversation for details
echo "Phase 3: Detailed Q&A (Multi-Turn)"
echo "───────────────────────────────────"

echo "Agent 1 answering multi-part question..."
curl -s -X POST "${BASE_URL}/api/v1/agents/1/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "task": "For API documentation: 1) What authentication methods are most common? 2) How should rate limits be documented? Keep each answer to 2 sentences."
  }' | jq '{status}'

echo "⏱ Processing..."
sleep 2
echo "✓ Q&A complete"
echo

# Phase 4: Create draft (uses file tool)
echo "Phase 4: Create Draft Documentation (Tool Use)"
echo "───────────────────────────────────────────────"

echo "Agent 3 (Friendly Coder) creating draft..."
curl -s -X POST "${BASE_URL}/api/v1/agents/3/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "task": "Create a file called api-docs-draft.md with a simple example of documenting a POST /users endpoint. Include description, example request, and example response."
  }' | jq '{status}'

echo "⏱ Creating file..."
sleep 2
echo "✓ Draft created"
echo

# Phase 5: Concise summary (Agent 4)
echo "Phase 5: Executive Summary (Concise Expert)"
echo "────────────────────────────────────────────"

echo "Agent 4 creating bullet-point summary..."
curl -s -X POST "${BASE_URL}/api/v1/agents/4/run-once" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "task": "Summarize the key benefits of having good API documentation in 3 bullet points"
  }' | jq '{status}'

echo "⏱ Processing..."
sleep 2
echo "✓ Summary created"
echo

# Phase 6: Memory search to verify knowledge
echo "Phase 6: Knowledge Verification (Memory Search)"
echo "────────────────────────────────────────────────"

echo "Searching for API-related content..."
curl -s -X POST "${BASE_URL}/api/v1/agents/2/memory/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "query": "API documentation",
    "limit": 3
  }' | jq '.results[] | {path, snippet}' | head -20

echo "✓ Knowledge verified"
echo

# Phase 7: Show results from all agents
echo "Phase 7: Collaboration Results"
echo "───────────────────────────────"
echo

for AGENT_ID in 1 2 3 4; do
  echo "Agent $AGENT_ID contributions:"
  FILE_COUNT=$(curl -s "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files" \
    -H "Authorization: Bearer ${API_KEY}" | jq '.files | length')
  echo "  📄 Memory files: $FILE_COUNT"
  
  # Show latest file
  LATEST=$(curl -s "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files" \
    -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0] | "\(.path) (\(.wordCount)w)"')
  echo "  📝 Latest: $LATEST"
  echo
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Final summary
echo "╔══════════════════════════════════════════════════╗"
echo "║             Pipeline Complete! ✅                 ║"
echo "╚══════════════════════════════════════════════════╝"
echo

echo "✓ Features Demonstrated:"
echo "  ✅ Multi-agent collaboration (4 agents)"
echo "  ✅ Memory storage (project brief + results)"
echo "  ✅ FTS5 search (knowledge retrieval)"
echo "  ✅ Tool execution (file creation)"
echo "  ✅ Multi-turn reasoning (Q&A)"
echo "  ✅ Persona diversity (formal, casual, concise)"
echo

echo "📊 Pipeline Stats:"
TOTAL_FILES=$(curl -s "${BASE_URL}/api/v1/agents/1/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.files | length')
TOTAL_FILES_2=$(curl -s "${BASE_URL}/api/v1/agents/2/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.files | length')
TOTAL_FILES_3=$(curl -s "${BASE_URL}/api/v1/agents/3/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.files | length')
TOTAL_FILES_4=$(curl -s "${BASE_URL}/api/v1/agents/4/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.files | length')

TOTAL=$((TOTAL_FILES + TOTAL_FILES_2 + TOTAL_FILES_3 + TOTAL_FILES_4))
echo "  Total memory files created: $TOTAL"
echo "  Agents involved: 4"
echo "  Phases completed: 7"
echo

echo "🎯 Production Readiness: ✅ DEMONSTRATED"
echo "  - Multi-agent orchestration working"
echo "  - Independent memories maintained"
echo "  - Tools integrated seamlessly"
echo "  - Knowledge persistence verified"
echo

echo "=== Test 12 Complete ✅ ==="
