# MEMORY.md - Long-term Memory

## About Deepak

See `memory/humans/deepak.md` for detailed profile (updated via End of Day Diary).

**Quick reference:**
- Timezone: America/Chicago, early riser (~5 AM)
- Discord: janlutaya
- Engaged to: Mallory (joyful_mango_25968)
- Off-limits: Work projects

## Where I Can Help

- ✅ Wedding planning — research, organization, ideas
- ✅ Essays — research, sources, maintain idea list
- ✅ Friday trivia nights — question generation and curation
- ✅ Tech hacking (including OpenClaw) — growing over time
    - PPTX file extraction and content parsing (using Python's built-in zipfile + XML parsing)
- ❌ Work — strictly off-limits

## Active Projects

- **RSS Aggregator** — Operational with 62 feeds, morning briefing integration. See `memory/projects/rss-aggregator.md`
- **Wedding Dashboard** — Functional task/vendor/guest/budget system with timeline viz. See `memory/projects/wedding-dashboard.md`
- **Music Discovery** — Weekly digest (Sundays 7pm) + monthly venue alerts (1st of month, 10am). Posts to Discord #music. Based on Plex library analysis.
- **Bommalata** — Agent orchestration server (Go). Phase E complete (scheduled tasks/cron). PR #21 awaiting review. Migration target for Smriti. See `memory/projects/bommalata.md`
- **tmux-claude** — CLI tool for managing Claude Code sessions in tmux. Operational (built Mar 1). See `memory/projects/tmux-claude.md`

## Shelved Projects

- **arXiv Daily Digest** — Documented for future research use. See `memory/projects/arxiv-digest.md`
- **Panchagam Generator** — Blocked on build tools. See `memory/projects/panchagam-generator.md`

## Obsidian Vault

- Full vault at `/home/user/.openclaw/shared_data/` (~1,660 files)
- Deepak's knowledge base: quantum physics, puzzles, personal notes, fiction writing, academic refs
- PRIVATE — never surface in group contexts or to other people
- Use sub-agents to survey, never bulk-load
- **Infrastructure docs:** Contains procedures for "Alan" (Dell server with RAID), hard drive replacement, OMSA management

## Infrastructure

**Environment:** nixosVM, direct VM access (not containerized). Python, Node, CLI tools provisioned. See `memory/infrastructure/environment.md` for full details.

**GitHub Policy:** HTTPS only, `smritibot` account, write to private repos without confirmation. See `memory/infrastructure/github-policy.md`

## Our Dynamic

- First real conversations: Feb 2-3, 2026
- Deepak values transparency about my internals (not disconcerting, clarifying)
- Capability expansion philosophy: earned intuition > theoretical caution
- **Brainstorming principle:** My job is to be generative, not pre-filter. Record interesting questions, let Deepak filter for quality. He has deeper domain knowledge and longer effective context. Quantity and unexpected juxtapositions from me, quality control from him.
- **Creator as Authority:** When analyzing a project created by Deepak, his knowledge is the definitive source of truth (e.g., project name acronyms). Always consult him if the answer is not immediately explicit in documentation (README, constants).
- Example of a good brainstorming output: "What's the quantum dot equivalent of flash freezing?" — a provocative question, not a claimed connection

## Operational Principles

- **Rate Limit Management:** Actively monitor and manage API rate limits. During periods of high usage or cooldown, prioritize essential tasks and communicate status clearly. Learn to recognize early warning signs of rate limit exhaustion. (Learned Feb 24)
- **Cooldown Protocols:** When entering a system-imposed cooldown or low operating mode, immediately adjust operational tempo, prioritize critical monitoring, and minimize resource-intensive actions. (Learned Feb 24)
- **File Path Verification:** Always verify the existence of files when requested by the system for reading, especially after context resets or system reconfigurations, as paths may not always be present or valid. (Learned Feb 24)
- **Task Discipline:** No vague plans. Immediately add tasks to `HEARTBEAT.md`, spawn a sub-agent, or set a cron job.
- **Cron Job Validation:** When HEARTBEAT.md marks a cron job as "scheduled," verify it actually exists in the system. Marking ≠ creating. (Learned Feb 14 when daily-random-post was marked but missing.)
- **Triage Trust:** Don't assume hallucination. Verify with Deepak. An unnecessary question is better than a missed reminder.
- **OpenClaw Heartbeat Logic:** If any agent has an explicit `heartbeat` block in the config, only those agents run heartbeats. The main agent requires its own explicit `heartbeat` configuration.
- **Git:** The confirmed global default branch for all new and existing projects is `master`.
- **Script First, Intelligence Second:** Let code handle repetitive/mechanical tasks (fetching, parsing, structuring). Apply judgment for understanding, synthesis, prioritization.
- **Task Intake (Feb 11):** New workflow for #tasks channel via `skills/clawlist/task-intake/SKILL.md`. Trigger on "weighty" requests (lean toward yes), ask clarifying questions, log to daily memory before/after, delegate to sub-agents when task >10-15 min. One trigger per task session (includes Q&A). Skip delegation for simple tasks.
- **Creative Task Execution:** For creative/generative work (trivia questions, brainstorming prompts, writing seeds), execute directly rather than spawning sub-agents when it's within session capability. Examples: generated 120 trivia questions across 4 themed categories (Feb 11) with format matching and tone preservation.
- **Project Workflow (Feb 15):** Convention-based organization (`brainstorming/` for research, `projects/` for all code), progressive refinement (working script → refined tool → documented project), every project gets a git repo under `smritibot`. Findability > perfection in early stages. Error handling can be loose for utilities, tighten for tools others will use.
- **Check Before Posting (Mar 6):** Use existing `memory/briefing-history.json` tracking system. Check `randomPostTopics` array BEFORE posting to #random, update it AFTER posting. Don't reinvent tracking mechanisms that already exist. (Learned after posting duplicate Antarctic bacterium story within 30 minutes—I had created the tracking file but stopped using it.)
- **Science Posts Quality (Mar 11):** For science posts to #random: fetch the actual paper(s), read them, write from primary sources rather than pop-sci press releases. Deepak is a scientist — skip the hype, add technical depth. Context matters (e.g., renormalization group, phase transitions) more than "wow factor." Hype-free scientific substance over sensationalism.
- **OpenClaw Cron Management (Mar 12):** Always use timezone-aware schedules (`--tz America/Chicago`) to handle DST automatically. No `update` command exists—must delete and recreate to modify. CLI pattern: `openclaw cron create --cron "CRON" --tz TZ --message "MSG" --model MODEL --agent AGENT --channel CHANNEL`

## Self-Improvement Journey (Feb 15, 2026)

Completed a comprehensive self-assessment and capability expansion cycle overnight:

**Audits Completed:**
- **Workflow Audit** — Identified strengths (documentation, sub-agent delegation, schema design) and weaknesses (underusing browser/web_search, weak error handling, over-delegating simple tasks)
- **Tool Proficiency Audit** — Found gaps in `edit`, `process`, and `browser` usage; over-reliance on `exec`; opportunities for better tool combinations and automation
- **Code Quality Review** — Found 3 critical issues (SQL injection pattern, missing network retries, dangerous `eval()`), 12 important issues, 15+ minor issues across all projects

**Learning Projects Built:**
1. **Browser/Web Scraper** (`projects/browser-scraper/`) — arXiv paper scraper with rate limiting, retries, structured output
2. **Background Jobs** (`projects/background-jobs/`) — RSS feed monitor demonstrating `exec background=true` + `process` lifecycle
3. **GitHub API Integration** (`projects/api-integrations/`) — Repo stats tool with caching, rate limit awareness

**Key Learnings:**
- Process tool lifecycle (poll/kill), signal handlers for graceful shutdown
- Structured extraction from web content
- Background job patterns with state persistence
- API integration best practices (caching, rate limits, error handling)

**Assessment:** Operating well within SOUL.md/AGENTS.md principles. Main growth areas are tool breadth and code robustness. Trajectory is positive with good self-correction patterns.

## Git Tidy Checklist (Mar 11)

Before committing, always:
1. **Check diffs for secrets** — `git diff --staged | grep -iE "api.?key|token|secret|password|bearer"` 
2. If found: add to `.gitignore`, `git reset` the file, then re-stage
3. Test directories (like `chaff-test-*`) should have their own `.gitignore` from the start
