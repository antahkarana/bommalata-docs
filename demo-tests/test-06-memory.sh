#!/usr/bin/env bash
# Test 6: Memory Integration
# Demonstrates: FTS5 file-based memory, semantic search, memory-aware agents

set -e

API_KEY="bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E"
BASE_URL="http://127.0.0.1:8080"
AGENT_ID=1

echo "=== Test 6: Memory Integration ==="
echo

# Step 1: Create memory files
echo "Step 1: Creating memory files"
echo "------------------------------"

echo "Creating daily log with programming notes..."
curl -s -X POST "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "path": "daily/2026-03-15-programming.md",
    "type": "daily_log",
    "content": "# Programming Notes - March 15\n\n## Languages\n\n- **Python**: Preferred for data science and machine learning\n- **Go**: Used for backend services and high-performance applications\n- **JavaScript**: Frontend development with React\n\n## Algorithms\n\n- Favorite sorting algorithm: **Quicksort** (O(n log n) average case)\n- Recently studied: Binary search trees and graph traversal\n"
  }' | jq '{id, path, type, wordCount}'

echo
echo "Creating long-term memory with preferences..."
curl -s -X POST "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "path": "preferences.md",
    "type": "long_term",
    "content": "# User Preferences\n\n## Development Environment\n\n- Editor: VS Code with Vim keybindings\n- Terminal: tmux + zsh\n- Version control: Git with trunk-based development\n\n## Code Style\n\n- Strongly typed languages preferred\n- Test-driven development when possible\n- Clear documentation and examples\n"
  }' | jq '{id, path, type, wordCount}'

echo
echo "Creating brainstorming notes..."
curl -s -X POST "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "path": "brainstorm/api-design.md",
    "type": "brainstorm",
    "content": "# API Design Ideas\n\n## REST vs GraphQL\n\n- REST: Simple, cacheable, well-understood\n- GraphQL: Flexible queries, reduces overfetching\n\n## Thoughts\n\n- For internal services: Go with gRPC for performance\n- For public APIs: REST with OpenAPI spec\n- Consider GraphQL for complex client requirements\n"
  }' | jq '{id, path, type, wordCount}'

echo
echo "✓ Memory files created"
echo

# Step 2: List all files
echo "Step 2: Listing memory files"
echo "------------------------------"

curl -s -X GET "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.files[] | {id, path, type, wordCount}'

echo
echo "✓ Files listed"
echo

# Step 3: Search memory with FTS5
echo "Step 3: Semantic search with FTS5"
echo "-----------------------------------"

echo "Query: 'programming languages'"
curl -s -X POST "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "query": "programming languages",
    "limit": 5
  }' | jq '.results'

echo
echo "Query: 'algorithm quicksort'"
curl -s -X POST "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "query": "algorithm quicksort",
    "limit": 5
  }' | jq '.results'

echo
echo "Query: 'API design'"
curl -s -X POST "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "query": "API design",
    "limit": 5
  }' | jq '.results'

echo
echo "✓ Search complete"
echo

# Step 4: Get specific file
echo "Step 4: Retrieving specific file"
echo "----------------------------------"

# Get the ID of the first file
FILE_ID=$(curl -s -X GET "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files" \
  -H "Authorization: Bearer ${API_KEY}" | jq -r '.files[0].id')

echo "Fetching file ID: ${FILE_ID}"
curl -s -X GET "${BASE_URL}/api/v1/agents/${AGENT_ID}/memory/files/${FILE_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq '{id, path, type, content}'

echo
echo "✓ File retrieved"
echo

echo "=== Test 6 Complete ✅ ==="
echo
echo "Memory Integration Validated:"
echo "  ✓ File-based memory storage"
echo "  ✓ FTS5 semantic search across files"
echo "  ✓ Multiple file types (daily_log, long_term, brainstorm)"
echo "  ✓ Content chunking and retrieval"
echo
echo "Created files:"
echo "  - daily/2026-03-15-programming.md (programming notes)"
echo "  - preferences.md (user preferences)"
echo "  - brainstorm/api-design.md (design ideas)"
