# Bommalata Demo - Task Breakdown

**Total:** 12 tests across 4 phases, ~15-18 heartbeats

---

## Phase 1: Foundation (Tests 1-3)

### Test 1: Server Lifecycle & Agent Creation
**Heartbeat:** 1  
**Duration:** ~20 minutes

**Tasks:**
1. Create directory structure (demo-tests/, demo-results/, demo-logs/, demo-data/, demo-workspace/)
2. Write demo-config.yaml (server config with both providers)
3. Start tmux session: `bommalata-demo`
4. Build and start server in tmux
5. Verify health endpoint responds
6. Create test script: `demo-tests/test-01-server-lifecycle.sh`
7. Execute script:
   - POST /api/v1/agents (create agent with persona)
   - GET /api/v1/agents (list agents)
   - GET /api/v1/agents/1 (get specific agent)
   - Verify database persistence
8. Capture logs → `demo-logs/test-01-server.log`
9. Document results → `demo-results/test-01-server-lifecycle.md`
10. Update TIMELINE.md

**Deliverables:**
- Infrastructure setup complete
- Test 1 documented with logs
- Server running in tmux

---

### Test 2: Basic Task Execution (Streaming)
**Heartbeat:** 2  
**Duration:** ~15 minutes

**Tasks:**
1. Create test script: `demo-tests/test-02-streaming.sh`
2. Create simple task: "Write a haiku about Go programming"
3. POST /api/v1/agents/1/run-once with streaming enabled
4. Capture SSE event stream (use curl with --no-buffer or httpie --stream)
5. Show event sequence:
   - agent_start
   - turn_start (iteration 1)
   - message_end (assistant response)
   - turn_end
   - agent_end
6. Capture server logs showing streaming chunks
7. Extract final haiku from response
8. Document results → `demo-results/test-02-streaming.md`
9. Archive logs → `demo-logs/test-02-server.log`
10. Update TIMELINE.md

**Deliverables:**
- Streaming demonstrated end-to-end
- Event flow documented
- Example of text generation task

---

### Test 3: Tool Execution
**Heartbeat:** 3  
**Duration:** ~20 minutes

**Tasks:**
1. Verify echo tool is registered (built-in)
2. Create test script: `demo-tests/test-03-tools.sh`
3. Create task: "Echo the message 'Hello bommalata' and tell me what you learned"
4. POST /api/v1/agents/1/run-once with events channel
5. Capture event sequence:
   - agent_start
   - turn_start
   - message_end (assistant decides to use echo tool)
   - tool_execution_start (echo, args: {message: "Hello bommalata"})
   - tool_execution_end (result: "echo: Hello bommalata")
   - turn_end
   - turn_start (iteration 2, with tool result)
   - message_end (assistant reflects on result)
   - turn_end
   - agent_end
6. Show logs from runner (tool loop iteration)
7. Document tool call flow
8. Document results → `demo-results/test-03-tools.md`
9. Archive logs
10. Update TIMELINE.md

**Deliverables:**
- Tool execution demonstrated
- Tool events captured
- Multi-iteration loop shown

---

## Phase 2: Advanced Features (Tests 4-6)

### Test 4: Tool Lifecycle Hooks
**Heartbeat:** 4  
**Duration:** ~25 minutes

**Tasks:**
1. Create custom runner with hooks (Go program)
2. Implement BeforeToolExecution hook:
   - Rate limit: Allow max 2 echo calls
   - Return error on 3rd call with "Rate limit exceeded"
3. Implement AfterToolExecution hook:
   - Transform result: append timestamp
   - Log to console
4. Create test script that runs custom runner
5. Task: "Echo these messages: 'first', 'second', 'third'"
6. Show hook blocking on 3rd call
7. Show result transformation on successful calls
8. Capture hook logs
9. Document results → `demo-results/test-04-hooks.md`
10. Update TIMELINE.md

**Deliverables:**
- Custom runner with hooks
- BeforeToolExecution blocking demonstrated
- AfterToolExecution transformation demonstrated
- Code example for developers

---

### Test 5: Steering & Interruption
**Heartbeat:** 5  
**Duration:** ~25 minutes

**Tasks:**
1. Create custom runner with steering
2. Implement GetSteeringMessages hook:
   - Return steering message after 1st tool execution
   - Message: "Stop that approach, try something different"
3. Create task: "Echo these messages: 'one', 'two', 'three', 'four'"
4. Run with steering enabled
5. Show event sequence:
   - tool_execution_start (echo "one")
   - tool_execution_end
   - Steering check: message found
   - Remaining tools skipped ("two", "three", "four")
   - Steering message injected
   - Next turn with new direction
6. Show logs: "Steering messages received (1), skipping remaining 3 tools"
7. Document results → `demo-results/test-05-steering.md`
8. Update TIMELINE.md

**Deliverables:**
- Steering demonstrated
- Tool skipping shown
- Human-in-the-loop pattern validated

---

### Test 6: Memory Integration
**Heartbeat:** 6  
**Duration:** ~20 minutes

**Tasks:**
1. Create test script: `demo-tests/test-06-memory.sh`
2. Store facts via POST /api/v1/agents/1/memory:
   - "The user prefers Python for data science"
   - "The user's favorite algorithm is quicksort"
   - "Go is used for backend services"
3. Search memory via POST /api/v1/agents/1/memory/search:
   - Query: "programming languages"
   - Verify results include Python and Go facts
4. Create task: "What do you know about my programming preferences?"
5. Show agent retrieves stored facts (check logs for memory queries)
6. Verify response includes stored information
7. Document FTS5 search behavior
8. Document results → `demo-results/test-06-memory.md`
9. Update TIMELINE.md

**Deliverables:**
- Memory storage demonstrated
- FTS5 search working
- Memory-aware agent behavior shown

---

## Phase 3: Real-World Scenarios (Tests 7-9)

### Test 7: Multi-Turn Conversation
**Heartbeat:** 7  
**Duration:** ~20 minutes

**Tasks:**
1. Create agent with persona: "You are a helpful coding tutor who explains concepts clearly"
2. Create test script with multi-turn task:
   - Turn 1: "Explain quicksort algorithm"
   - Turn 2: "How would you optimize it for nearly-sorted arrays?"
   - Turn 3: "What edge cases should I test?"
3. Run task, capture conversation history
4. Show context building across turns
5. Document how persona influences responses
6. Measure token usage across turns
7. Document results → `demo-results/test-07-multi-turn.md`
8. Update TIMELINE.md

**Deliverables:**
- Multi-turn reasoning demonstrated
- Context management shown
- Persona influence documented

---

### Test 8: Error Handling & Recovery
**Heartbeat:** 8  
**Duration:** ~20 minutes

**Tasks:**
1. Create custom failing tool (returns error after 2 calls)
2. Create test script with task triggering failure
3. Capture error events:
   - tool_execution_start
   - tool_execution_end (isError: true)
   - Error message to model
   - Model response handling error
4. Verify event balancing (agent_start/end matched despite error)
5. Test closed channel resilience (close events channel mid-execution)
6. Show graceful degradation (events dropped, task continues)
7. Document error flow
8. Document results → `demo-results/test-08-error-handling.md`
9. Update TIMELINE.md

**Deliverables:**
- Error handling demonstrated
- Graceful degradation shown
- Event balancing verified

---

### Test 9: Scheduled Task Execution
**Heartbeat:** 9 (setup) + 10 (verify)  
**Duration:** 2 heartbeats (~40 minutes + wait time)

**Tasks (HB 9):**
1. Create test script: `demo-tests/test-09-scheduled.sh`
2. POST /api/v1/scheduled-tasks:
   - Task: "Check system time and log it"
   - Cron: "*/5 * * * *" (every 5 minutes)
   - Agent: 1
3. Verify task created
4. Wait for first execution

**Tasks (HB 10):**
1. GET /api/v1/scheduled-tasks/1/executions
2. Verify execution history
3. Check execution results
4. Show cron pattern working
5. Document results → `demo-results/test-09-scheduled.md`
6. Update TIMELINE.md

**Deliverables:**
- Scheduled tasks working
- Cron integration demonstrated
- Execution history shown

---

## Phase 4: Integration Patterns (Tests 10-12)

### Test 10: Event-Driven UI Updates
**Heartbeat:** 11  
**Duration:** ~25 minutes

**Tasks:**
1. Create mock SSE listener (Go program or curl script)
2. Subscribe to events endpoint (if available) or use runner events
3. Create long-running task: "Write a short story about a robot"
4. Show real-time event updates:
   - Progress tracking (turn 1, 2, 3...)
   - Message updates (incremental text)
   - Tool execution updates
5. Simulate UI state updates based on events
6. Document event timing and frequency
7. Document results → `demo-results/test-10-event-ui.md`
8. Update TIMELINE.md

**Deliverables:**
- Event-driven pattern demonstrated
- Real-time updates shown
- Frontend integration pattern documented

---

### Test 11: Multi-Agent Coordination
**Heartbeat:** 12 (setup) + 13 (execute)  
**Duration:** 2 heartbeats (~40 minutes)

**Tasks (HB 12):**
1. Create Agent A: "Research assistant - gather facts"
2. Create Agent B: "Writing assistant - synthesize information"
3. Design workflow:
   - Agent A: Research topic "History of Go language"
   - Agent A stores facts in memory
   - Agent B: Read facts, write summary

**Tasks (HB 13):**
1. Execute Agent A task
2. Verify memory storage
3. Execute Agent B task
4. Show memory retrieval
5. Document coordination pattern
6. Document results → `demo-results/test-11-multi-agent.md`
7. Update TIMELINE.md

**Deliverables:**
- Multi-agent pattern demonstrated
- Coordination via memory shown
- Task queue workflow validated

---

### Test 12: Full Pipeline
**Heartbeat:** 14 (setup) + 15 (execute)  
**Duration:** 2 heartbeats (~50 minutes)

**Tasks (HB 14):**
1. Design end-to-end pipeline:
   - Webhook receives task (simulated POST)
   - Task queued for agent
   - Agent processes with tools
   - Events emitted to mock SSE endpoint
   - Results stored in memory
   - Completion notification (log entry)
2. Create test harness

**Tasks (HB 15):**
1. Execute pipeline end-to-end
2. Trace request through all components
3. Show timing at each stage
4. Document all API calls
5. Show final state (database, memory, logs)
6. Document results → `demo-results/test-12-full-pipeline.md`
7. Create executive summary: `demo-results/SUMMARY.md`
8. Update TIMELINE.md

**Deliverables:**
- Complete agentic workflow demonstrated
- Integration points validated
- Production-readiness shown
- Final summary document

---

## Maintenance Tasks (Continuous)

**Every Test:**
- Archive server logs for that test
- Update TIMELINE.md with test summary
- Commit demo-results/ changes to git
- Keep tmux session alive

**After Each Phase:**
- Review logs for patterns
- Document interesting behaviors
- Update demonstration-plan.md if needed

**Final Cleanup:**
- Create SUMMARY.md (executive overview)
- Create LESSONS-LEARNED.md
- Create DEVELOPER-GUIDE.md (quick-start from examples)
- Archive full server.log

---

## Total Effort Estimate

**Setup:** 1 HB  
**Phase 1:** 3 HB  
**Phase 2:** 3 HB  
**Phase 3:** 4 HB  
**Phase 4:** 5 HB  
**Total:** ~16 heartbeats (4 days at 2/day or 1 week at natural pace)

**Documentation Output:** 12 test documents + 1 summary + logs + timeline

**Code Artifacts:** 12 test scripts, config file, custom runners (2-3 programs)

**Value:** Comprehensive demonstration of all bommalata features with real examples
