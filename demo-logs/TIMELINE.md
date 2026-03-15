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

## Next Test

**Test 2: Streaming & Events**  
**Planned:** Next heartbeat  
**Focus:** SSE event stream, real-time task execution

---

_Timeline updated: 2026-03-15 18:51 CST_
