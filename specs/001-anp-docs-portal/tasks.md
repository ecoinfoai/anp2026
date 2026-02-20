# Tasks: ANP2026 Docs Portal

**Input**: Design documents from `/specs/001-anp-docs-portal/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, coding-standards.md, pre-impl-review.md, failure-cases.md
**Scope**: US4 (Landing Page) is DEFERRED — will be added in a future iteration.

**Tests**: TDD workflow enforced per coding-standards.md. Build verification tests written BEFORE implementation (RED → GREEN → REFACTOR).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the minimal Julia package structure required by Documenter.jl and establish the TDD test foundation.

- [X] T001 [P] Create root package definition in Project.toml with `name = "ANP2026"`, a generated UUID v4, and `version = "0.1.0"`
- [X] T002 [P] Create minimal module stub in src/ANP2026.jl containing `module ANP2026 end` with module-level docstring
- [X] T003 [P] Create docs environment in docs/Project.toml with Documenter.jl dependency (UUID: `e30172f5-a6a5-5a46-863b-614d45cd2de4`, compat: `"1"`)
- [X] T004 [P] Update .gitignore to add `docs/build/`, `docs/Manifest.toml`, and `Manifest.toml` entries
- [X] T005 [P] **[TDD-RED]** Create build verification tests in tests/runtests.jl: (1) test Project.toml exists with required fields, (2) test src/ANP2026.jl exists, (3) test docs/Project.toml exists, (4) test docs/make.jl exists (will FAIL — make.jl not yet created), (5) test 14 Korean chapter files exist in docs/src/summary_kr/ (will FAIL — not yet moved), (6) test 14 English chapter files exist in docs/src/summary_en/ (will FAIL — not yet moved). Use `@testset` with descriptive names. Tests for existing files should PASS, tests for not-yet-created files should FAIL.

**Checkpoint**: `julia -e 'using Pkg; Pkg.activate("."); Pkg.status()'` shows ANP2026 package. `julia tests/runtests.jl` runs with expected failures for not-yet-created files.

---

## Phase 2: Foundational (Content Migration)

**Purpose**: Move existing chapter summaries into Documenter's source directory and create index pages. MUST complete before any user story.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 [P] Move 14 Korean chapter summaries from docs/summary_kr/ to docs/src/summary_kr/ (preserve all filenames matching `Ch{NN}_*_Summary_KR.md` pattern)
- [X] T007 [P] Move 14 English chapter summaries from docs/summary_en/ to docs/src/summary_en/ (preserve all filenames matching `Ch{NN}_*_Summary_EN.md` pattern)
- [X] T008 [P] Create main page in docs/src/index.md with: ANP2026 course title (Korean/English), brief course description, navigation guidance to Korean and English chapter sections
- [X] T009 [P] Create directory structure docs/src/assets/ for future custom assets
- [X] T010 **[TDD-GREEN]** Run tests/runtests.jl — chapter file tests should now PASS (T006, T007 completed). Verify expected results: Project.toml tests PASS, chapter tests PASS, make.jl test still FAILS (not yet created).

**Checkpoint**: All 28 markdown files exist under `docs/src/` — verify with `ls docs/src/summary_kr/ docs/src/summary_en/ | wc -l` (should be 28). Tests partially green.

---

## Phase 3: User Story 1 - Browse Chapter Summaries by Language (Priority: P1) 🎯 MVP

**Goal**: Students can browse all 14 chapters in Korean or English via sidebar navigation

**Independent Test**: Build site locally with `julia --project=docs docs/make.jl`, open `docs/build/index.html`, verify all 14 chapters appear under Korean and English sidebar sections with correct formatting

**FR Coverage**: FR-001, FR-002, FR-003, FR-005, FR-008

### Implementation for User Story 1

- [X] T011 [US1] Create build script in docs/make.jl with: (1) **Fail-fast validation block** at top: verify `docs/src/` exists, verify `summary_kr/` has ≥1 `Ch*.md` file, verify `summary_en/` has ≥1 `Ch*.md` file — all with WHAT+WHY+WHERE error messages per coding-standards.md and failure-cases.md FV-001/002/003, (2) `SUMMARY_KR_PAGES` array mapping Korean chapter titles (e.g., "Ch01. 서론") to file paths in `summary_kr/`, (3) `SUMMARY_EN_PAGES` array mapping English chapter titles to file paths in `summary_en/`, (4) `makedocs()` with `sitename = "ANP2026 해부생리학"`, `Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true", collapselevel = 1)`, `pages = ["Home" => "index.md", "한국어 요약 (Korean)" => SUMMARY_KR_PAGES, "English Summaries" => SUMMARY_EN_PAGES]`, `warnonly = [:missing_docs, :cross_references]`, (5) `deploydocs()` with `repo`, `devbranch = "main"`, `cname = "ecoinfo.ai.kr"`, (6) `@info` logging for build progress (chapters found count, build status). All functions must have Julia type annotations and docstrings. Include `# Implements FR-001, FR-002, FR-003, FR-005, FR-008` traceability comments.
- [X] T012 [US1] Install Documenter and run local build: `julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'` then `julia --project=docs docs/make.jl` — verify docs/build/ is generated with all chapter pages
- [X] T013 [US1] **[TDD-GREEN]** Run tests/runtests.jl — ALL tests should now PASS (make.jl exists, chapters exist, Project.toml exists). Verify 0 failures.
- [X] T014 [US1] Verify local build output: confirm 28 chapter HTML files exist in docs/build/, sidebar shows Korean and English sections with Ch01-Ch14 in correct order, chapter content renders with headings, lists, and tables

**Checkpoint**: Site builds locally with all 28 chapters accessible via sidebar navigation. All tests pass. FR-001, FR-002, FR-003, FR-005, FR-008 satisfied.

---

## Phase 4: User Story 2 - Automated Site Deployment (Priority: P2)

**Goal**: Site automatically rebuilds and deploys to GitHub Pages when content is pushed to main branch

**Independent Test**: Push a minor edit to any chapter file, verify GitHub Actions workflow runs successfully and gh-pages branch is updated within 10 minutes

**FR Coverage**: FR-004, FR-005

### Implementation for User Story 2

- [X] T015 [US2] Create CI/CD workflow in .github/workflows/docs.yml with: (1) trigger on push to `main` and tags `'*'`, (2) permissions: `actions: write`, `contents: write`, `pull-requests: read`, `statuses: write`, (3) steps: `actions/checkout@v4`, `julia-actions/setup-julia@v2` with `version: '1'`, `julia-actions/cache@v2`, install deps via `julia --project=docs` shell running `Pkg.develop(PackageSpec(path=pwd()))` and `Pkg.instantiate()`, build and deploy via `julia --project=docs docs/make.jl` with env `GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}`. Include `# Implements FR-004, FR-005` comment at top.
- [X] T016 [US2] Create GitHub repository using `gh repo create` and configure remote origin with `git remote add origin`
- [X] T017 [US2] Push all changes to main branch and verify: (1) GitHub Actions workflow triggers, (2) build completes successfully, (3) gh-pages branch is created with built site content

**Checkpoint**: Automated deployment pipeline operational. FR-004, FR-005 satisfied.

---

## Phase 5: User Story 3 - Custom Domain Access (Priority: P3)

**Goal**: Portal accessible at `https://ecoinfo.ai.kr` with valid HTTPS certificate

**Independent Test**: Navigate to `https://ecoinfo.ai.kr` and verify the portal loads with valid SSL

**FR Coverage**: FR-006, FR-011

### Implementation for User Story 3

- [X] T018 [US3] Verify `deploydocs(cname = "ecoinfo.ai.kr")` is present in docs/make.jl (already added in T011 — confirm CNAME file is generated in docs/build/ after local build)
- [X] T019 [US3] ⚙️ MANUAL: Configure DNS at Gabia — add CNAME record: `ecoinfo.ai.kr` pointing to `<username>.github.io`. Then in GitHub repo Settings > Pages: enter custom domain `ecoinfo.ai.kr` and enable "Enforce HTTPS"
- [X] T020 [US3] Verify custom domain: after DNS propagation, confirm `https://ecoinfo.ai.kr` loads the portal with valid HTTPS certificate and the GitHub Pages default URL redirects to the custom domain

**Checkpoint**: Custom domain operational with HTTPS. FR-006, FR-011 satisfied.

---

## Phase 6: User Story 5 - Expandable Content Structure (Priority: P5)

**Goal**: New content sections (quizzes, assessments) can be added by creating a folder with markdown files and adding one line to the pages configuration

**Independent Test**: Create a test quiz folder with a sample markdown file, add it to pages config, build, and verify it appears in sidebar

**FR Coverage**: FR-009

### Implementation for User Story 5

- [X] T021 [US5] Add commented example section to docs/make.jl showing how to add a new content section: `# "퀴즈 (Quiz)" => ["Quiz 1" => "quiz/quiz_01.md"]` with inline comments explaining the pattern. Include `# Implements FR-009` traceability comment.
- [X] T022 [US5] Verify extensibility: create a temporary docs/src/quiz/ folder with a sample quiz_01.md file, uncomment the quiz section in pages config, run build, confirm the new section appears in sidebar, then remove the test files and re-comment

**Checkpoint**: Content extensibility pattern documented and validated. FR-009 satisfied.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across all user stories and failure case validation

- [X] T023 [P] Verify mobile responsiveness: build site and check generated HTML includes responsive viewport meta tag and Documenter's default responsive CSS handles 375px screens (FR-010, SC-006)
- [X] T024 [P] Validate all internal links: check that all 28 chapter summary sidebar links in the built site resolve to existing HTML files with content (SC-007)
- [X] T025 [P] **[Fail-Fast Validation]** Test failure scenarios from failure-cases.md: (1) FV-001: remove docs/src/ temporarily, run make.jl, verify clear error message, (2) FV-002: empty summary_kr/, run make.jl, verify clear error message, (3) FV-011: run make.jl without Pkg.instantiate(), verify helpful error. Restore after testing.
- [X] T026 Run full quickstart.md validation: follow all steps from specs/001-anp-docs-portal/quickstart.md end-to-end on a clean build
- [X] T027 Final acceptance: verify all success criteria SC-001 through SC-007 are met (excluding SC-004 if DNS not yet propagated)

---

## Deferred: User Story 4 - Custom Landing Page Display (Priority: P4)

**Status**: DEFERRED — will be added in a future iteration

**When ready**: Create a new feature branch or add tasks to implement:
- Post-build landing page integration logic in docs/make.jl
- Fallback behavior (no landing assets → default index)
- Create docs/src/home.md as documentation entry point from landing page
- Test with/without landing assets

**FR Coverage (deferred)**: FR-007

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup (Phase 1) — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Foundational (Phase 2) — this is the MVP
- **US2 (Phase 4)**: Depends on US1 (Phase 3) — needs working make.jl to deploy
- **US3 (Phase 5)**: Depends on US2 (Phase 4) — needs deployed site for domain config
- **US5 (Phase 6)**: Depends on US1 (Phase 3) — modifies make.jl pages config
- **Polish (Phase 7)**: Depends on all active user stories being complete

### User Story Dependencies

- **US1 (P1)**: Blocked by Phase 2 only — no dependencies on other stories
- **US2 (P2)**: Blocked by US1 — needs the make.jl build script
- **US3 (P3)**: Blocked by US2 — needs working deployment pipeline
- **US5 (P5)**: Blocked by US1 — can run in parallel with US2/US3

```
Phase 1 (Setup + TDD-RED)
    ↓
Phase 2 (Foundational + TDD-GREEN partial)
    ↓
Phase 3 (US1: Browse Chapters + TDD-GREEN full) ← MVP
    ↓                ↓
Phase 4 (US2)    Phase 6 (US5)
    ↓              [parallel]
Phase 5 (US3)
    ↓
Phase 7 (Polish + Failure Validation)
```

### Parallel Opportunities

**Within Phase 1**: T001, T002, T003, T004, T005 — all different files, fully parallel
**Within Phase 2**: T006, T007, T008, T009 — all different files/directories, fully parallel
**After US1 completes**: US5 (T021-T022) can run in parallel with US2 (T015-T017)
**Within Polish**: T023, T024, T025 can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup + TDD-RED (T001-T005)
2. Complete Phase 2: Foundational + TDD-GREEN partial (T006-T010)
3. Complete Phase 3: User Story 1 + TDD-GREEN full (T011-T014)
4. **STOP and VALIDATE**: Build site locally, verify 28 chapters in sidebar, all tests pass
5. The portal is now usable locally — students can access via built HTML

### Incremental Delivery

1. Setup + Foundational → Package scaffold, content migrated, tests partially green
2. US1 → Local build works, all chapters browsable, all tests pass → **MVP!**
3. US2 → Automated deployment, site live on GitHub Pages
4. US3 → Custom domain `ecoinfo.ai.kr` operational
5. US5 → Extensibility validated
6. Polish → Failure validation, acceptance criteria verified
7. *(Future)* US4 → Landing page integration

---

## Coding Standards Compliance

Per `specs/001-anp-docs-portal/coding-standards.md`:

| Standard | Enforcement | Tasks |
|----------|-------------|-------|
| TDD (P0) | T005 RED, T010/T013 GREEN | Build verification tests before implementation |
| Anti-Hallucination (P0) | T011 | All Documenter.jl APIs verified in research.md |
| Fail-Fast (P0) | T011, T025 | Validation block in make.jl + failure scenario tests |
| Security (P0) | T015 | GITHUB_TOKEN via ENV only |
| Typing (P1) | T011 | Julia type annotations on all functions |
| Documentation (P1) | T011 | Docstrings on all functions, FR-xxx traceability comments |
| Structure (P2) | All | Lines ≤92 chars, functions ≤50 lines |
| Git (P2) | All | `type(scope): description` commit format |

## FR Traceability Summary

| FR | Task | Automated Test | Status |
|----|------|----------------|--------|
| FR-001 | T006, T011 | T005/T013 (file exists) | Covered |
| FR-002 | T007, T011 | T005/T013 (file exists) | Covered |
| FR-003 | T011 | T014 (manual verify) | Covered |
| FR-004 | T015 | T017 (CI verify) | Covered |
| FR-005 | T011, T025 | T025 (failure scenarios) | Covered |
| FR-006 | T018, T019 | T020 (manual verify) | Covered |
| FR-007 | DEFERRED | — | Deferred (US4) |
| FR-008 | T008, T011 | T014 (manual verify) | Covered |
| FR-009 | T021 | T022 (manual verify) | Covered |
| FR-010 | Documenter default | T023 (manual verify) | Covered |
| FR-011 | T011 (deploydocs cname) | T018 (verify) | Covered |

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- ⚙️ MANUAL marks tasks requiring human action outside the codebase (DNS config, GitHub settings)
- `deploydocs(repo = ...)` in T011 needs the actual GitHub repo URL — update after T016
- No remote origin is configured yet — T016 must be completed before T017
- US4 (Landing Page) is DEFERRED — home.md not needed until landing page is implemented
- Commit after each phase completion using `type(scope): description` format
