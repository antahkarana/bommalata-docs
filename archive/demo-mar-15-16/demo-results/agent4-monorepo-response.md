

# Monorepo vs. Polyrepo Architecture

## Monorepo (Single Repository)

### Pros
- **Atomic changes**: Cross-project refactors and dependency updates happen in a single commit — no coordination across repos.
- **Code sharing & reuse**: Shared libraries live alongside consumers, making it trivial to extract and consume common code.
- **Unified CI/CD**: One pipeline configuration, one set of linting/formatting rules, one source of truth for build tooling.
- **Simplified dependency management**: Internal dependencies are always at the latest version — no version matrix hell.
- **Discoverability**: All code is searchable in one place; onboarding developers can see the full picture.
- **Consistent tooling & standards**: Enforcing code style, testing practices, and review policies is straightforward.

### Cons
- **Scalability pressure**: As the repo grows, `git clone`, `git status`, and CI times degrade without specialized tooling (e.g., Bazel, Nx, Turborepo, or VFS for Git).
- **Tight coupling risk**: Easy access encourages reaching into other teams' code, blurring ownership boundaries.
- **Blast radius**: A bad merge or broken `main` can block *every* team.
- **Complex CI**: You need **affected-target detection** ("what changed?") to avoid rebuilding/testing everything on every commit.
- **Access control**: Fine-grained permissions (e.g., restricting who can modify a sensitive service) are harder in most Git hosts.
- **Tooling investment**: At scale, you essentially need a dedicated platform/infra team to maintain the build system.

---

## Polyrepo (One Repository Per Project)

### Pros
- **Clear ownership & boundaries**: Each repo has its own team, permissions, and release cadence — strong encapsulation.
- **Independent deployability**: Teams ship on their own schedule with no coordination overhead.
- **Simpler per-repo CI**: Pipelines are scoped and fast; no need for change-detection logic.
- **Granular access control**: Native support in GitHub/GitLab — restrict who can see or push to each repo.
- **Scales naturally with Git**: Each repo stays small; standard Git workflows work without special tooling.
- **Technology heterogeneity**: Each repo can use different languages, frameworks, and build systems without conflict.

### Cons
- **Cross-repo changes are painful**: A shared library update requires PRs across N repos, versioning, and coordinated releases ("dependency hell").
- **Code duplication**: Without easy sharing, teams copy-paste utilities, leading to drift.
- **Inconsistent standards**: Each repo evolves its own linting, CI config, formatting, and testing practices.
- **Discoverability suffers**: Finding existing solutions or understanding system-wide architecture requires jumping across repos.
- **Diamond dependency problems**: Service A and Service B may pin different versions of a shared library, causing runtime incompatibilities.
- **Tooling sprawl**: Managing hundreds of repos requires meta-tools (e.g., `meta`, Backstage catalogs, repo templating).

---

## Decision Framework

| Factor | Favors Monorepo | Favors Polyrepo |
|---|---|---|
| Team size | Small–medium, high collaboration | Large org, autonomous teams |
| Code coupling | Highly interdependent services/libs | Loosely coupled, well-defined APIs |
| Release cadence | Coordinated releases | Independent releases |
| Tooling budget | Can invest in build infra | Prefer off-the-shelf Git workflows |
| Access control needs | Low sensitivity differentiation | Strict per-project permissions |
| Tech diversity | Mostly homogeneous stack | Polyglot / heterogeneous |

## The Pragmatic Middle Ground

Many organizations use a **hybrid** approach:

- **Monorepo per domain**: Group tightly-coupled services (e.g., a platform team's microservices + shared libs) in one repo, but keep unrelated domains separate.
- **Shared libraries in their own repo** with proper semantic versioning, consumed by polyrepos.
- **Inner-source model**: Polyrepo structure but with org-wide contribution guidelines and a service catalog (e.g., Backstage).

### Key Takeaway

> **Monorepo optimizes for collaboration and consistency at the cost of tooling complexity. Polyrepo optimizes for autonomy and isolation at the cost of coordination overhead.** The right choice depends on your team structure, coupling between projects, and willingness to invest in build infrastructure.
