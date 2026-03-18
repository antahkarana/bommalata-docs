# Bommalata Demo Playbook V2

**Date:** March 17, 2026  
**Focus:** SSE Event Streaming, Session API, CLI Workflows

## Prerequisites

- Staging server running at `http://localhost:8081`
- Fresh database with user registered
- `bomma` CLI installed and configured

## Test Matrix

| # | Test | Features | Status |
|---|------|----------|--------|
| 1 | CLI Auth Flow | register, login, keys | |
| 2 | Agent Management via CLI | create, list, show, update | |
| 3 | Session Lifecycle | create, send, messages, close | |
| 4 | SSE Event Streaming | watch, real-time events | |
| 5 | Agent Run with Events | run-once + watch | |
| 6 | Memory Operations | list, create, search | |
| 7 | Multi-turn Conversation | session steering | |
| 8 | Scheduled Tasks | create, trigger, history | |

---

## Test 1: CLI Authentication Flow

### Steps
```bash
# Already done during setup, verify it works
bomma --url http://localhost:8081 auth keys-list
```

### Expected
- Lists API keys for authenticated user

---

## Test 2: Agent Management via CLI

### Steps
```bash
# List agents
bomma agents list

# Create new agent with model
bomma agents create --name "DemoAgent" --emoji "🎯" \
  --model openrouter/anthropic/claude-sonnet-4

# Show agent details
bomma agents show 2

# Update agent
bomma agents update 2 --emoji "🚀"
```

### Expected
- Agent created with ID
- Details show model configuration
- Emoji updated

---

## Test 3: Session Lifecycle

### Steps
```bash
# Create session
bomma sessions create --agent 1 --name "demo-session"

# Send messages
bomma sessions send SESSION_ID --content "Hello! What's 2+2?"
bomma sessions send SESSION_ID --content "4" --role assistant
bomma sessions send SESSION_ID --content "And what's 3+3?"

# Get transcript
bomma sessions messages SESSION_ID

# Close session
bomma sessions close SESSION_ID
bomma sessions show SESSION_ID  # Verify closed status
```

### Expected
- Session created with event stream URL
- Messages stored and retrievable
- Transcript shows conversation
- Status changes to "closed"

---

## Test 4: SSE Event Streaming

### Steps
```bash
# Create session for watching
bomma sessions create --agent 1 --name "sse-demo"

# In terminal 1: Watch session
bomma sessions watch SESSION_ID

# In terminal 2: Send messages
bomma sessions send SESSION_ID --content "Tell me a joke"
```

### Expected
- Watch shows "Connected" event
- Events stream as messages are sent
- Real-time display of session activity

---

## Test 5: Agent Run with Events

### Steps
```bash
# Create session
bomma sessions create --agent 1 --name "run-demo"

# Start watching in background or split terminal
bomma sessions watch SESSION_ID &

# Run a task that triggers agent processing
bomma agents run 1 --task "Write a haiku about computers"
```

### Expected
- Events show: agent_start, turn_start, message_update, turn_end, agent_end
- Haiku returned in output

---

## Test 6: Memory Operations

### Steps
```bash
# Create memory file
bomma memory create --agent 1 --path "notes/demo.md" \
  --type brainstorm --content "# Demo Notes\n\nThis is a test file."

# List files
bomma memory list --agent 1

# Search
bomma memory search --agent 1 --query "demo test"

# Show content
bomma memory show --agent 1 --file FILE_ID
```

### Expected
- File created with word count
- Search returns relevant results
- Content displayed correctly

---

## Test 7: Multi-turn Conversation

### Steps
```bash
# Create session
bomma sessions create --agent 1 --name "conversation"

# Multi-turn exchange
bomma sessions send $SID --content "Let's play a word game. I say a word, you say a related word."
bomma sessions send $SID --content "Great! Here's my word: ocean" 
bomma sessions send $SID --content "Nice! My turn: sunset"

# View full conversation
bomma sessions messages $SID
```

### Expected
- Session maintains context
- Each message builds on previous
- Full transcript available

---

## Test 8: Scheduled Tasks

### Steps
```bash
# Create scheduled task
bomma scheduled create --name "demo-task" \
  --schedule "0 * * * * *" \
  --agent 1 --task "Say hello"

# List tasks
bomma scheduled list

# Manual trigger
bomma scheduled trigger TASK_ID

# View history
bomma scheduled history TASK_ID
```

### Expected
- Task created with next run time
- Manual trigger executes
- History shows execution record

---

## Summary Checklist

- [ ] Auth flow works
- [ ] Agent CRUD via CLI
- [ ] Session create/send/messages/close
- [ ] SSE watch shows events
- [ ] Agent run produces output
- [ ] Memory CRUD + search
- [ ] Multi-turn conversations
- [ ] Scheduled task lifecycle
