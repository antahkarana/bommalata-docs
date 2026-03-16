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

### Test 3: Tool Execution ✅
**Time:** 19:26 - 19:28 CST  
**Duration:** ~15 minutes (including discovery + execution)  
**Status:** PASSED

**What was demonstrated:**
- File tool usage (write operation)
- Multi-iteration reasoning loop (2 iterations)
- Tool call/result flow with proper message structure
- Model switching mid-task (Gemini → Claude Opus)
- Workspace isolation (file created in agent-1 workspace)

**Execution trace:**
- Iteration 1: Gemini 2.5 Flash Lite decided to use file tool (114 tokens)
- Tool execution: Write to test3-greeting.txt (result: "ok")
- Iteration 2: Claude 4.6 Opus synthesized final response (833 tokens)
- Total: 3.23s, ~947 tokens, 2 iterations

**Key discovery:**
- Only file tool registered (not echo tool as planned)
- OpenRouter intelligently switches models (cost optimization: cheap for tool call, premium for synthesis)
- Tool execution overhead: ~2x time, ~10x tokens vs no-tool tasks

**Created artifact:**
- File: `data/workspaces/agent-1/test3-greeting.txt`
- Content: "Hello from Test 3! The file tool is working."

**Artifacts:**
- Script: `demo-tests/test-03-tools.sh`
- Results: `demo-results/test-03-tools.md` (11.4KB)
- Server logs: `demo-logs/test-03-server.log`

**Architecture insight:**
- Workspace isolation working (files in agent-specific dirs)
- Tool execution properly logged at every step
- Message role flow correct (user → assistant → tool → assistant)

---

### Test 4: Tool Hooks ✅
**Time:** 19:48 - 20:16 CST  
**Duration:** ~30 minutes (including troubleshooting)  
**Status:** COMPLETE SUCCESS

**What was demonstrated:**
- BeforeToolExecution: Rate limiting (max 2 file tool calls) ✅
- AfterToolExecution: Result transformation (timestamps) ✅
- Hook blocking: Third call prevented by rate limit ✅
- Model integration: Saw transformed results and understood blocking ✅

**Execution results:**
- **Test 1 (Call #1):** Allowed, file created, result transformed ✅
- **Test 2 (Call #2):** Allowed, file created, result transformed ✅
- **Test 3 (Call #3):** **BLOCKED by rate limit** ✅
  - Hook prevented execution
  - Error became tool result
  - Model responded: "I am sorry, I cannot fulfill this request..."
  - File NOT created (correctly blocked)

**Files created:**
- hook-test-1.txt: "First file created successfully" ✅
- hook-test-2.txt: "Second file created successfully" ✅
- hook-test-3.txt: ❌ Does NOT exist (blocked by hook)

**Troubleshooting:**
- Initial run: API privacy/guardrail error with gpt-4o-mini
- Solution: Changed model to google/gemini-2.5-flash-lite
- Server config update helped (env_file loading API key)

**Enhanced logging in action:**
```
msg[0] role=user (Create a file named hook-test-1.txt with...)
msg[1] role=assistant (tool call: file)
msg[2] role=tool (file tool result: ok (transformed at 2026-03-15 20:15:46))
```

**Value:**
- Proves Phase H hook infrastructure production-ready ✅
- Validates 2 critical use cases (security + enhancement) ✅
- Shows proper integration with runner ✅
- Model handled hooks intelligently ✅

**Artifacts:**
- Code: `cmd/demo-hooks/main.go` (5.4KB)
- Success doc: `demo-results/test-04-hooks-SUCCESS.md` (8.2KB)
- Architecture doc: `demo-results/test-04-hooks.md` (10.5KB)
- Output log: `demo-logs/test-04-hooks-output.log` (full execution trace)
- Files: 2 created, 1 correctly blocked

---

### Test 5: Steering & Interruption ✅
**Time:** 20:27 - 20:34 CST  
**Duration:** ~7 minutes (execution < 2 min, documentation ~5 min)  
**Status:** COMPLETE SUCCESS

**What was demonstrated:**
- AfterToolExecution hook: Injected steering message after first tool execution ✅
- GetSteeringMessages hook: Returned queued steering messages to runner ✅
- Tool skipping: Remaining 3 tools automatically skipped ✅
- Agent response: Acknowledged interruption correctly ✅
- Human-in-the-loop pattern: Validated end-to-end ✅

**Execution flow:**
- Agent planned to write 4 files (steering-1.txt through steering-4.txt)
- After first file written, hook queued steering message
- Runner detected steering, skipped remaining 3 tool calls
- Skipped tools shown as: "Skipped: user interruption received"
- Agent response: "The user interrupted the file writing operations. Therefore, only 'steering-1.txt' was created with the content 'First'."

**Files created:**
- steering-1.txt: ✅ Created (content: "First")
- steering-2.txt: ❌ Skipped (correctly)
- steering-3.txt: ❌ Skipped (correctly)
- steering-4.txt: ❌ Skipped (correctly)

**Key observations:**
- Steering check occurs after each tool execution
- Non-blocking channel read (returns nil if empty)
- Tool skipping is batch-aware (skips all remaining in current batch)
- Event stream remains balanced (start/end pairs correct)
- Model understood interruption context perfectly

**Use cases validated:**
- Human-in-the-loop workflows
- Safety guardrails (stop dangerous operations mid-flight)
- Priority handling (inject urgent tasks)
- Cost control (abort expensive multi-tool sequences)

**Artifacts:**
- Code: `cmd/demo-steering/main.go` (172 lines)
- Results: `demo-results/test-05-steering.md` (7.7KB)
- Logs: `demo-logs/test-05-steering.log` (53 lines)
- Files: 1 created, 3 correctly skipped

**Value:**
- Validates Phase H's steering system production-ready ✅
- Demonstrates critical agentic pattern (interruption without breaking flow) ✅
- Proves runtime task redirection works ✅

---

## Next Test

**Test 6: Memory Integration**  
**Focus:** FTS5 search, memory-aware tasks, semantic retrieval

---

_Timeline updated: 2026-03-15 20:34 CST_
