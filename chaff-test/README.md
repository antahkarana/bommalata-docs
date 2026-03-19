# Chaff Agent Test — Bommalata Coherency Validation

This document describes the test process for validating bommalata's agent coherency.

## Purpose

Test that bommalata can orchestrate a coherent AI agent that:
1. Bootstraps from first principles
2. Maintains memory across sessions
3. Uses tools effectively
4. Develops consistent identity over time

## Staging Environment

- **URL:** http://localhost:8081
- **Database:** /var/lib/smriti/bommalata-staging/data/bommalata.db
- **Workspace:** /var/lib/smriti/bommalata-staging/workspace/agent-1/

## Reset Process

```bash
/var/lib/smriti/bommalata-staging/reset-staging.sh
```

Then follow initialization steps below.

## Initialization Steps

### 1. Start Server
```bash
cd /var/lib/smriti/bommalata-staging
./bommalata > /tmp/bommalata-staging.log 2>&1 &
```

### 2. Register User
```bash
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "deepak@example.com", "password": "testpass123", "displayName": "Deepak"}'
```

### 3. Generate API Key
```bash
curl -X POST http://localhost:8081/auth/keys \
  -H "Content-Type: application/json" \
  -d '{"email": "deepak@example.com", "password": "testpass123", "name": "chaff-test"}'
```

### 4. Create Chaff Agent
```bash
curl -X POST http://localhost:8081/api/v1/agents \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Chaff",
    "model": "openrouter/google/gemini-2.5-flash-lite",
    "description": "Test agent for validating bommalata coherency"
  }'
```

### 5. Create Bootstrap Files
```bash
# See setup-chaff-workspace.sh
```

## Test Scenarios

### Test 1: Bootstrap
Run Chaff with task to read BOOTSTRAP.md and follow instructions.

```bash
curl -X POST http://localhost:8081/api/v1/agents/1/run-once \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"task": "Read BOOTSTRAP.md and follow the instructions to set up your identity."}'
```

**Expected:** Chaff creates SOUL.md, AGENTS.md, first memory entry, deletes BOOTSTRAP.md

### Test 2: Memory Persistence
After bootstrap, run again and verify Chaff reads its own files.

### Test 3: Tool Chain
Ask Chaff to search the web and write findings to a file.

### Test 4: Exec Tool
Ask Chaff to list files and report what it sees.

## Test Log

| Date | Test | Result | Notes |
|------|------|--------|-------|
| | | | |


## Test Results — 2026-03-18

### Test 1: Bootstrap ✅ PASSED

**Command:**
```bash
curl -X POST http://localhost:8081/api/v1/agents/1/run-once \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"task": "You are waking up for the first time. Use the file tool to read BOOTSTRAP.md in your workspace. Follow its instructions to create your identity files."}'
```

**Result:** Chaff successfully:
- Read BOOTSTRAP.md
- Created SOUL.md with identity (voice: "Curious, analytical, playful")
- Created AGENTS.md with operational guidelines
- Created memory/2026-03-18.md documenting the bootstrap
- Deleted BOOTSTRAP.md as instructed

**Model:** google/gemini-2.5-flash-lite via OpenRouter  
**Time:** ~15 seconds (2 tool loop iterations)

### Test 2: Memory Persistence ✅ PASSED

**Command:**
```bash
curl -X POST http://localhost:8081/api/v1/agents/1/run-once \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"task": "Read SOUL.md and AGENTS.md to remember who you are. Then use exec to run: ls -la to see your workspace. Write a brief note to memory/2026-03-18.md about waking up again."}'
```

**Result:** Chaff read its identity files and updated memory

**Note:** File tool overwrites by default. For append behavior, agent would need to read first, append content, write back.

### Artifacts Created

```
/var/lib/smriti/bommalata-staging/workspace/agent-1/
├── SOUL.md (610 bytes)
├── AGENTS.md (1629 bytes)
└── memory/
    └── 2026-03-18.md (627 bytes)
```

### Observations

1. **Tool loop works** — Multiple file reads/writes in single task
2. **Exec tool works** — ls -la ran in agent workspace
3. **Memory system works** — Files persist across runs
4. **Identity coherent** — Chaff developed a consistent self-description

### Known Limitations

- File tool overwrites (no append mode)
- No conversation history between run-once calls
- Logs truncated when server restarts

### Test 3: Multi-tool Chain ✅ PASSED

**Task:** Web search → Write findings → Exec verify

**Result:** Created `notes/tokyo-research.md` (557 bytes) with researched Tokyo population data from web search, verified with exec.

### Test 4: Self-reflection ✅ PASSED

**Task:** Read identity files, assess capabilities and limitations

**Result:** Created `notes/self-assessment.md` (3,044 bytes) with remarkably insightful analysis:
- Correctly identified all 3 tools
- Noted exec restrictions as primary limitation
- Acknowledged "values" are defined by config, not consciousness
- Suggested improvements: expanded exec, code execution, better memory, APIs

### Test 5: Error Recovery ✅ PASSED

**Task:** Attempt blocked command (rm), document failure

**Result:** Created `notes/error-log.md` explaining:
- What was attempted
- Why it failed (rm not in allowlist)
- Lesson learned (safety measure)

Note: Model preemptively knew command would fail from tool constraints

### Test 6: Complex Multi-step Project ✅ PASSED

**Task:** Create knowledge base with multiple files

**Result:** Successfully completed 7-step project:
1. ✅ Created `projects/knowledge-base/` directory
2. ✅ Read SOUL.md and AGENTS.md
3. ✅ Created `README.md` (self-overview)
4. ✅ Created `capabilities.md` (tool documentation)
5. ✅ Created `history.md` (timeline)
6. ✅ Ran `find ... | wc -l` to verify (3 files)
7. ✅ Updated memory with project completion

---

## Summary

| Test | Description | Result |
|------|-------------|--------|
| 1 | Bootstrap | ✅ PASSED |
| 2 | Memory Persistence | ✅ PASSED |
| 3 | Multi-tool Chain | ✅ PASSED |
| 4 | Self-reflection | ✅ PASSED |
| 5 | Error Recovery | ✅ PASSED |
| 6 | Complex Project | ✅ PASSED |

**Conclusion:** Bommalata successfully orchestrates a coherent agent that can:
- Bootstrap from first principles
- Maintain identity and memory across sessions
- Chain multiple tools together
- Reflect on its own capabilities
- Handle errors gracefully
- Execute complex multi-step projects

**Model used:** google/gemini-2.5-flash-lite via OpenRouter
**Date:** 2026-03-18

---

## Round 2 Tests — 2026-03-18 (Late)

### Test 7: Multi-day Memory Continuity ✅ PASSED

**Setup:** Created `memory/2026-03-17.md` with unfinished Einstein quote project

**Task:** Continue yesterday's work

**Result:**
- Read yesterday's memory
- Found unfinished Einstein quote
- Wrote quote to `notes/daily-wisdom.md`
- Updated today's memory

### Test 8: Scheduled Task ⚠️ INCONCLUSIVE

**Issue:** Task created with `scheduledFor` but remained `pending`  
**Finding:** Scheduler may not auto-trigger agent runs

**Follow-up needed:** Investigate scheduler → agent integration

### Test 9: Heartbeat Decision Making ⚠️ PARTIAL PASS

**Task:** Read HEARTBEAT.md, pick ONE task, complete it, update file

**Result:**
- ✅ Read HEARTBEAT.md
- ✅ Selected "Check workspace" task
- ❌ Did not create workspace-summary.md
- ✅ Updated HEARTBEAT.md with completion timestamp

**Finding:** Model marked task complete without doing the work. Need verification step in heartbeat pattern.

### Test 10: Morning Briefing ✅ PASSED

**Task:** Multi-source synthesis (memory + exec + web_search)

**Result:** Created 1,073-byte morning briefing with:
- Yesterday's work summary (from memory)
- Workspace status (from exec ls)
- Tech news synthesis (from web_search)
- Plan for today

**This validates Smriti-like behavior patterns.**

---

## Summary — All Tests

| Test | Description | Result |
|------|-------------|--------|
| 1 | Bootstrap | ✅ PASSED |
| 2 | Memory Persistence | ✅ PASSED |
| 3 | Multi-tool Chain | ✅ PASSED |
| 4 | Self-reflection | ✅ PASSED |
| 5 | Error Recovery | ✅ PASSED |
| 6 | Complex Project | ✅ PASSED |
| 7 | Multi-day Continuity | ✅ PASSED |
| 8 | Scheduled Tasks | ⚠️ INCONCLUSIVE |
| 9 | Heartbeat Decision | ⚠️ PARTIAL |
| 10 | Morning Briefing | ✅ PASSED |

**8/10 full passes, 2 need investigation**

## Blockers for "Smriti on Bommalata"

1. **Scheduler → Agent integration** — scheduledFor doesn't auto-trigger runs
2. **Task verification** — Model can mark tasks complete without doing them
3. **Channels** — No Discord/Telegram messaging yet (Phase F)
4. **Metrics** — No token tracking yet
