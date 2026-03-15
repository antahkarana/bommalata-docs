# Bommalata Demonstration Plan
## Documentation by Example - Showcasing Agentic Features

**Goal:** Create comprehensive test demonstrations showing bommalata's capabilities through realistic scenarios

**Approach:** Multi-part project with tests scheduled across heartbeats, server running in tmux with persistent logs

---

## Architecture

**Server Setup:**
- Run bommalata server in dedicated tmux session: `bommalata-demo`
- Persistent logs: `projects/bommalata-docs/demo-logs/`
- Keep full history (no erasure) - chronicle evolution over time
- Configuration: `projects/bommalata-docs/demo-config.yaml`

**Test Infrastructure:**
- Test scripts: `projects/bommalata-docs/demo-tests/`
- Results: `projects/bommalata-docs/demo-results/`
- One markdown file per test capturing: setup, execution, output, observations

**Documentation:**
- Each test produces a narrative document
- Shows actual API calls, responses, events, logs
- Real-world examples developers can reference

---

## Test Scenarios (Prioritized)

### Phase 1: Foundation (Tests 1-3)
**Setup & Basic Operations**

**Test 1: Server Lifecycle & Agent Creation**
- Start server, verify health
- Create agent with persona
- Test authentication
- Verify database persistence
- **Demonstrates:** Basic CRUD, auth, persistence
- **Time:** 1 heartbeat

**Test 2: Basic Task Execution (No Tools)**
- Create task: "Write a haiku about Go programming"
- Execute with streaming enabled
- Capture event stream
- Show logs from runner
- **Demonstrates:** Streaming, events (agent_start/end, turn_start/end, message_end)
- **Time:** 1 heartbeat

**Test 3: Tool Execution**
- Create echo tool
- Task: "Echo the message 'Hello bommalata'"
- Capture tool execution events (tool_execution_start/end)
- Show tool call arguments, results
- **Demonstrates:** Tool loop, tool events
- **Time:** 1 heartbeat

---

### Phase 2: Advanced Features (Tests 4-6)
**Hooks, Steering, Complex Workflows**

**Test 4: Tool Lifecycle Hooks**
- Create rate-limiting hook (BeforeToolExecution)
- Create result-caching hook (AfterToolExecution)
- Task: Multiple tool calls, show hook interception
- **Demonstrates:** Tool hooks, blocking, result transformation
- **Time:** 1 heartbeat

**Test 5: Steering & Interruption**
- Start long task with multiple tool calls
- Inject steering message mid-execution
- Show tools skipped, new direction taken
- **Demonstrates:** Human-in-the-loop, steering queue integration
- **Time:** 1 heartbeat

**Test 6: Memory Integration**
- Store facts via memory API
- Create task that references stored memories
- Show FTS5 search integration
- **Demonstrates:** Memory store, semantic search
- **Time:** 1 heartbeat

---

### Phase 3: Real-World Scenarios (Tests 7-9)
**Production-Like Use Cases**

**Test 7: Multi-Turn Conversation**
- Agent with persona: "Helpful coding assistant"
- Multi-turn task: Explain quicksort, then optimize it, then test edge cases
- Show conversation history building
- **Demonstrates:** Context management, multi-turn reasoning
- **Time:** 1 heartbeat

**Test 8: Error Handling & Recovery**
- Create failing tool
- Task triggers tool error
- Show error events, model recovery
- Test graceful degradation
- **Demonstrates:** Robust error handling, event balancing
- **Time:** 1 heartbeat

**Test 9: Scheduled Task Execution**
- Create scheduled task (cron pattern)
- Wait for execution
- Show task_executions history
- **Demonstrates:** Cron scheduling, task history
- **Time:** 2 heartbeats (create + wait)

---

### Phase 4: Integration Patterns (Tests 10-12)
**OpenClaw-Style Integration**

**Test 10: Event-Driven UI Updates**
- Simulate SSE endpoint consuming events
- Real-time progress tracking
- Show event flow: agent → turn → message → tool
- **Demonstrates:** Frontend integration pattern
- **Time:** 1 heartbeat

**Test 11: Multi-Agent Coordination**
- Create 2 agents with different personas
- Agent A: Research assistant (gathers info)
- Agent B: Writing assistant (synthesizes)
- Coordinate via task queue
- **Demonstrates:** Agent orchestration
- **Time:** 2 heartbeats

**Test 12: Full Pipeline**
- Webhook receives task
- Agent processes with tools
- Events emitted to SSE
- Results stored in memory
- Completion notification
- **Demonstrates:** End-to-end agentic workflow
- **Time:** 2 heartbeats

---

## Test Script Template

Each test follows this structure:

```markdown
# Test N: [Name]

## Objective
[What we're demonstrating]

## Setup
```bash
# Configuration
# Prerequisites
# Initial state
```

## Execution
```bash
# Actual API calls with curl/httpie
# Show request bodies
```

## Server Logs
```
[Timestamped logs from bommalata server]
```

## Event Stream
```json
[Events emitted, in order]
```

## Results
[What happened, what we learned]

## Observations
[Interesting behaviors, edge cases, insights]
```

---

## Implementation Schedule

**Heartbeat-Based Execution:**

### Week 1: Foundation
- **HB 1:** Setup (tmux, config, directories) + Test 1
- **HB 2:** Test 2 (streaming)
- **HB 3:** Test 3 (tools)

### Week 2: Advanced Features
- **HB 4:** Test 4 (hooks)
- **HB 5:** Test 5 (steering)
- **HB 6:** Test 6 (memory)

### Week 3: Real-World Scenarios
- **HB 7:** Test 7 (multi-turn)
- **HB 8:** Test 8 (error handling)
- **HB 9-10:** Test 9 (scheduled tasks, wait for execution)

### Week 4: Integration Patterns
- **HB 11:** Test 10 (event-driven UI)
- **HB 12-13:** Test 11 (multi-agent)
- **HB 14-15:** Test 12 (full pipeline)

**Total:** ~15 heartbeats (~1 week real-time at 30min intervals)

---

## Technical Details

### Server Configuration

```yaml
# demo-config.yaml
server:
  host: "127.0.0.1"
  port: 8080
  workspace: "/var/lib/smriti/workspace/projects/bommalata-docs/demo-workspace"

database:
  path: "./demo-data/bommalata.db"

providers:
  - name: openrouter
    type: openrouter
    models: ["openai/gpt-4o-mini", "anthropic/claude-3.5-sonnet"]
  
  - name: anthropic
    type: anthropic
    models: ["claude-3-5-sonnet-20241022"]

logging:
  level: debug
  format: json
  file: "./demo-logs/server.log"

env_file: "/var/lib/smriti/.config/secrets.env"
```

### Tmux Session Setup

```bash
# Create dedicated session
TMUX_TMPDIR=/var/lib/smriti/shared/tmux tmux new-session -d -s bommalata-demo

# Start server
tmux send-keys -t bommalata-demo "cd /var/lib/smriti/workspace/projects/bommalata" C-m
tmux send-keys -t bommalata-demo "nix develop" C-m
tmux send-keys -t bommalata-demo "./bommalata server --config ../bommalata-docs/demo-config.yaml 2>&1 | tee -a ../bommalata-docs/demo-logs/server.log" C-m

# View with: tmux attach -t bommalata-demo
```

### Log Management

**Log Rotation Strategy:**
- Keep full logs (no deletion)
- Archive by test: `demo-logs/test-01-server.log`, etc.
- Create summary timeline: `demo-logs/TIMELINE.md`

**Log Analysis:**
- Extract interesting patterns
- Document performance characteristics
- Identify optimization opportunities

---

## Success Criteria

Each test must:
- ✅ Execute successfully (or fail gracefully if testing error handling)
- ✅ Produce comprehensive documentation
- ✅ Capture all relevant logs
- ✅ Show actual API requests/responses
- ✅ Demonstrate the target feature clearly
- ✅ Include observations/insights

**Documentation Quality:**
- Clear narrative (not just logs)
- Explains what's happening at each step
- Highlights interesting behaviors
- Provides copy-paste examples for developers

**Historical Value:**
- Shows evolution of server behavior over time
- Documents quirks and edge cases
- Provides regression test baseline

---

## Directory Structure

```
projects/bommalata-docs/
├── demonstration-plan.md          # This file
├── demo-config.yaml               # Server config
├── demo-tests/                    # Test scripts
│   ├── test-01-server-lifecycle.sh
│   ├── test-02-streaming.sh
│   ├── test-03-tools.sh
│   └── ...
├── demo-results/                  # Test documentation
│   ├── test-01-server-lifecycle.md
│   ├── test-02-streaming.md
│   └── ...
├── demo-logs/                     # Server logs (persistent)
│   ├── server.log                 # Current log (appended)
│   ├── test-01-server.log         # Archived per test
│   ├── test-02-server.log
│   └── TIMELINE.md                # Summary of all tests
├── demo-data/                     # Database & workspace
│   ├── bommalata.db              # SQLite database
│   └── agent-*/                   # Agent workspaces
└── demo-workspace/                # Agent workspace root
```

---

## Why This Matters

**For Documentation:**
- Real examples > theoretical explanations
- Developers can copy-paste actual working code
- Shows gotchas and edge cases
- Demonstrates integration patterns

**For Testing:**
- Integration testing with real server
- Validates all features work together
- Catches issues missed by unit tests
- Provides regression baseline

**For Development:**
- Documents actual behavior over time
- Shows performance characteristics
- Identifies optimization opportunities
- Historical record of fixes and improvements

**For OpenClaw Integration:**
- Proves patterns work end-to-end
- Shows event flow, hook usage, steering
- Validates migration path
- Demonstrates production-readiness

---

## Notes

- **No secrets in logs:** Mask API keys, sanitize responses
- **Keep history:** Don't delete old logs, shows evolution
- **Incremental execution:** One test per heartbeat (manageable chunks)
- **Real providers:** Use actual OpenRouter/Anthropic (validates production behavior)
- **Document surprises:** Unexpected behaviors are learning opportunities

---

## Next Steps

1. **Setup Phase** (next heartbeat):
   - Create directory structure
   - Write demo-config.yaml
   - Start tmux session
   - Verify server startup
   - Create Test 1 script

2. **Execute Tests** (subsequent heartbeats):
   - One test per heartbeat
   - Document thoroughly
   - Archive logs
   - Update TIMELINE.md

3. **Synthesis** (after all tests):
   - Create executive summary
   - Highlight best practices
   - Document integration patterns
   - Create developer quick-start guide

---

**Status:** Planning complete, ready to execute
**First Execution:** Next heartbeat (Test 1: Server Lifecycle)
