# Bommalāṭa - Agent Orchestration Server

**Repository:** `antahkarana/bommalata`  
**Location:** `projects/bommalata/`  
**Status:** Active development (Phase D complete, Phase E next)  
**Branch:** `feat/agent-config` (ready for PR to dev)  
**Language:** Go  
**Started:** Feb 2026

## Overview

Bommalāṭa (Telugu: బొమ్మలాట, "shadow puppet theater") is a lightweight Go HTTP server for orchestrating agent workflows and automation tasks. Named after traditional Telugu shadow puppet art, reflecting behind-the-scenes orchestration of multiple agents.

## Purpose

Provides structured API layer for:
- Agent task coordination and status tracking
- Workflow orchestration across multiple agent sessions
- Integration endpoints for external services (GitHub, RSS, etc.)
- State management for long-running automation tasks
- Multi-user agent hosting with isolation

## Architecture

- **Server:** Go with Chi router
- **Database:** SQLite with FTS5 for full-text search
- **State:** Write-through cache for performance
- **Auth:** API key authentication with user isolation
- **Migration System:** Idempotent SQL migrations with rollback support

## Development Phases

### Phase 1: Foundation ✅ Complete
- Basic HTTP server with Chi router
- Documentation cleanup
- Basic endpoints (`/ping`, `/health`)

### Phase 2: Agent Features ✅ Complete
- Session management API
- Task queue implementation
- Webhook management

### Phase 3: Model Provider Integration ✅ Complete
- Anthropic, OpenAI, Google providers
- Budget manager, fallback chain
- Context optimization

### Phase 4: Multi-User Auth ✅ Complete
- API key authentication
- User isolation
- Auth middleware

### Phase A: Session Persistence ✅ Complete (Feb 28)
- SQLite database with migrations
- Write-through cache
- Session recovery on restart
- Test coverage 85%+
- **Status:** Merged to dev (PR #11)

### Phase B: Memory System ✅ Complete (Feb 28)
- Hybrid storage (Markdown + SQLite)
- FTS5 search with BM25 ranking
- Chunking strategy, daily logs
- Human profiles with consent tracking

### Phase C: Identity & Persona ✅ Complete (Mar 1)
- Agent profiles (identity, models, tools)
- Persona file management (SOUL.md, AGENTS.md, etc.)
- Full CRUD API
- Server startup fixed, all tests passing
- **Status:** Merged to dev (PR #14)

### Phase D: Tools & Runner ✅ Complete (Mar 11)
- Tool registry with file tool
- Anthropic & OpenRouter providers with tool use
- Agent runner with tool execution loop
- Runner endpoints (run-once/start/stop)
- Full logging (model selection, tool args, tokens)
- **Test verified:** Task → tool calls → file creation
- **Branch:** `feat/agent-config`

### Phase E: Scheduled Tasks 🔜 Next
- Cron system for workflows
- Heartbeat scheduling
- Recurring task support

### Phase F: Full Migration (Week 5+)
- Connect message channels
- RSS integration
- GitHub webhooks
- Parallel run with OpenClaw
- Cutover to bommalata

## Related Projects

**bomma-cliclient** (`projects/bomma-cliclient/`)
- Python CLI client for bommalata API
- Repository: `antahkarana/bomma-cliclient`
- Commands: sessions, tasks, health check
- Config: `~/.config/bomma/config.toml`
- Uses uv for dependency management

## Migration Context

Bommalata is the target platform for migrating Smriti from OpenClaw. Goal: self-hosted agent orchestration with full control over memory, scheduling, and identity.

**Migration Plan:** See `brainstorming/smriti-on-bommalata-requirements.md`  
**Timeline:** 4-week phased migration (currently in Phase C)

## Quick Start

```bash
# Enter Nix dev shell
nix develop .#simpleGo

# Run server
go run cmd/server/main.go

# Run tests
go test ./...

# Build
nix build
```

## Known Issues

- **Issue #13:** PR #11 deferred items (shutdown ordering, cache-DB ordering, benchmarks)
- **Issue #9:** Session handler improvements (tech debt from PR #8)
- **Issue #6:** SQL treefmt formatter disabled

## Next Steps

- Phase D: Scheduled tasks and cron system
- Message channel integration
- RSS aggregator integration
- GitHub webhook handling
