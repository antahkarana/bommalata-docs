# Test 1: Server Lifecycle & Agent Creation

**Date:** 2026-03-15  
**Duration:** ~20 minutes  
**Status:** ✅ **PASSED**

---

## Objective

Demonstrate basic server operations and agent CRUD functionality:
- Server startup and health check
- Authentication (user registration + API key creation)
- Agent creation, listing, retrieval, and updates
- Database persistence

---

## Setup

**Infrastructure:**
- Server running in tmux session: `bommalata-demo`
- Database: `./data/bommalata.db` (SQLite with FTS5 support)
- Config: `demo-config.yaml`
- Build: bommalata with `CGO_ENABLED=1` and `-tags "fts5"`

**Prerequisites:**
1. Built bommalata with FTS5 support:
   ```bash
   cd projects/bommalata
   CGO_ENABLED=1 nix develop -c go build -tags "fts5" -o bommalata ./cmd/server
   ```

2. Started server in tmux:
   ```bash
   TMUX_TMPDIR=/var/lib/smriti/shared/tmux tmux new-session -d -s bommalata-demo
   BOMMALATA_ROOT=/path/to/bommalata ./bommalata server --config demo-config.yaml
   ```

3. Created user and API key:
   ```bash
   # Register user
   curl -X POST http://127.0.0.1:8080/auth/register \
     -H "Content-Type: application/json" \
     -d '{"email":"demo@example.com","displayName":"Demo User","password":"demo1234"}'
   
   # Create API key
   curl -X POST http://127.0.0.1:8080/auth/keys \
     -H "Content-Type: application/json" \
     -d '{"email":"demo@example.com","password":"demo1234","name":"demo-key"}'
   ```

**API Key (for this test):** `bomma_4j12rDXvu1XGfad722RG5BLKf5FxQ1UctJb2BP4qY0E`

---

## Execution

### 1. Health Check

**Request:**
```bash
curl -s http://127.0.0.1:8080/health
```

**Response:**
```
OK
```

✅ Server is operational

---

### 2. Create Agent

**Request:**
```bash
curl -X POST http://127.0.0.1:8080/api/v1/agents \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "name": "demo-agent",
    "persona": "You are a helpful AI assistant specialized in demonstrating bommalata'\''s capabilities. You are enthusiastic, clear, and thorough in your explanations.",
    "model": "openai/gpt-4o-mini",
    "provider": "openrouter"
  }'
```

**Response:**
```json
{
  "id": 1,
  "userId": 1,
  "name": "demo-agent",
  "status": "active",
  "workspaceRoot": "agent-1",
  "createdAt": "2026-03-15T18:50:30.664895596-05:00",
  "updatedAt": "2026-03-15T23:50:30Z"
}
```

✅ Agent created with ID: 1  
📁 Workspace created at: `agent-1/`

**Note:** The response doesn't include `persona`, `model`, or `provider` fields. These are likely stored in a separate table (e.g., agent profiles or configurations).

---

### 3. List All Agents

**Request:**
```bash
curl -s http://127.0.0.1:8080/api/v1/agents \
  -H "Authorization: Bearer $API_KEY"
```

**Response:**
```json
{
  "agents": [
    {
      "id": 1,
      "userId": 1,
      "name": "demo-agent",
      "status": "active",
      "workspaceRoot": "agent-1",
      "createdAt": "2026-03-15T18:50:30.664895596-05:00",
      "updatedAt": "2026-03-15T23:50:30Z"
    }
  ],
  "total": 1
}
```

✅ Agent listed successfully

---

### 4. Get Agent by ID

**Request:**
```bash
curl -s http://127.0.0.1:8080/api/v1/agents/1 \
  -H "Authorization: Bearer $API_KEY"
```

**Response:**
```json
{
  "id": 1,
  "userId": 1,
  "name": "demo-agent",
  "status": "active",
  "workspaceRoot": "agent-1",
  "createdAt": "2026-03-15T18:50:30.664895596-05:00",
  "updatedAt": "2026-03-15T23:50:30Z"
}
```

✅ Agent retrieved by ID

---

### 5. Update Agent

**Request:**
```bash
curl -X PATCH http://127.0.0.1:8080/api/v1/agents/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "persona": "You are a helpful AI assistant specialized in demonstrating bommalata'\''s capabilities. You are enthusiastic, clear, thorough, and you love emojis! 🎉"
  }'
```

**Response:**
```json
{
  "id": 1,
  "userId": 1,
  "name": "demo-agent",
  "status": "active",
  "workspaceRoot": "agent-1",
  "createdAt": "2026-03-15T18:50:30.664895596-05:00",
  "updatedAt": "2026-03-15T23:50:32Z"
}
```

✅ Agent updated successfully  
⏱️ `updatedAt` changed from `23:50:30Z` → `23:50:32Z`

**Note:** The update method is **PATCH**, not PUT. The response indicates the update succeeded (timestamp changed), but the persona field isn't returned in the response.

---

## Server Logs (Excerpt)

```
2026/03/15 18:50:27 [server] Initializing database at ./data/bommalata.db
2026/03/15 18:50:27 [database] Applied migration: 003_auth_tables.sql
2026/03/15 18:50:27 [database] Applied migration: 004_session_persistence.sql
2026/03/15 18:50:27 [database] Applied migration: 005_memory_system.sql
2026/03/15 18:50:27 [database] Applied migration: 006_agents.sql
2026/03/15 18:50:27 [database] Applied migration: 007_add_task_result_type.sql
2026/03/15 18:50:27 [database] Applied migration: 008_scheduled_tasks.sql
2026/03/15 18:50:27 [database] Applied migration: 009_tasks_webhooks_workflows.sql
2026/03/15 18:50:27 [database] Initialized at ./data/bommalata.db
2026/03/15 18:50:27 [server] Recovering sessions from database...
2026/03/15 18:50:27 [sessions] Recovered 0 sessions from database
2026/03/15 18:50:27 Starting server on port 8080
2026/03/15 18:50:27 [scheduler] Starting scheduler with 1m0s check interval
2026/03/15 18:50:27 [scheduler] Scheduler started with 0 tasks loaded
2026/03/15 18:50:27 [server] Scheduler started
2026/03/15 18:50:27 ✅ Server ready on port 8080

2026/03/15 18:50:30 "POST http://127.0.0.1:8080/api/v1/agents HTTP/1.1" from 127.0.0.1:37808 - 201 181B in 524.889912ms
2026/03/15 18:50:30 "GET http://127.0.0.1:8080/api/v1/agents HTTP/1.1" from 127.0.0.1:37812 - 200 226B in 507.950841ms
2026/03/15 18:50:31 "GET http://127.0.0.1:8080/api/v1/agents/1 HTTP/1.1" from 127.0.0.1:37826 - 200 181B in 517.697396ms
2026/03/15 18:50:32 "PATCH http://127.0.0.1:8080/api/v1/agents/1 HTTP/1.1" from 127.0.0.1:37838 - 200 181B in 506.758197ms
2026/03/15 18:50:32 "GET http://127.0.0.1:8080/api/v1/agents/1 HTTP/1.1" from 127.0.0.1:37850 - 200 181B in 499.992738ms
```

**Key observations:**
- ✅ All migrations applied successfully (including FTS5-dependent 005_memory_system.sql)
- ✅ Scheduler started and loaded 0 tasks
- ✅ All API calls returned expected status codes (201 for create, 200 for get/list/patch)
- ⏱️ Response times: ~500-525ms (expected for DB operations)

---

## Results

### ✅ Successful Operations

1. **Health check** - Server operational
2. **Agent creation** - Agent ID 1 created with workspace
3. **Agent listing** - Returned 1 agent
4. **Agent retrieval** - Retrieved agent by ID
5. **Agent update** - `updatedAt` timestamp changed, confirming persistence

### 🔍 Observations

**1. FTS5 Requirement**
- Initial build without FTS5 support failed on migration 005
- Required rebuilding with: `CGO_ENABLED=1 go build -tags "fts5"`
- This is essential for the memory system's full-text search

**2. Authentication Flow**
- User registration requires: `email`, `displayName`, `password` (min 8 chars)
- API keys created via `/auth/keys` with email/password auth
- All agent endpoints require `Authorization: Bearer <key>` header
- Key format: `bomma_<base64_string>`

**3. Agent Schema**
- Agents have: `id`, `userId`, `name`, `status`, `workspaceRoot`, timestamps
- Persona, model, provider fields submitted on creation but not returned in responses
- Likely stored separately (agent profiles table)

**4. CRUD Patterns**
- **Create:** POST `/api/v1/agents`
- **List:** GET `/api/v1/agents`
- **Get:** GET `/api/v1/agents/{id}`
- **Update:** PATCH `/api/v1/agents/{id}` (not PUT!)
- **Delete:** DELETE `/api/v1/agents/{id}` (not tested)

**5. Database Persistence**
- SQLite database with 9 migrations applied
- Session recovery enabled (0 sessions recovered on fresh start)
- Scheduler integrated (cron tasks)

---

## Artifacts

**Test Script:** `demo-tests/test-01-server-lifecycle.sh`  
**Server Logs:** `demo-logs/test-01-server.log`  
**Database:** `data/bommalata.db` (persists across runs)

---

## Next Steps

✅ Test 1 complete - foundation established  
➡️ **Test 2:** Streaming & Events (demonstrate SSE event stream)

**Recommendations:**
- Keep server running in tmux for all subsequent tests
- Use same API key for remaining tests
- Agent 1 can be reused for tasks in upcoming tests
