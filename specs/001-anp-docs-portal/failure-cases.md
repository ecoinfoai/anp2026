# Failure Case Validation: ANP2026 Docs Portal

**Date**: 2026-02-20
**Branch**: `001-anp-docs-portal`
**Validator**: Failure Case Validator (Pre-Implementation)

## Applicable Personas

| Persona | Relevance | Priority |
|---------|-----------|----------|
| PERSONA-001: Hurried User | HIGH — instructor skips docs, runs build immediately | P1 |
| PERSONA-002: Edge Case Explorer | MEDIUM — unusual markdown content | P2 |
| PERSONA-004: Resource Constrained | LOW — GitHub Actions has standard resources | P3 |
| PERSONA-005: Integration User | MEDIUM — Julia version compatibility | P2 |

*PERSONA-003 (Malicious Actor) is NOT APPLICABLE — public read-only static site with no user input processing.*

## Failure Scenarios by Category

### FC-001: Input Validation Failures (Build Script)

| ID | Scenario | Persona | Expected Behavior | Severity |
|----|----------|---------|-------------------|----------|
| FV-001 | `docs/src/` directory does not exist | PERSONA-001 | `error()` with message: "Documentation source directory not found. Run content migration first." | HIGH |
| FV-002 | Korean summary folder is empty (0 chapter files) | PERSONA-001 | `error()` with message: "No Korean chapter files found in summary_kr/. Expected Ch01-Ch14." | HIGH |
| FV-003 | English summary folder is empty | PERSONA-001 | `error()` with message: "No English chapter files found in summary_en/. Expected Ch01-Ch14." | HIGH |
| FV-004 | Chapter file referenced in `pages` array doesn't exist | PERSONA-002 | Documenter build fails with clear error naming the missing file | MEDIUM |
| FV-005 | `docs/make.jl` run without `docs/Project.toml` | PERSONA-001 | Julia Pkg error: "No Project.toml found in docs/" | MEDIUM |
| FV-006 | `Project.toml` at root missing `name` or `uuid` | PERSONA-001 | Julia Pkg error on `Pkg.develop()` — should suggest checking Project.toml | MEDIUM |

### FC-002: Resource Failures

| ID | Scenario | Persona | Expected Behavior | Severity |
|----|----------|---------|-------------------|----------|
| FV-007 | GitHub Actions workflow fails (network timeout downloading Julia) | PERSONA-004 | Workflow shows failed step with retry available; site remains on previous version | LOW |
| FV-008 | GitHub Pages deployment quota exceeded | PERSONA-004 | `deploydocs()` reports push failure; previous site version remains live | LOW |
| FV-009 | DNS not propagated yet (CNAME configured but not active) | PERSONA-001 | Site loads on default GitHub Pages URL; custom domain shows DNS error | MEDIUM |
| FV-010 | `docs/build/` write permission denied | PERSONA-005 | Julia IOError with path; CI typically has write access | LOW |

### FC-003: State Failures

| ID | Scenario | Persona | Expected Behavior | Severity |
|----|----------|---------|-------------------|----------|
| FV-011 | Running `make.jl` before `Pkg.instantiate()` (Documenter not installed) | PERSONA-001 | Julia error: "Package Documenter not found. Run: julia --project=docs -e 'using Pkg; Pkg.instantiate()'" | HIGH |
| FV-012 | Running build from wrong directory (not repo root) | PERSONA-001 | Path resolution fails; error should indicate expected working directory | MEDIUM |
| FV-013 | `gh-pages` branch doesn't exist on first deploy | PERSONA-001 | `deploydocs()` creates it automatically — no failure expected | N/A (handled) |

### FC-004: Dependency Failures

| ID | Scenario | Persona | Expected Behavior | Severity |
|----|----------|---------|-------------------|----------|
| FV-014 | Julia version < 1.10 installed | PERSONA-005 | Documenter.jl compat error at `Pkg.instantiate()` with version requirement | MEDIUM |
| FV-015 | Documenter.jl v2.x released with breaking changes | PERSONA-005 | `docs/Project.toml` compat `"1"` prevents auto-upgrade to v2; no failure | N/A (handled) |
| FV-016 | Network unavailable during `Pkg.instantiate()` | PERSONA-004 | Julia Pkg error with connection message; cached deps work offline | LOW |

### FC-006: Edge Case Failures

| ID | Scenario | Persona | Expected Behavior | Severity |
|----|----------|---------|-------------------|----------|
| FV-017 | Markdown file contains raw HTML that conflicts with Documenter | PERSONA-002 | Documenter renders HTML as-is or strips it; build should not fail | MEDIUM |
| FV-018 | Chapter file has Korean characters in headings that break anchor links | PERSONA-002 | Documenter generates URL-safe anchors; Korean headings work correctly | LOW |
| FV-019 | Very large markdown file (>1MB, many images) | PERSONA-004 | Build completes but may be slow; no failure expected | LOW |
| FV-020 | Empty markdown file (0 bytes) | PERSONA-002 | Documenter generates page with title from `pages` config but no body; no build failure | LOW |
| FV-021 | Landing page `landing.html` exists but is malformed HTML | PERSONA-002 | Post-build copy succeeds (raw copy); browser may render poorly but build doesn't fail | LOW |
| FV-022 | Landing page references CDN assets that are unavailable | PERSONA-004 | Landing page loads with missing assets; documentation still accessible via `home/` link | MEDIUM |
| FV-023 | `docs/src/assets/landing/` directory exists but `landing.html` is missing | PERSONA-002 | Fallback: default Documenter index.html used (directory exists but key file absent) | MEDIUM |

## Error Message Quality Requirements

Based on failure scenarios, the build script MUST produce error messages with WHAT + WHY + WHERE:

| Scenario | Required Error Message Pattern |
|----------|-------------------------------|
| FV-001 | "Documentation source directory not found: {path}. Expected docs/src/ to exist. Run content migration (see tasks.md Phase 2)." |
| FV-002 | "No Korean chapter files found in {path}. Expected files matching Ch01-Ch14 pattern. Verify content migration completed." |
| FV-003 | "No English chapter files found in {path}. Expected files matching Ch01-Ch14 pattern. Verify content migration completed." |
| FV-011 | "Package Documenter not found in docs/ environment. Run: julia --project=docs -e 'using Pkg; Pkg.instantiate()'" |

## Known Limitations (Pre-Implementation)

| ID | Category | Description | Workaround | Severity |
|----|----------|-------------|------------|----------|
| LIM-001 | Content | New markdown files require manual addition to `pages` array in make.jl | Follow the pattern in make.jl comments; no auto-discovery for new sections | LOW |
| LIM-002 | Deployment | First deployment requires manual GitHub Pages configuration (Settings > Pages) | One-time setup; documented in quickstart.md | LOW |
| LIM-003 | Domain | DNS propagation can take up to 48 hours after configuration | Site accessible via default GitHub Pages URL during propagation | LOW |
| LIM-004 | Landing Page | Landing page must be self-contained HTML — no Documenter layout wrapping | By design; landing page links to `home/` for documentation entry | LOW |
| LIM-005 | Landing Page | Post-build `cp()` checks only for `landing.html` — other files in landing/ directory are copied but not validated | Instructor must verify landing page works locally before pushing | LOW |

## Recommendations for Implementation

### Critical (Must implement)

1. **Add fail-fast validation block to `docs/make.jl`** covering FV-001, FV-002, FV-003
   - Check `docs/src/` exists
   - Check `summary_kr/` has ≥1 chapter file
   - Check `summary_en/` has ≥1 chapter file
   - All errors include WHAT + WHY + WHERE

2. **Refine landing page fallback logic** for FV-023
   - Check specifically for `landing.html` existence, not just directory existence
   - Log `@info` when using fallback vs. landing page

### Important (Should implement)

3. **Add `@info` logging to build script** for build progress visibility
   - `@info "Building ANP2026 documentation..."` at start
   - `@info "Found $(length(kr_files)) Korean chapters, $(length(en_files)) English chapters"`
   - `@info "Landing page: $(landing_installed ? "installed" : "using default index")"`

4. **Document all known limitations** in the generated site's index.md or a dedicated page

### Suggestions

5. **Consider adding a CI smoke test** that verifies the built site has exactly 28 chapter links
6. **Consider adding build time logging** to catch performance regressions as content grows

## Validation Status

| Metric | Value |
|--------|-------|
| Total failure scenarios identified | 23 |
| Handled by design | 2 (FV-013, FV-015) |
| Requires implementation | 6 (FV-001–003, FV-011, FV-012, FV-023) |
| Acceptable as-is | 15 |
| Release readiness | **CONDITIONAL** — implement fail-fast validation before release |
