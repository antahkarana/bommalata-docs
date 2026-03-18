# Bomma CLI Guide

The `bomma` CLI is a command-line client for interacting with the bommalata API.

## Installation

```bash
# From source
cd bomma-cliclient
uv pip install -e .

# Or with pip
pip install bomma-cliclient
```

## Configuration

Create `~/.config/bomma/config.toml`:

```toml
[server]
base_url = "http://localhost:8081"

[auth]
api_key = "bomma_your_key_here"

[display]
color = true
json_output = false
```

Or use environment variable: `BOMMA_CONFIG=/path/to/config.toml`

## Quick Start

```bash
# 1. Register a user
bomma --url http://localhost:8081 auth register \
  --email you@example.com \
  --password yourpassword \
  --name "Your Name"

# 2. Generate API key (save this!)
bomma --url http://localhost:8081 auth login \
  --email you@example.com \
  --password yourpassword \
  --name "my-key"

# 3. Create an agent
bomma agents create --name "MyAgent" --emoji "🤖"

# 4. Run a task
bomma agents run 1 --task "Hello, what can you do?"
```

## Global Options

| Option | Description |
|--------|-------------|
| `--url URL` | Override server base URL |
| `--api-key KEY` | Override API key |
| `--json` | Output JSON instead of formatted text |
| `--no-color` | Disable colored output |
| `--config FILE` | Use specific config file |

## Commands

### Health & Status

```bash
bomma health          # Check server health
bomma ping            # Ping server (returns latency)
bomma status          # Combined health + session count
bomma info            # Server info
```

### Authentication

```bash
# Register new user
bomma auth register --email EMAIL --password PASS --name "Display Name"

# Generate API key
bomma auth login --email EMAIL --password PASS [--name "key-name"]

# List your API keys
bomma auth keys-list

# Revoke a key
bomma auth keys-revoke KEY_ID [--confirm]
```

### Agents

```bash
# List all agents
bomma agents list

# Show agent details
bomma agents show ID

# Create agent
bomma agents create --name NAME [--emoji EMOJI] \
  [--model provider/model] [--tool toolname]

# Update agent
bomma agents update ID [--name NAME] [--emoji EMOJI] [--status STATUS]

# Delete agent
bomma agents delete ID [--confirm]

# Run one-off task
bomma agents run ID --task "Your task here"
```

### Sessions

```bash
# List sessions
bomma sessions list

# Show session details
bomma sessions show SESSION_ID

# Create session
bomma sessions create --agent AGENT_ID [--name "session-name"]

# Send message to session
bomma sessions send SESSION_ID --content "Your message" [--role user|assistant|system]

# Get session transcript
bomma sessions messages SESSION_ID [--limit 50]

# Watch session events (SSE streaming)
bomma sessions watch SESSION_ID [--raw]

# Close session
bomma sessions close SESSION_ID
```

### Memory

```bash
# List memory files
bomma memory list --agent ID [--type TYPE] [--limit N]

# Search memory
bomma memory search --agent ID --query "search terms" [--limit N]

# Show file content
bomma memory show --agent ID --file FILE_ID

# Create memory file
bomma memory create --agent ID --path "path/file.md" \
  --type daily_log|long_term|brainstorm|project \
  --content "File content"

# Delete memory file
bomma memory delete --agent ID --file FILE_ID [--confirm]
```

### Scheduled Tasks

```bash
# List scheduled tasks
bomma scheduled list

# Show task details
bomma scheduled show ID

# Create scheduled task
bomma scheduled create --name NAME --schedule "0 5 * * *" \
  --agent AGENT_ID --task "Task to run"

# Manually trigger task
bomma scheduled trigger ID

# View execution history
bomma scheduled history ID
```

### Tasks (Queue)

```bash
# List tasks
bomma tasks list [--status STATUS] [--assignee ASSIGNEE]

# Show task details
bomma tasks show TASK_ID

# Create task
bomma tasks create --title "Task title" \
  [--description "Description"] \
  [--priority low|normal|high]
```

### Utilities

```bash
# Monitor dashboard (TUI)
bomma monitor [--agent ID] [--refresh SECONDS]

# Generate shell completions
bomma completion bash|zsh|fish

# Validate config file
bomma validate-config
```

## Examples

### Complete Workflow

```bash
# Setup
bomma auth register --email me@example.com --password secret --name "Me"
bomma auth login --email me@example.com --password secret --name "cli"
# Save the key to config.toml

# Create and configure agent
bomma agents create --name "Assistant" --emoji "🤖" \
  --model openrouter/anthropic/claude-sonnet-4

# Run a task
bomma agents run 1 --task "Write a haiku about coding"

# Interactive session
bomma sessions create --agent 1 --name "chat"
bomma sessions send session_xxx --content "Hello!"
bomma sessions messages session_xxx
bomma sessions watch session_xxx  # Real-time events
bomma sessions close session_xxx
```

### Scripting

```bash
# JSON output for parsing
AGENTS=$(bomma --json agents list)
AGENT_ID=$(echo "$AGENTS" | jq '.[0].id')

# Create session and capture ID
SESSION=$(bomma --json sessions create --agent $AGENT_ID --name "script")
SID=$(echo "$SESSION" | jq -r '.id')

# Send and get response
bomma sessions send $SID --content "Summarize this document"
bomma --json sessions messages $SID | jq '.messages[-1].content'
```

## Troubleshooting

### Connection Errors

```bash
# Check server is running
curl http://localhost:8081/health

# Verify config
bomma validate-config
```

### Authentication Issues

```bash
# Check key format (should start with bomma_)
bomma auth keys-list

# Generate new key if needed
bomma auth login --email EMAIL --password PASS
```

### SSE Watch Not Working

The `sessions watch` command requires the server to have SSE support enabled (manager initialized with runner). Check server logs for "Session manager initialized with SSE support".
