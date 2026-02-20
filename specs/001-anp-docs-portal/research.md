# Research: ANP2026 Docs Portal

**Date**: 2026-02-20
**Branch**: `001-anp-docs-portal`

## R1: Julia Documenter.jl Project Setup

**Decision**: Use Documenter.jl v1.x with minimal Julia package stub

**Rationale**: Documenter.jl requires a valid Julia package structure (Project.toml with `name` + `uuid`, and a module file). Even for documentation-only projects, this minimal scaffolding is mandatory. Documenter v1.16+ is the current stable release with all needed features.

**Alternatives considered**:
- Franklin.jl: More flexible static site generator but lacks Documenter's sidebar navigation and GitHub Pages integration conveniences
- Raw GitHub Pages with Jekyll: Would require leaving the Julia ecosystem; no Julia-native tooling

**Key findings**:
- Root `Project.toml` needs: `name = "ANP2026"`, `uuid` (v4), `version`
- `src/ANP2026.jl` needs: `module ANP2026 end`
- `docs/Project.toml` needs: `Documenter = "e30172f5-a6a5-5a46-863b-614d45cd2de4"` with compat `"1"`
- All source markdown must reside under `docs/src/` (current files at `docs/summary_kr/` must be moved)

## R2: Sidebar Navigation Structure

**Decision**: Use `pages` argument with nested sections — Korean and English as top-level groups

**Rationale**: The `pages` keyword in `makedocs()` directly controls sidebar order and grouping. Defining `SUMMARY_KR_PAGES` and `SUMMARY_EN_PAGES` as separate arrays keeps the build script maintainable and mirrors the spec's requirement for clearly labeled sections.

**Key findings**:
- `pages` accepts nested vectors: `"Section Name" => [pairs...]`
- Chapter ordering is explicit (Ch01-Ch14), not alphabetical
- `collapselevel = 1` keeps sidebar manageable with 28+ pages
- Korean chapter titles in sidebar (e.g., "Ch01. 서론") for Korean section; English titles for English section

## R3: GitHub Actions CI/CD Workflow

**Decision**: Use `julia-actions/setup-julia@v2` + `julia-actions/cache@v2` with `GITHUB_TOKEN` authentication

**Rationale**: This is the officially recommended Documenter.jl deployment pattern. `GITHUB_TOKEN` (automatic) is sufficient for main-branch deployments; `DOCUMENTER_KEY` (SSH deploy key) is only needed for tagged-release deployments, which this project does not require initially.

**Alternatives considered**:
- Manual deployment via local builds: Not sustainable for ongoing content updates
- DOCUMENTER_KEY setup: Unnecessary complexity for a single-branch deployment model

**Key findings**:
- Workflow triggers on push to `main` branch
- Required permissions: `actions: write`, `contents: write`, `pull-requests: read`, `statuses: write`
- `Pkg.develop(PackageSpec(path=pwd()))` adds root package as dev dependency in docs environment
- `julia-actions/cache@v2` caches `~/.julia` depot for faster builds

## R4: Custom Domain (CNAME) Handling

**Decision**: Use `deploydocs(cname = "ecoinfo.ai.kr")` — Documenter writes CNAME on every deployment

**Rationale**: Documenter force-pushes to `gh-pages`, which would delete a manually-placed CNAME file. The `cname` argument ensures CNAME is regenerated on every deploy. Placing CNAME in `docs/src/assets/` is insufficient because GitHub Pages expects it at the branch root, not in a subdirectory.

**DNS configuration**:
- `ecoinfo.ai.kr` is a subdomain → use CNAME DNS record pointing to `<username>.github.io`
- GitHub repo Settings > Pages: set custom domain to `ecoinfo.ai.kr`, enable HTTPS

## R5: Custom Landing Page Integration

**Decision**: Post-build `cp()` replacement pattern with directory-based fallback

**Rationale**: Documenter.jl does not natively support custom HTML index pages (only `.md` files in `pages`). Three approaches were evaluated:

| Approach | Verdict |
|----------|---------|
| `@raw html` blocks in `index.md` | Rejected — content wrapped in Documenter layout (sidebar/header), conflicts with full-screen 3D design |
| Post-build file replacement | **Selected** — full HTML control, clean fallback, no layout wrapping |
| Separate redirect page | Rejected — extra HTTP round-trip, flash of blank page |

**Implementation pattern**:
1. Instructor places landing assets in `docs/src/assets/landing/` (landing.html, landing.js, landing.css)
2. After `makedocs()`, `make.jl` checks if `landing.html` exists
3. If present: copy `landing.html` → `build/index.html`, copy supporting assets to `build/assets/landing/`
4. If absent: Documenter's generated `index.html` (from `index.md`) remains — standard doc site
5. A separate `docs/src/home.md` page provides the "documentation home" accessible from the landing page

**Key findings**:
- `deploydocs()` deploys whatever is in `docs/build/` — post-build modifications are fully supported
- Landing page should link to `home/` (or first chapter) to enter the documentation
- Landing page JS/CSS should NOT be listed in `Documenter.HTML(assets=...)` — they are only for the landing page, not every doc page

## R6: Pretty URLs and Local Development

**Decision**: Use `prettyurls` conditional on CI environment

**Rationale**: `prettyurls = true` converts `foo.md` → `foo/index.html` for clean URLs in production. Locally, `prettyurls = false` allows browsing `docs/build/` directly without a web server.

**Pattern**: `prettyurls = get(ENV, "CI", nothing) == "true"`

## R7: Build Warnings Configuration

**Decision**: Use `warnonly = [:missing_docs, :cross_references]`

**Rationale**: Since there is no Julia API to document (documentation-only project), Documenter would emit `:missing_docs` warnings. The markdown files were not written for Documenter's cross-reference system, so `:cross_references` warnings should also be suppressed. Build-breaking errors for actual file issues (missing pages, syntax errors) are still enforced.
