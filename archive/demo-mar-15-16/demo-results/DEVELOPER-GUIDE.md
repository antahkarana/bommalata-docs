# Bommalata Developer Guide

**Version:** 1.0  
**Last Updated:** March 16, 2026  
**Based on:** 12 comprehensive integration tests

---

## Overview

This guide helps developers integrate with bommalata, an agent orchestration server built in Go. It covers setup, common patterns, API usage, and best practices discovered during comprehensive testing.

**Target Audience:** Developers building clients, integrating agents, or extending bommalata

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Architecture Overview](#architecture-overview)
3. [API Reference](#api-reference)
4. [Common Patterns](#common-patterns)
5. [Agent Management](#agent-management)
6. [Memory System](#memory-system)
7. [Tools & Execution](#tools--execution)
8. [Scheduled Tasks](#scheduled-tasks)
9. [Multi-Agent Coordination](#multi-agent-coordination)
10. [Event-Driven UIs](#event-driven-uis)
11. [Error Handling](#error-handling)
12. [Best Practices](#best-practices)
13. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Prerequisites

- Go 1.21+ (if building from source)
- SQLite with FTS5 support
- API key for at least one provider (OpenRouter, Anthropic, or OpenAI)

### Installation

```bash
# Clone repository
git clone https://github.com/antahkarana/bommalata.git
cd bommalata

# Build with FTS5 support (required!)
go build -tags fts5 -o bommalata ./cmd/server

# Run server
./bommalata --config config.yaml
```

**Important:** The `-tags fts5` build flag is mandatory. Without it, the server will fail to start due to FTS5 table creation errors.

### Minimal Configuration

```yaml
# config.yaml
server:
  port: 8080
  host: "0.0.0.0"

database:
  path: "bommalata.db"

workspace:
  root: "./workspaces"

env_file: "secrets.env"  # Store API keys here
```

```bash
# secrets.env (mode 600, not committed to git!)
OPENROUTER_API_KEY=sk-or-v1-...
# OR
ANTHROPIC_API_KEY=sk-ant-...
```

### Your First Agent

```bash
# 1. Start server
./bommalata --config config.yaml

# 2. Create agent (in another terminal)
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "name": "my-first-agent",
    "providerId": 1,
    "modelName": "anthropic/claude-3.5-sonnet",
    "systemPrompt": "You are a helpful assistant."
  }'

# 3. Run task
curl -X POST http://localhost:8080/api/v1/agents/1/run-once \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "task": "Explain quantum computing in 3 bullet points"
  }'
```

---

## Architecture Overview

### Core Components

```
┌─────────────────────────────────────────────┐
│              HTTP API Layer                 │
│  /api/v1/agents, /memory, /scheduled-tasks │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│           Agent Runner                      │
│  Execution loop + Tool calls + Hooks        │
└─────────────────┬───────────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
┌────────▼──────┐  ┌───────▼────────┐
│   Providers   │  │  Memory Store  │
│ (OpenRouter,  │  │  (SQLite +     │
│  Anthropic)   │  │   FTS5)        │
└───────────────┘  └────────────────┘
```

### Data Flow

```
User Request
    ↓
HTTP Handler (auth, validation)
    ↓
Agent Runner (task execution)
    ↓
Provider (LLM API call)
    ↓
Tool Execution (optional)
    ↓
Memory Storage (automatic)
    ↓
Response to User
```

### Key Concepts

**Agent:** A configured instance with persona, model, and tools
**Provider:** LLM service (OpenRouter, Anthropic, OpenAI)
**Memory:** Per-agent file storage with FTS5 semantic search
**Task:** User request for agent to complete
**Tool:** Function the agent can call (e.g., file creation)

---

## API Reference

### Base URL

```
http://localhost:8080/api/v1
```

All endpoints require authentication:
```
Authorization: Bearer {API_KEY}
```

### Agents

#### Create Agent

```http
POST /api/v1/agents
Content-Type: application/json

{
  "name": "technical-writer",
  "providerId": 1,
  "modelName": "anthropic/claude-3.5-sonnet",
  "systemPrompt": "You are a technical writer who creates formal documentation.",
  "temperature": 0.7
}
```

**Response:**
```json
{
  "id": 2,
  "name": "technical-writer",
  "status": "active",
  "createdAt": "2026-03-16T10:00:00Z"
}
```

#### Run Task (One-Shot)

```http
POST /api/v1/agents/{id}/run-once
Content-Type: application/json

{
  "task": "Explain REST API best practices in 5 bullet points"
}
```

**Response:**
```json
{
  "agentId": 2,
  "status": "completed"
}
```

**Note:** Result is automatically stored in agent's memory. Retrieve via memory API.

#### List Agents

```http
GET /api/v1/agents
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "demo-agent",
    "status": "active",
    "createdAt": "2026-03-15T18:50:30Z"
  },
  {
    "id": 2,
    "name": "technical-writer",
    "status": "active",
    "createdAt": "2026-03-16T10:00:00Z"
  }
]
```

### Memory

#### List Memory Files

```http
GET /api/v1/agents/{id}/memory/files
```

**Response:**
```json
{
  "files": [
    {
      "id": 1,
      "path": "memory/task_result_20260316_100523.md",
      "type": "task_result",
      "content": "1. Use consistent naming...",
      "wordCount": 87,
      "createdAt": "2026-03-16T10:05:23Z"
    }
  ],
  "total": 1
}
```

**Best Practice:** Sort by `createdAt` descending to get latest:
```bash
curl ... | jq '.files | sort_by(.createdAt) | reverse | .[0]'
```

#### Search Memory (FTS5)

```http
POST /api/v1/agents/{id}/memory/search
Content-Type: application/json

{
  "query": "REST API best practices",
  "limit": 5
}
```

**Response:**
```json
{
  "results": [
    {
      "fileId": 1,
      "path": "memory/task_result_20260316_100523.md",
      "snippet": "REST API best practices include...",
      "score": -2.4,
      "heading": "Best Practices"
    }
  ]
}
```

**Note:** Lower score = better match (FTS5 convention)

#### Get Memory File

```http
GET /api/v1/agents/{id}/memory/files/{fileId}
```

**Response:**
```json
{
  "id": 1,
  "path": "memory/task_result_20260316_100523.md",
  "type": "task_result",
  "content": "1. Use consistent naming conventions...",
  "wordCount": 87,
  "createdAt": "2026-03-16T10:05:23Z"
}
```

### Scheduled Tasks

#### Create Scheduled Task

```http
POST /api/v1/scheduled-tasks
Content-Type: application/json

{
  "name": "daily-summary",
  "scheduleType": "cron",
  "scheduleExpr": "0 0 9 * * *",
  "timezone": "America/Chicago",
  "agentId": 1,
  "taskPayload": {
    "prompt": "Summarize yesterday's activities"
  },
  "enabled": true
}
```

**Important:** Cron uses 6 fields (includes seconds):
```
0 0 9 * * *
│ │ │ │ │ │
│ │ │ │ │ └─ weekday (0-7, 0 and 7 are Sunday)
│ │ │ │ └─── month (1-12)
│ │ │ └───── day (1-31)
│ │ └─────── hour (0-23)
│ └───────── minute (0-59)
└─────────── second (0-59)
```

**Response:**
```json
{
  "id": 1,
  "name": "daily-summary",
  "scheduleExpr": "0 0 9 * * *",
  "timezone": "America/Chicago",
  "enabled": true,
  "nextRunAt": "2026-03-17T09:00:00-05:00"
}
```

#### List Scheduled Tasks

```http
GET /api/v1/scheduled-tasks
```

#### Get Execution History

```http
GET /api/v1/scheduled-tasks/{id}/executions
```

**Response:**
```json
{
  "executions": [
    {
      "id": 1,
      "startedAt": "2026-03-16T09:00:00Z",
      "completedAt": "2026-03-16T09:00:02Z",
      "status": "success",
      "durationMs": 2100
    }
  ],
  "total": 1,
  "limit": 50
}
```

---

## Common Patterns

### Pattern 1: Task Execution with Memory Retrieval

```python
import requests

BASE_URL = "http://localhost:8080/api/v1"
API_KEY = "your-api-key"

def execute_and_retrieve(agent_id, task):
    # 1. Execute task
    response = requests.post(
        f"{BASE_URL}/agents/{agent_id}/run-once",
        headers={"Authorization": f"Bearer {API_KEY}"},
        json={"task": task}
    )
    response.raise_for_status()
    
    # 2. Wait a moment for storage (usually immediate)
    import time
    time.sleep(0.5)
    
    # 3. Retrieve latest result
    files = requests.get(
        f"{BASE_URL}/agents/{agent_id}/memory/files",
        headers={"Authorization": f"Bearer {API_KEY}"}
    ).json()
    
    if files.get('files'):
        latest = sorted(
            files['files'],
            key=lambda f: f['createdAt'],
            reverse=True
        )[0]
        return latest['content']
    
    return None

# Usage
result = execute_and_retrieve(1, "Explain quantum entanglement")
print(result)
```

### Pattern 2: Event Polling (Real-Time Updates)

```javascript
// Poll for new task completions
async function watchAgent(agentId, interval = 2000) {
  let lastCount = 0;
  
  setInterval(async () => {
    const response = await fetch(
      `/api/v1/agents/${agentId}/memory/files`,
      { headers: { Authorization: `Bearer ${apiKey}` } }
    );
    
    const data = await response.json();
    const files = data.files || [];
    
    if (files.length > lastCount) {
      const newFiles = files.slice(lastCount);
      newFiles.forEach(file => {
        console.log(`New result: ${file.path}`);
        displayResult(file);
      });
      lastCount = files.length;
    }
  }, interval);
}

// Usage
watchAgent(1); // Poll agent 1 every 2 seconds
```

### Pattern 3: Multi-Agent Workflow

```python
def documentation_pipeline(topic):
    # Step 1: Research (Technical Writer)
    research = execute_and_retrieve(
        agent_id=2,  # Technical Writer
        task=f"Research best practices for {topic}"
    )
    
    # Step 2: Draft (Friendly Coder)
    draft = execute_and_retrieve(
        agent_id=3,  # Friendly Coder
        task=f"Create a friendly tutorial about {topic}"
    )
    
    # Step 3: Summary (Concise Expert)
    summary = execute_and_retrieve(
        agent_id=4,  # Concise Expert
        task=f"Summarize key points about {topic} in 5 bullets"
    )
    
    return {
        'research': research,
        'draft': draft,
        'summary': summary
    }

# Usage
docs = documentation_pipeline("REST API design")
```

### Pattern 4: Memory Search with Context

```python
def query_knowledge_base(agent_id, question, context_limit=3):
    # 1. Search memory
    results = requests.post(
        f"{BASE_URL}/agents/{agent_id}/memory/search",
        headers={"Authorization": f"Bearer {API_KEY}"},
        json={"query": question, "limit": context_limit}
    ).json()
    
    # 2. Build context from results
    context_snippets = [
        r['snippet'] for r in results.get('results', [])
    ]
    context = "\n\n".join(context_snippets)
    
    # 3. Ask question with context
    enhanced_task = f"""Context from memory:
{context}

Question: {question}

Answer the question using the context above."""
    
    return execute_and_retrieve(agent_id, enhanced_task)

# Usage
answer = query_knowledge_base(1, "What are REST API best practices?")
```

---

## Agent Management

### Persona Design

Agents differentiate through system prompts. Examples from testing:

#### Technical Writer (Formal Documentation)
```json
{
  "systemPrompt": "You are a technical writer who creates formal, structured documentation. Use clear headings, numbered lists, and professional language. Responses should be thorough and well-organized.",
  "temperature": 0.5
}
```
**Output:** 59-word formal responses, structured sections

#### Friendly Coder (Casual & Practical)
```json
{
  "systemPrompt": "You are a friendly, approachable developer who explains things casually. Use conversational language and focus on practical examples. Keep responses brief and actionable.",
  "temperature": 0.7
}
```
**Output:** 31-word casual responses, action-oriented

#### Concise Expert (Bullet Points)
```json
{
  "systemPrompt": "You are a concise expert who communicates via bullet points. Bold key concepts. No fluff—just the essential information in scannable format.",
  "temperature": 0.3
}
```
**Output:** 57-word bullet lists, technical depth

### Choosing Models

**OpenRouter** (auto-routing):
```json
{
  "modelName": "openrouter/auto",
  "temperature": 0.7
}
```
- Automatically selects best model
- Cost-optimized
- Good for general use

**Anthropic Claude** (high quality):
```json
{
  "modelName": "anthropic/claude-3.5-sonnet",
  "temperature": 0.5
}
```
- Best for complex reasoning
- Structured outputs
- Higher cost

**Via OpenRouter** (specific model):
```json
{
  "modelName": "anthropic/claude-3.5-sonnet:beta",
  "temperature": 0.7
}
```
- Access any OpenRouter model
- Billing through OpenRouter
- Flexible provider switching

---

## Memory System

### Memory File Types

```
task_result   - Agent execution outputs
daily_log     - Daily notes/observations
long_term     - Persistent facts/preferences
brainstorm    - Planning and ideation
project       - Project-specific docs
```

### FTS5 Search Tips

**Basic search:**
```json
{"query": "API documentation"}
```

**Phrase search:**
```json
{"query": "\"REST API\""}
```

**Multiple terms (AND):**
```json
{"query": "API authentication security"}
```

**Boost recent results:**
Sort by `createdAt` after search:
```python
results = search_memory(agent_id, query)
results.sort(key=lambda r: r['fileId'], reverse=True)
```

### Memory Isolation

Each agent has independent memory:
- Agent 1 cannot see Agent 2's files
- Database query filters by `agentId`
- Workspace directories are separate

**Sharing memory between agents:**
Currently not supported. Workaround:
1. Agent A writes to memory
2. You retrieve it via API
3. You pass context to Agent B's task

---

## Tools & Execution

### Available Tools

**File Tool** (built-in):
- Create files in agent workspace
- Modify existing files
- Read file contents

### Tool Lifecycle

```
1. Agent decides to use tool
2. BeforeToolExecution hook (optional)
3. Tool executes
4. AfterToolExecution hook (optional)
5. Result added to context
6. Agent continues or finishes
```

### Tool Hooks Example

```go
// Rate limiting with hooks
config := runner.Config{
    BeforeToolExecution: func(ctx context.Context, call ToolCall) error {
        if callCount >= maxCalls {
            return errors.New("too many tool calls")
        }
        callCount++
        return nil
    },
    
    AfterToolExecution: func(ctx context.Context, result ToolResult) (ToolResult, error) {
        // Transform result
        result.Output = fmt.Sprintf("[%s] %s", time.Now(), result.Output)
        return result, nil
    },
}
```

**Use cases:**
- Rate limiting (max calls per task)
- Validation (check arguments)
- Transformation (modify results)
- Logging (track usage)
- Cost control (prevent expensive operations)

### Steering (Human-in-the-Loop)

```go
config := runner.Config{
    GetSteeringMessages: func(ctx context.Context) ([]Message, error) {
        // Check for user interruption
        if userWantsToStop() {
            return []Message{{
                Role: "user",
                Content: "Please stop execution now."
            }}, nil
        }
        return nil, nil
    },
}
```

When steering message is injected:
- Remaining tools are skipped
- Agent receives interruption message
- Agent can acknowledge and wrap up

---

## Scheduled Tasks

### Cron Expression Reference

**6-field format** (includes seconds):

```
0 0 9 * * *    # Every day at 9:00:00 AM
0 */30 * * * * # Every 30 minutes
0 0 * * * 1    # Every Monday at midnight
0 0 0 1 * *    # First day of every month at midnight
```

**Common schedules:**

| Description | Expression |
|-------------|------------|
| Every minute | `0 * * * * *` |
| Every hour | `0 0 * * * *` |
| Daily at 9 AM | `0 0 9 * * *` |
| Weekly (Monday 9 AM) | `0 0 9 * * 1` |
| Monthly (1st, 9 AM) | `0 0 9 1 * *` |

### Monitoring Scheduled Tasks

```python
def check_task_health(task_id):
    task = requests.get(
        f"{BASE_URL}/scheduled-tasks/{task_id}",
        headers={"Authorization": f"Bearer {API_KEY}"}
    ).json()
    
    executions = requests.get(
        f"{BASE_URL}/scheduled-tasks/{task_id}/executions",
        headers={"Authorization": f"Bearer {API_KEY}"}
    ).json()
    
    total = executions['total']
    if total == 0:
        return "No executions yet"
    
    successes = sum(
        1 for e in executions['executions']
        if e['status'] == 'success'
    )
    
    success_rate = successes / total
    
    if success_rate < 0.9:
        return f"WARNING: Success rate {success_rate:.1%}"
    
    return f"Healthy: {success_rate:.1%} success rate"
```

---

## Multi-Agent Coordination

### Sequential Pattern (Tests 1-12)

```python
# Research → Draft → Review pipeline
def sequential_workflow():
    # Phase 1: Research
    research = run_task(agent_id=2, task="Research topic")
    
    # Phase 2: Draft
    draft = run_task(agent_id=3, task="Create draft")
    
    # Phase 3: Review
    review = run_task(agent_id=4, task="Summarize")
    
    return (research, draft, review)
```

**Pros:**
- Simple to implement
- Easy to debug
- No race conditions

**Cons:**
- Can't parallelize
- Total time = sum of phase times

### Parallel Pattern (Future)

```python
import asyncio

async def parallel_research(topic):
    tasks = [
        run_task_async(2, f"Research {topic} from perspective A"),
        run_task_async(3, f"Research {topic} from perspective B"),
        run_task_async(4, f"Research {topic} from perspective C"),
    ]
    
    results = await asyncio.gather(*tasks)
    return results
```

**Pros:**
- Faster (parallel execution)
- Scales to many agents

**Cons:**
- More complex
- Requires async support
- Potential API rate limiting

### Choosing Agents by Task Type

```python
def route_task(task_content):
    if 'documentation' in task_content.lower():
        return 2  # Technical Writer
    elif 'summary' in task_content.lower():
        return 4  # Concise Expert
    elif 'tutorial' in task_content.lower():
        return 3  # Friendly Coder
    else:
        return 1  # Default agent

agent_id = route_task("Create API documentation")
result = run_task(agent_id, task)
```

---

## Event-Driven UIs

### Polling-Based Updates

**Simple polling (2-second interval):**

```javascript
class AgentMonitor {
  constructor(agentId, apiKey) {
    this.agentId = agentId;
    this.apiKey = apiKey;
    this.lastCount = 0;
  }
  
  async start(callback) {
    setInterval(async () => {
      const files = await this.getMemoryFiles();
      
      if (files.length > this.lastCount) {
        const newFiles = files.slice(this.lastCount);
        newFiles.forEach(callback);
        this.lastCount = files.length;
      }
    }, 2000);
  }
  
  async getMemoryFiles() {
    const response = await fetch(
      `/api/v1/agents/${this.agentId}/memory/files`,
      {
        headers: {
          'Authorization': `Bearer ${this.apiKey}`
        }
      }
    );
    const data = await response.json();
    return data.files || [];
  }
}

// Usage
const monitor = new AgentMonitor(1, API_KEY);
monitor.start(file => {
  console.log(`New file: ${file.path}`);
  displayInUI(file);
});
```

**Adaptive polling (slow down when idle):**

```javascript
let interval = 2000; // Start at 2 seconds

function adaptivePoll() {
  checkForUpdates().then(hasUpdates => {
    if (hasUpdates) {
      interval = 2000; // Speed up when active
    } else {
      interval = Math.min(interval * 1.5, 30000); // Slow down, max 30s
    }
    
    setTimeout(adaptivePoll, interval);
  });
}
```

---

## Error Handling

### API Error Response Format

**Structured (preferred):**
```json
{
  "error": {
    "code": "MISSING_FIELD",
    "message": "Missing required field: scheduleExpr",
    "details": {
      "field": "scheduleExpr",
      "expected": "Cron expression (6 fields)"
    }
  }
}
```

**Simple (some endpoints):**
```json
{
  "error": "agent not found"
}
```

### HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success | Task completed |
| 401 | Unauthorized | Invalid API key |
| 404 | Not Found | Agent doesn't exist |
| 400 | Bad Request | Missing field |
| 500 | Server Error | Internal failure |

### Error Handling Pattern

```python
def safe_api_call(func, *args, **kwargs):
    try:
        response = func(*args, **kwargs)
        response.raise_for_status()
        return response.json()
    except requests.HTTPError as e:
        if e.response.status_code == 404:
            print("Resource not found")
        elif e.response.status_code == 401:
            print("Authentication failed")
        else:
            print(f"API error: {e.response.text}")
        return None
    except requests.RequestException as e:
        print(f"Network error: {e}")
        return None

# Usage
result = safe_api_call(
    requests.post,
    f"{BASE_URL}/agents/1/run-once",
    headers={"Authorization": f"Bearer {API_KEY}"},
    json={"task": "Test task"}
)
```

---

## Best Practices

### 1. Always Handle Empty State

```python
# BAD: Assumes files exist
latest = files['files'][0]

# GOOD: Check first
files_list = files.get('files', [])
if not files_list:
    print("No files yet")
    return None
latest = files_list[0]
```

### 2. Sort by Timestamp, Not Array Position

```python
# BAD: Gets first by ID
latest = files['files'][0]

# GOOD: Gets latest by creation time
latest = sorted(
    files['files'],
    key=lambda f: f['createdAt'],
    reverse=True
)[0]
```

### 3. Use Structured Error Responses

```python
# In your API wrapper
def parse_error(response):
    error_data = response.json()
    if isinstance(error_data.get('error'), dict):
        # Structured error
        return error_data['error']['message']
    else:
        # Simple error
        return str(error_data.get('error', 'Unknown error'))
```

### 4. Implement Retry Logic

```python
def retry(func, max_attempts=3, delay=1):
    for attempt in range(max_attempts):
        try:
            return func()
        except Exception as e:
            if attempt < max_attempts - 1:
                time.sleep(delay * (attempt + 1))
            else:
                raise
```

### 5. Monitor Scheduled Task Health

```python
# Check success rate every hour
def monitor_scheduled_tasks():
    tasks = get_all_scheduled_tasks()
    for task in tasks:
        executions = get_executions(task['id'])
        success_rate = calculate_success_rate(executions)
        
        if success_rate < 0.90:
            alert(f"Task {task['name']} failing: {success_rate:.1%}")
```

### 6. Use 6-Field Cron Expressions

```python
# WRONG (5 fields - will fail)
"* * * * *"

# RIGHT (6 fields with seconds)
"0 * * * * *"  # Every minute at second 0
```

### 7. Separate Secrets from Config

```yaml
# config.yaml (committed)
env_file: /etc/bommalata/secrets.env

# secrets.env (NOT committed, mode 600)
OPENROUTER_API_KEY=sk-or-v1-...
```

### 8. Validate Response Content

```python
def validate_task_response(task_keywords, response):
    content = response.get('content', '').lower()
    matches = any(kw.lower() in content for kw in task_keywords)
    
    if not matches:
        logging.warning("Response may not match task")
    
    return response
```

---

## Troubleshooting

### Server Won't Start

**Error:** `no such table: memory_fts`

**Cause:** SQLite built without FTS5 support

**Solution:**
```bash
# Rebuild with FTS5 tag
go build -tags fts5 -o bommalata ./cmd/server
```

### Scheduled Task Not Executing

**Check 1:** Verify cron expression format (6 fields)
```bash
# Wrong
"0 9 * * *"

# Right
"0 0 9 * * *"
```

**Check 2:** Check enabled status
```bash
curl .../scheduled-tasks/1 | jq '.enabled'
# Should be: true
```

**Check 3:** Check next run time
```bash
curl .../scheduled-tasks/1 | jq '.nextRunAt'
# Should be in the future
```

### Empty Memory Files

**Issue:** `files[0]` is null or undefined

**Cause:** Agent has no execution history yet

**Solution:**
```javascript
const files = response.files || [];
if (files.length === 0) {
  console.log('No memory files yet');
  return;
}
const latest = files[0];
```

### Wrong Task Result Retrieved

**Issue:** Getting old results instead of latest

**Cause:** Array not sorted by timestamp

**Solution:**
```python
latest = sorted(
    files['files'],
    key=lambda f: f['createdAt'],
    reverse=True
)[0]
```

### Rate Limiting / Slow Responses

**Cause:** Multiple agents calling expensive models

**Solution 1:** Use cheaper models for simple tasks
```json
{
  "modelName": "openrouter/auto",  // Auto-routes to cheaper models
  "temperature": 0.7
}
```

**Solution 2:** Implement tool hooks for rate limiting
```go
BeforeToolExecution: func(ctx, call) error {
    if callCount >= maxCalls {
        return errors.New("rate limit exceeded")
    }
    callCount++
    return nil
}
```

---

## Next Steps

1. **Read Test Documentation:** See `demo-results/test-*.md` for detailed examples
2. **Review Lessons Learned:** `LESSONS-LEARNED.md` for gotchas and best practices
3. **Check Executive Summary:** `SUMMARY.md` for production readiness assessment
4. **Explore API:** Test endpoints with `curl` or Postman
5. **Build Client:** Use patterns from this guide to build your integration

---

## Additional Resources

- **Source Code:** https://github.com/antahkarana/bommalata
- **Test Results:** `/demo-results/test-*.md` (15 files, ~115KB)
- **API Examples:** All test scripts in `/demo-tests/`
- **Configuration:** Example configs in `/config/`

---

## Getting Help

1. **Check test documentation** - Most questions answered in test result files
2. **Review error messages** - Error details include field expectations
3. **Validate assumptions** - Empty state, sorting, 6-field cron common issues
4. **Check build flags** - `-tags fts5` required for compilation

---

**Version:** 1.0  
**Last Updated:** March 16, 2026  
**Based on:** 12 integration tests, 100% success rate  
**Status:** Production-ready guide
