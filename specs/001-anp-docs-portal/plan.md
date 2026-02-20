# Implementation Plan: ANP2026 Docs Portal

**Branch**: `001-anp-docs-portal` | **Date**: 2026-02-20 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-anp-docs-portal/spec.md`

## Summary

Build a course materials portal for the ANP2026 Anatomy & Physiology course using Julia Documenter.jl. The portal serves 28 chapter summary documents (14 Korean + 14 English) as a static site deployed to GitHub Pages via GitHub Actions, accessible at `https://ecoinfo.ai.kr`. The site supports an optional instructor-provided 3D landing page and is extensible for future content sections (quizzes, assessments).

## Technical Context

**Language/Version**: Julia 1.10+
**Primary Dependencies**: Documenter.jl v1.x (v1.16+)
**Storage**: N/A — static site, all content is markdown files in git
**Testing**: Local build verification (`julia --project=docs docs/make.jl`), CI build status
**Target Platform**: GitHub Pages (static hosting), accessed via modern web browsers
**Project Type**: Single project — documentation-only Julia package
**Performance Goals**: Page load < 3 seconds on broadband; deploy within 10 minutes of push
**Constraints**: Public read-only site; no server-side logic; GitHub Pages hosting limits
**Scale/Scope**: 28 markdown documents (14 chapters x 2 languages), expandable

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

No constitution file (`.specify/memory/constitution.md`) exists in this repository. Gate passes by default — no violations to check.

**Post-Phase 1 re-check**: Project structure is minimal (single Julia package + docs). No complexity violations. No external service dependencies beyond GitHub Pages. No authentication or security concerns (public site).

## Project Structure

### Documentation (this feature)

```text
specs/001-anp-docs-portal/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0: Technology research findings
├── data-model.md        # Phase 1: Content entity model
├── quickstart.md        # Phase 1: Developer quickstart guide
├── contracts/           # Phase 1: Build contract and file naming conventions
│   └── README.md
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
anp2026/
├── Project.toml                        # Julia package definition (name, uuid, version)
├── src/
│   └── ANP2026.jl                      # Minimal module stub
├── docs/
│   ├── Project.toml                    # Documenter.jl dependency
│   ├── Manifest.toml                   # Auto-generated (gitignored)
│   ├── make.jl                         # Build script (makedocs + deploydocs)
│   └── src/
│       ├── index.md                    # Default home page
│       ├── home.md                     # Documentation home (landing page link target)
│       ├── summary_kr/                 # Korean chapter summaries (14 files)
│       │   ├── Ch01_Introduction_Summary_KR.md
│       │   └── ... (Ch02-Ch14)
│       ├── summary_en/                 # English chapter summaries (14 files)
│       │   ├── Ch01_Introduction_Summary_EN.md
│       │   └── ... (Ch02-Ch14)
│       └── assets/
│           └── landing/                # Optional instructor-provided landing page
│               ├── landing.html
│               ├── landing.js
│               └── landing.css
├── .github/
│   └── workflows/
│       └── docs.yml                    # CI/CD: build + deploy to gh-pages
├── tests/
│   └── runtests.jl                     # Minimal test file
└── .gitignore                          # Includes docs/build/, docs/Manifest.toml
```

**Structure Decision**: Single project layout. This is a documentation-only Julia package — no backend/frontend split, no API, no database. The entire codebase is `docs/make.jl` (build script), markdown content files, and CI configuration.

## Implementation Phases

### Phase 1: Julia Package Scaffolding

**Goal**: Create the minimal Julia package structure required by Documenter.jl

**Files to create**:
- `Project.toml` — package definition with name `ANP2026`, generated UUID, version `0.1.0`
- `src/ANP2026.jl` — minimal module: `module ANP2026 end`
- `docs/Project.toml` — Documenter dependency (UUID: `e30172f5-a6a5-5a46-863b-614d45cd2de4`, compat: `"1"`)

**Files to update**:
- `.gitignore` — add `docs/build/`, `docs/Manifest.toml`

**Verification**: `julia -e 'using Pkg; Pkg.activate("."); Pkg.status()'` shows ANP2026 package

### Phase 2: Content Migration and Docs Structure

**Goal**: Move existing chapter summaries into Documenter's source directory and create index pages

**Actions**:
- Move `docs/summary_kr/*.md` → `docs/src/summary_kr/`
- Move `docs/summary_en/*.md` → `docs/src/summary_en/`
- Create `docs/src/index.md` — main page with course overview and navigation guidance
- Create `docs/src/home.md` — documentation home page (link target from landing page)
- Create `docs/src/assets/` directory for future custom assets

**Verification**: All 28 markdown files exist under `docs/src/` with correct paths

### Phase 3: Build Script (make.jl)

**Goal**: Create the Documenter build script with sidebar navigation for all chapters

**Key configuration**:
- `makedocs()` with `pages` array defining Korean and English sections
- `Documenter.HTML()` with `prettyurls` conditional on CI, `collapselevel = 1`
- `warnonly = [:missing_docs, :cross_references]` to suppress non-applicable warnings
- Landing page post-build integration logic (check `docs/src/assets/landing/landing.html`)
- `deploydocs()` with `cname = "ecoinfo.ai.kr"`, `devbranch = "main"`

**Sidebar structure**:
```
Home
한국어 요약 (Korean)
  ├── Ch01. 서론
  ├── Ch02. 세포와 조직
  └── ... (Ch03-Ch14 with Korean titles)
English Summaries
  ├── Ch01. Introduction
  ├── Ch02. Cell and Tissue
  └── ... (Ch03-Ch14 with English titles)
```

**Verification**: `julia --project=docs docs/make.jl` builds successfully; `docs/build/index.html` renders correctly

### Phase 4: GitHub Actions CI/CD

**Goal**: Automate build and deployment on push to main branch

**File**: `.github/workflows/docs.yml`

**Workflow steps**:
1. Trigger on push to `main` branch
2. `julia-actions/setup-julia@v2` (version: `'1'`)
3. `julia-actions/cache@v2` for dependency caching
4. `Pkg.develop(PackageSpec(path=pwd()))` + `Pkg.instantiate()`
5. Run `docs/make.jl` with `GITHUB_TOKEN`

**Permissions**: `actions: write`, `contents: write`, `pull-requests: read`, `statuses: write`

**Verification**: Push to main triggers workflow; `gh-pages` branch created with built site

### Phase 5: Custom Domain Configuration

**Goal**: Connect `ecoinfo.ai.kr` domain to GitHub Pages

**Actions**:
1. `deploydocs(cname = "ecoinfo.ai.kr")` already in make.jl (Phase 3)
2. DNS configuration at Gabia: CNAME record `ecoinfo.ai.kr` → `<username>.github.io`
3. GitHub Settings > Pages: set custom domain, enable HTTPS
4. Verify DNS propagation and HTTPS certificate

**Note**: DNS configuration is a manual step requiring access to Gabia control panel. This phase produces documentation/instructions rather than automated code.

**Verification**: `https://ecoinfo.ai.kr` loads the portal with valid SSL certificate

### Phase 6: Landing Page Integration Support

**Goal**: Ensure the build pipeline correctly handles optional landing page assets

**Already implemented in Phase 3** (make.jl post-build logic). This phase verifies:
1. With no `docs/src/assets/landing/` directory: default index.md renders as home
2. With landing assets present: `landing.html` replaces `index.html` in build output
3. Landing page links to `home/` to enter documentation

**Verification**: Build with and without landing assets; verify correct behavior in both cases

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Site generator | Documenter.jl v1.x | Julia-native, built-in GitHub Pages deploy, sidebar navigation |
| Language sections | Separate sidebar sections | Simpler than tabs; standard doc site pattern |
| CNAME handling | `deploydocs(cname=...)` | Survives gh-pages force-push; officially recommended |
| Landing page | Post-build cp() replacement | Full HTML control; clean fallback; no Documenter layout wrapping |
| Pretty URLs | Conditional on CI env | Clean URLs in production; file browsing locally |
| Build warnings | Suppress missing_docs, cross_references | Documentation-only project; no Julia API to document |
| Authentication | GITHUB_TOKEN only | Sufficient for main-branch deploys; no tagged releases needed initially |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Existing markdown has Documenter-incompatible syntax | Build warnings/errors | Use `warnonly` for non-critical warnings; fix files incrementally |
| GitHub remote not yet configured | Cannot deploy | Must create GitHub repo and add remote before Phase 4 |
| DNS propagation delay | Temporary inaccessibility at custom domain | Site remains accessible via default GitHub Pages URL |
| Landing page conflicts with Documenter layout | Broken styling | Post-build replacement avoids layout conflicts entirely |

## Complexity Tracking

No complexity violations. This is a minimal single-project documentation site with:
- 1 build script (`make.jl`)
- 1 CI workflow (`docs.yml`)
- 28 content files (existing)
- 0 external service integrations (beyond GitHub Pages)
