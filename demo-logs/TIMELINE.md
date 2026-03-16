# Bommalata Demo Timeline

Chronological record of test executions

---

## 2026-03-15

### Test 1: Server Lifecycle & Agent Creation ✅
**Time:** 18:44 - 18:50 CST  
**Duration:** ~20 minutes (including troubleshooting)  
**Status:** PASSED

**What was demonstrated:**
- Server startup with all 9 migrations (including FTS5-dependent memory system)
- User registration and API key creation
- Agent CRUD operations (Create, List, Get, Update)
- Database persistence
- Authentication flow

**Key learnings:**
- FTS5 support requires `CGO_ENABLED=1` and `-tags "fts5"` during build
- Agent updates use PATCH, not PUT
- Persona/model/provider fields stored separately from base agent record
- All API endpoints require Bearer token authentication

**Artifacts:**
- Script: `demo-tests/test-01-server-lifecycle.sh`
- Results: `demo-results/test-01-server-lifecycle.md`
- Logs: `demo-logs/test-01-server.log`

**Database state:**
- Users: 1 (demo@example.com)
- API Keys: 1 (demo-key)
- Agents: 1 (demo-agent)

---

### Test 2: Basic Task Execution ✅ (⚠️ HTTP Streaming Discovery)
**Time:** 19:04 - 19:12 CST  
**Duration:** ~25 minutes (including investigation)  
**Status:** TASK EXECUTION SUCCESSFUL | HTTP STREAMING NOT YET IMPLEMENTED

**What was demonstrated:**
- Inline task submission and execution
- LLM completion (Google Gemini 2.5 Flash Lite via OpenRouter)
- Memory storage of results
- Runner execution flow (visible in logs)
- Haiku generation: "Statically typed, / Fast and efficient, GoLang, / Concurrency reigns."

**Key discovery:**
- ✅ Runner has event emission capabilities (Phase H infrastructure)
- ❌ HTTP handlers don't expose events via SSE yet
- RunOnce endpoint returns simple `{"status": "completed"}` without event stream
- HTTP streaming integration deferred to Test 10 (Event-Driven UI)

**Environment setup:**
- Required `OPENROUTER_API_KEY` environment variable
- Used `$SMRITI_FALLBACK_OPENROUTER_KEY`
- Server restart needed with explicit export

**Artifacts:**
- Script: `demo-tests/test-02-streaming.sh`
- Results: `demo-results/test-02-streaming.md` (9.9KB)
- Server logs: Captured task execution trace

**Architecture insight:**
- Phase H delivered event emission at runner layer ✅
- HTTP integration layer not yet implemented ⚠️
- This validates the need for Test 10

---

## Next Test

**Test 3: Tool Execution**  
**Planned:** Next heartbeat  
**Focus:** Echo tool demonstration, multi-iteration tool loop

---

_Timeline updated: 2026-03-15 19:12 CST_
