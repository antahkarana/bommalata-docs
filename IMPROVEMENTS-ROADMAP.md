# Bommalata Improvements Roadmap

**Source:** Demo learnings (Tests 1-12)  
**Date:** March 16, 2026  
**Status:** Production-ready, improvements for hardening + features

---

## 🚨 High Priority (Production Hardening)

### 1. Error Format Standardization
**Issue:** Mix of structured/simple error formats  
**Impact:** Inconsistent client error handling  
**Effort:** 2-3 hours

**Tasks:**
- [ ] Standardize all HTTP errors to `{"error": {"code": "...", "message": "..."}}`
- [ ] Add error codes enum (NOT_FOUND, UNAUTHORIZED, VALIDATION_ERROR, etc.)
- [ ] Update all handler functions
- [ ] Add integration tests for error responses
- [ ] Update bomma-cliclient to handle structured errors

**Acceptance:** All API endpoints return consistent error format

---

### 2. Retry Logic for Tasks
**Issue:** Tasks fail permanently on transient errors  
**Impact:** Poor user experience for network/provider issues  
**Effort:** 4-6 hours

**Tasks:**
- [ ] Add retry configuration (max retries, backoff strategy)
- [ ] Implement exponential backoff
- [ ] Track retry attempts in database
- [ ] Add retry status to task execution history
- [ ] Test with simulated network failures
- [ ] Update API to expose retry status

**Acceptance:** Tasks automatically retry with backoff, user sees retry history

---

### 3. Secret Management
**Issue:** API keys in config file (Test 1 discovery)  
**Impact:** Security risk if config committed to git  
**Status:** ✅ Partially solved (env_file support exists)  
**Effort:** 1-2 hours

**Tasks:**
- [ ] Document env_file configuration prominently
- [ ] Add example `.env` file with all provider keys
- [ ] Validate that API keys never appear in config YAML
- [ ] Add security checklist to deployment docs
- [ ] Test config validation for missing secrets

**Acceptance:** Clear documentation, example files, validation warnings

---

### 4. Cron Format Documentation
**Issue:** 6-field cron format non-standard (Test 9 discovery)  
**Impact:** User confusion  
**Effort:** 1 hour

**Tasks:**
- [ ] Document 6-field format in API docs
- [ ] Add examples with seconds field
- [ ] Show comparison with standard 5-field format
- [ ] Add validation errors that explain format
- [ ] Update bomma-cliclient help text

**Acceptance:** Users understand 6-field format before first use

---

## ⚠️ Medium Priority (Robustness)

### 5. Concurrent Execution Testing
**Issue:** Only sequential execution tested  
**Impact:** Unknown behavior under load  
**Effort:** 3-4 hours

**Tasks:**
- [ ] Create test with 10+ simultaneous tasks
- [ ] Test scheduled tasks firing at same time
- [ ] Verify database locking/transactions
- [ ] Check memory isolation under concurrent access
- [ ] Monitor goroutine leaks
- [ ] Test provider API rate limiting

**Acceptance:** System handles 10+ concurrent tasks without errors

---

### 6. Network Failure Handling
**Issue:** Provider API failures not tested  
**Impact:** Unknown recovery behavior  
**Effort:** 2-3 hours

**Tasks:**
- [ ] Test with provider timeout (mock)
- [ ] Test with provider 500 error
- [ ] Test with provider rate limit
- [ ] Verify graceful degradation
- [ ] Add fallback provider configuration
- [ ] Document failure modes

**Acceptance:** System degrades gracefully, logs useful errors

---

### 7. Large Workflow Testing
**Issue:** Tested small workflows (38 files max)  
**Impact:** Performance unknown at scale  
**Effort:** 2-3 hours

**Tasks:**
- [ ] Create test with 1000+ memory files
- [ ] Test FTS5 search performance at scale
- [ ] Test agent response with large context
- [ ] Monitor memory usage growth
- [ ] Test database size limits
- [ ] Add pagination to memory list API

**Acceptance:** System handles 1000+ files with <2s search times

---

## 🚀 New Features (Enhancement)

### 8. Advanced Tools
**Priority:** High (enables more use cases)  
**Effort:** 6-10 hours per tool

**Tasks:**
- [ ] **Web Search Tool** (3-4 hours)
  - Integrate Brave/Google/DuckDuckGo API
  - Return structured results
  - Add caching to reduce API costs
  
- [ ] **Database Query Tool** (4-6 hours)
  - Support read-only queries
  - Parameterized queries (SQL injection protection)
  - Result formatting
  
- [ ] **Code Execution Sandbox** (8-12 hours)
  - Docker-based isolation
  - Timeout enforcement
  - Resource limits (CPU, memory)
  - Language support (Python, Go, JavaScript)

**Acceptance:** Each tool documented, tested, integrated

---

### 9. Workflow Templates
**Priority:** Medium (improves onboarding)  
**Effort:** 4-6 hours

**Tasks:**
- [ ] Define YAML template format
- [ ] Create 5 example templates (documentation, code review, research, Q&A, summarization)
- [ ] Add template endpoints (list, get, instantiate)
- [ ] Update bomma-cliclient with template commands
- [ ] Add template gallery to docs

**Acceptance:** Users can browse and run templates without writing JSON

---

### 10. Web Dashboard
**Priority:** Medium (better UX than CLI)  
**Effort:** 12-20 hours

**Tasks:**
- [ ] Set up frontend (React/Vue/Svelte)
- [ ] Implement polling-based UI (Test 10 pattern)
- [ ] Agent list + status view
- [ ] Memory browser with search
- [ ] Task history with filtering
- [ ] Real-time task execution view
- [ ] Scheduled tasks CRUD
- [ ] Agent creation wizard

**Acceptance:** Full-featured web UI with all CLI capabilities

---

### 11. Workflow Engine
**Priority:** Low (nice-to-have)  
**Effort:** 20-40 hours

**Tasks:**
- [ ] Design DAG-based workflow format
- [ ] Implement task dependencies
- [ ] Add conditional execution
- [ ] Support parallel task execution
- [ ] Add loop/retry logic
- [ ] Create visual workflow editor
- [ ] Add workflow templates

**Acceptance:** Users can define complex multi-step workflows

---

## 📊 Observability Improvements

### 12. Enhanced Logging
**Priority:** Medium  
**Effort:** 2-3 hours

**Tasks:**
- [ ] Structured logging (JSON format)
- [ ] Log levels (DEBUG, INFO, WARN, ERROR)
- [ ] Request tracing IDs
- [ ] Performance metrics (response time, token usage)
- [ ] Log rotation configuration
- [ ] Integration with log aggregators (optional)

**Acceptance:** Logs are queryable, searchable, useful for debugging

---

### 13. Metrics & Monitoring
**Priority:** Medium  
**Effort:** 4-6 hours

**Tasks:**
- [ ] Add Prometheus metrics endpoint
- [ ] Track: API request rate, error rate, response time
- [ ] Track: Task completion rate, average duration
- [ ] Track: Provider usage, token consumption, cost
- [ ] Create Grafana dashboard
- [ ] Add alerting rules

**Acceptance:** Operations team can monitor health in real-time

---

### 14. Cost Tracking
**Priority:** Low  
**Effort:** 3-4 hours

**Tasks:**
- [ ] Track token usage per task
- [ ] Estimate cost per provider
- [ ] Add cost field to task execution history
- [ ] Create cost summary API endpoint
- [ ] Add budget alerts

**Acceptance:** Users see estimated cost per task/agent

---

## 📚 Documentation Improvements

### 15. Deploy Demo Docs
**Priority:** High  
**Effort:** 2-3 hours

**Tasks:**
- [ ] Publish test results as examples
- [ ] Create quickstart guide from Test 1
- [ ] Document all API endpoints (OpenAPI/Swagger)
- [ ] Add architecture diagrams
- [ ] Create video walkthrough (optional)
- [ ] Add troubleshooting guide

**Acceptance:** New users can self-onboard without support

---

### 16. API Reference
**Priority:** High  
**Effort:** 4-6 hours

**Tasks:**
- [ ] Generate OpenAPI spec from code
- [ ] Add request/response examples for all endpoints
- [ ] Document error codes
- [ ] Add authentication guide
- [ ] Create Postman collection
- [ ] Host interactive API explorer

**Acceptance:** Developers can integrate without asking questions

---

## 🔐 Security Hardening

### 17. Input Validation
**Priority:** High  
**Effort:** 3-4 hours

**Tasks:**
- [ ] Add max length constraints (task prompt, memory content, etc.)
- [ ] Sanitize file paths (prevent directory traversal)
- [ ] Validate cron expressions before save
- [ ] Add rate limiting per user
- [ ] Add request size limits
- [ ] Test with malicious inputs

**Acceptance:** System rejects invalid/malicious input safely

---

### 18. Authentication Improvements
**Priority:** Medium  
**Effort:** 4-6 hours

**Tasks:**
- [ ] Add role-based access control (RBAC)
- [ ] Support multiple auth methods (OAuth, SAML)
- [ ] Add API key expiration
- [ ] Add audit log for auth events
- [ ] Add session management
- [ ] Add 2FA support (optional)

**Acceptance:** Fine-grained access control, audit trail

---

## 🌐 Distributed Features (Future)

### 19. Multi-Node Support
**Priority:** Low  
**Effort:** 40+ hours

**Tasks:**
- [ ] Agent pool management
- [ ] Load balancing across nodes
- [ ] Distributed locking
- [ ] State synchronization
- [ ] Fault tolerance
- [ ] Node health monitoring

**Acceptance:** System scales horizontally

---

## Summary

**Total Identified:** 19 improvement areas  
**High Priority:** 7 items (~20-30 hours)  
**Medium Priority:** 7 items (~30-40 hours)  
**Low Priority:** 5 items (~70+ hours)

**Recommended Approach:**
1. **Week 1:** High priority items (production hardening)
2. **Week 2-3:** Medium priority (robustness + documentation)
3. **Month 2:** New features (tools, templates, dashboard)
4. **Month 3+:** Advanced features (workflow engine, distributed)

**Next Step:** Add high-priority items to HEARTBEAT.md for incremental work
