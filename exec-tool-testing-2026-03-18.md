# Exec Tool Testing - March 18, 2026

## Test Environment
- **Branch:** `feat/exec-tool` (commit `f9b7658`)
- **Staging:** `http://localhost:8081`
- **API Key:** `bomma_AommVuuusESvTB4oDWkqZND0VOaKB6xQ0BAUzkUTYKc`

## Test 1: Multi-Tool Interaction (File + Exec)

### Task
```
1. Use the file tool to write a haiku about programming to memory/haiku.md
2. Use exec to run: cat memory/haiku.md
3. Use exec to run: wc -l memory/haiku.md
4. Tell me the results
```

### Results

**Iteration 1:** Model called file tool ✅
```
Tool file result (2 bytes): ok
```

**Iteration 2:** Model called exec tool ❌
```
[runner] Executing tool: exec (id=tool_exec_BthGirGXQl1B1LirVeAD) args=map[command:cat memory/haiku.md]
[runner] Tool exec result (60 bytes): { cat: memory/haiku.md: No such file or directory
```

**Iteration 3:** Model tried wc -l ❌
```
[runner] Executing tool: exec (id=tool_exec_TTjapZQCw80JHDcR9dlp) args=map[command:wc -l memory/haiku.md]
[runner] Tool exec result (59 bytes): { wc: memory/haiku.md: No such file or directory
```

**Iteration 4:** Model gave up and reported error

### File Actually Written ✅
```bash
$ cat /var/lib/smriti/bommalata-staging/workspace/agent-1/memory/haiku.md
Code flows like water
Bugs hide in the darkest depths
Fix one, two appear
```

## Bug Found: Exec Tool Working Directory

### Issue
Exec tool runs commands from system root (`/`), not the agent's workspace. File tool writes to agent workspace, but exec can't find those files.

### Root Cause
- File tool: receives workspace path via `file.New(workspaceRoot)`
- Exec tool: no workspace context, runs from default CWD

### Fix Required
Exec tool needs to:
1. Accept workspace path in constructor (like file tool)
2. Set working directory before executing commands

### Code Location
`internal/tools/exec/tool.go` - `Execute()` method

### Suggested Fix
```go
func NewTool(workspaceRoot string) *Tool {
    return &Tool{workspaceRoot: workspaceRoot}
}

// In Execute():
cmd.Dir = t.workspaceRoot
```

## Test 2: Web Search (Blocked)

### Issue
Web search returns `<nil>` - missing `OPENROUTER_API_KEY` in staging environment.

### Logs
```
[web_search] Searching (max results: 3, query length: 43)
[runner] Tool web_search result (5 bytes): <nil>
```

### Fix Required
Add `EnvironmentFile=/var/lib/smriti/bommalata-staging/.env` to systemd service (requires sudo).

## Observability Notes

### Current Logging (Good)
- Tool name and args logged: `Executing tool: exec (...) args=map[command:...]`
- Tool results logged: `Tool exec result (60 bytes): ...`
- Iteration count and message history visible

### Missing/Needed
1. **Working directory context** - Log what CWD the command runs in
2. **Tool error vs success distinction** - Currently both look similar
3. **Timing per tool call** - How long did exec take?

### Log Sample
```
2026/03/18 13:24:02 [runner] Starting tool loop (max 10 iterations), 3 tools available
2026/03/18 13:24:02 [runner] Iteration 1: calling completion with 1 messages
2026/03/18 13:24:09 [runner] Response: model=google/gemini-3-pro-preview-20251117, 1 tool calls, stop_reason=tool_use
2026/03/18 13:24:09 [runner] Executing tool: file (id=tool_file_3N2wYMcoapjXfGFy7eoK) args=map[content:Code flows like water...]
2026/03/18 13:24:09 [runner] Tool file result (2 bytes): ok
2026/03/18 13:24:10 [runner] Executing tool: exec (id=tool_exec_BthGirGXQl1B1LirVeAD) args=map[command:cat memory/haiku.md]
2026/03/18 13:24:10 [runner] Tool exec result (60 bytes): { cat: memory/haiku.md: No such file or directory
```

## Test 3: After Workspace Fix (13:26 CDT)

### Fix Applied
- Added `NewToolWithWorkdir(workdir)` constructor to exec tool
- agent_runner.go passes workspace path when creating exec tool
- Commit: `47fcabc`

### Results ✅

**Log output:**
```
[runner] Exec tool registered for agent 1 (workdir: /var/lib/smriti/bommalata-staging/workspace/agent-1)
[runner] Executing tool: exec args=map[command:cat memory/test-haiku.md]
[runner] Tool exec result: {Code breaks silently\nTests reveal the hidden bugs\nGreen check brings relief  0 false }
[runner] Executing tool: exec args=map[command:wc -l memory/test-haiku.md]
[runner] Tool exec result (35 bytes): {2 memory/test-haiku.md  0 false }
```

### Multi-tool coordination verified:
1. ✅ File tool wrote haiku to `memory/test-haiku.md`
2. ✅ Exec `cat` successfully read the file
3. ✅ Exec `wc -l` returned "2 memory/test-haiku.md"
4. ✅ Model reported results correctly

## Summary

| Test | Status | Notes |
|------|--------|-------|
| File tool write | ✅ PASS | Haiku written correctly |
| Exec tool (system paths) | ✅ PASS | `pwd`, `whoami`, `date` work |
| Exec tool (agent workspace) | ✅ PASS | **Fixed** - uses agent workspace |
| Multi-tool coordination | ✅ PASS | File + Exec work together |
| Web search | ❌ BLOCKED | Missing API key in env |

## Test 4: Full Multi-Tool Chain (13:53 CDT)

### Task
```
Search for news about Rust 2024 edition using web_search, then save the results 
to memory/search-results.md using file tool, then use exec to count the words 
with wc -w memory/search-results.md
```

### Results ✅ COMPLETE SUCCESS

**Step 1: Web Search**
```
[runner] Executing tool: web_search args=map[query:Rust 2024 edition news]
[web_search] Found 1 results for: "Rust 2024 edition news"
[runner] Tool web_search result (1758 bytes)
```

**Step 2: File Write**
```
[runner] Executing tool: file args=map[content:1. **Rust 1.85.0 released...
[runner] Tool file result (2 bytes): ok
```

**Step 3: Exec Word Count**
```
[runner] Executing tool: exec args=map[command:wc -w memory/search-results.md]
[runner] Tool exec result (41 bytes): {169 memory/search-results.md
```

**Step 4: Model Response**
```
[runner] Task complete, storing result
[memory] Storing task_result for agent 1: The search results have been saved to 
`memory/search-results.md`, and the word count for the file is...
```

### Bugs Fixed During Testing

1. **Model name wrong** (commit `c190031`): `perplexity/sonar-reasoning` → `perplexity/sonar`
2. **Exec CWD wrong** (commit `47fcabc`): Added `NewToolWithWorkdir()` to use agent workspace

## Final Summary

| Tool | Status | Notes |
|------|--------|-------|
| File tool | ✅ PASS | Writes to agent workspace |
| Exec tool | ✅ PASS | Uses agent workspace as CWD |
| Web search | ✅ PASS | Fixed model name |
| Multi-tool chain | ✅ PASS | web_search → file → exec works |

## Commits on `feat/exec-tool`

- `365e416` - Initial exec tool with allowlist
- `a51d463` - API docs refresh
- `f9b7658` - Register exec tool in agent runner
- `47fcabc` - Exec tool uses agent workspace as CWD
- `c190031` - Fix Perplexity model name for web search

## Nice-to-have (Future)
- Add timing logs for tool calls
- Distinguish tool errors from success in log format
- Add tool execution metrics/stats
