# Coding Standards: ANP2026 Docs Portal

**Branch**: `001-anp-docs-portal`
**Date**: 2026-02-20
**Source**: Constitutional coding standards skill v2.0

## Project-Specific Applicability

This project is a **Julia + Documenter.jl static documentation site**. The codebase consists of:
- `docs/make.jl` — Build script (primary code file, ~80 lines)
- `src/ANP2026.jl` — Minimal module stub (~3 lines)
- `.github/workflows/docs.yml` — CI/CD workflow (YAML)
- `tests/runtests.jl` — Minimal test file

### Standards Applicability Matrix

| Standard | Priority | Applies? | Notes |
|----------|----------|----------|-------|
| TDD Workflow | P0 | Partial | Build verification tests for make.jl; no unit tests for markdown content |
| Anti-Hallucination | P0 | Yes | Verify Documenter.jl API calls (makedocs, deploydocs arguments) |
| Fail-Fast | P0 | Yes | make.jl must fail clearly on missing files or bad config |
| Security | P0 | Minimal | No secrets in code; GITHUB_TOKEN via env only |
| Typing | P1 | Yes | Julia type annotations on functions in make.jl |
| Documentation | P1 | Yes | Docstrings/comments in make.jl explaining configuration |
| Structure | P2 | Yes | Line length ≤92 (Julia), function length ≤50 lines |
| Git Workflow | P2 | Yes | Conventional commits, branch naming |

## P0: Critical Standards

### TDD — Build Verification

Since this is a documentation project, "tests" means verifying the build pipeline:

```julia
# tests/runtests.jl — Verify Documenter build completes
using Test

@testset "ANP2026 Documentation Build" begin
    @testset "Required files exist" begin
        @test isfile(joinpath(@__DIR__, "..", "docs", "make.jl"))
        @test isfile(joinpath(@__DIR__, "..", "docs", "Project.toml"))
        @test isfile(joinpath(@__DIR__, "..", "Project.toml"))
        @test isfile(joinpath(@__DIR__, "..", "src", "ANP2026.jl"))
    end

    @testset "Chapter summaries exist" begin
        src_dir = joinpath(@__DIR__, "..", "docs", "src")
        for ch in 1:14
            ch_str = lpad(string(ch), 2, '0')
            @test any(startswith("Ch$(ch_str)"), readdir(joinpath(src_dir, "summary_kr")))
            @test any(startswith("Ch$(ch_str)"), readdir(joinpath(src_dir, "summary_en")))
        end
    end
end
```

**RED-GREEN-REFACTOR cycle for this project**:
1. RED: Write test checking for required files/structure → fails (files don't exist yet)
2. GREEN: Create the files → test passes
3. REFACTOR: Clean up file organization if needed

### Anti-Hallucination — Documenter.jl API Verification

All Documenter.jl API usage must be verified against official docs:

| API Call | Verified? | Source |
|----------|-----------|--------|
| `makedocs(sitename=..., format=..., pages=...)` | Yes | Documenter.jl v1.x stable docs |
| `Documenter.HTML(prettyurls=..., collapselevel=...)` | Yes | Documenter.jl HTML format docs |
| `deploydocs(repo=..., devbranch=..., cname=...)` | Yes | Documenter.jl hosting docs |
| `warnonly = [:missing_docs, :cross_references]` | Yes | Documenter.jl makedocs keyword |

**[VERIFY] markers**: If any Documenter.jl parameter is uncertain during implementation, mark it:
```julia
# [VERIFY] Does collapselevel=1 collapse all sections or just top-level?
collapselevel = 1,
```

### Fail-Fast — Build Script Validation

```julia
# make.jl must validate at the start:
const SRC_DIR = joinpath(@__DIR__, "src")

# Fail-fast: verify source directory exists
if !isdir(SRC_DIR)
    error("Documentation source directory not found: $SRC_DIR. " *
          "Run content migration first (see tasks.md Phase 2).")
end

# Fail-fast: verify at least one chapter exists
kr_files = filter(f -> startswith(f, "Ch"), readdir(joinpath(SRC_DIR, "summary_kr")))
if isempty(kr_files)
    error("No Korean chapter files found in $(joinpath(SRC_DIR, "summary_kr")). " *
          "Expected Ch01-Ch14 markdown files.")
end
```

### Security

- `GITHUB_TOKEN` accessed only via `ENV` in CI workflow — never hardcoded
- No `eval()` or dynamic code execution
- No user input processing (static site)
- SSL/HTTPS enforced via GitHub Pages settings

## P1: Important Standards

### Typing (Julia)

```julia
# All functions in make.jl with type annotations
function copy_landing_page(src_dir::String, build_dir::String)::Bool
    landing_html = joinpath(src_dir, "assets", "landing", "landing.html")
    if isfile(landing_html)
        cp(landing_html, joinpath(build_dir, "index.html"), force=true)
        return true
    end
    return false
end
```

### Documentation

```julia
"""
    copy_landing_page(src_dir::String, build_dir::String) -> Bool

Copy instructor-provided landing page to build output, replacing Documenter's index.

If `landing.html` exists in `src_dir/assets/landing/`, copies it to `build_dir/index.html`.
Also copies all supporting assets (JS, CSS) to `build_dir/assets/landing/`.

# Arguments
- `src_dir::String`: Path to `docs/src/` directory
- `build_dir::String`: Path to `docs/build/` directory

# Returns
- `Bool`: `true` if landing page was installed, `false` if not found (fallback to default)
"""
```

## P2: Style Standards

### Line Length
- Julia: max 92 characters per line
- YAML: max 120 characters per line
- Markdown: no hard limit (prose wraps naturally)

### Git Workflow

```
# Commit format
feat(docs): add Korean chapter summaries to sidebar navigation
fix(build): resolve missing_docs warning in makedocs
docs(readme): update build instructions
chore(ci): add Julia cache to GitHub Actions workflow
test(build): add chapter file existence verification
```

## Pre-Implementation Checklist

Before writing any code for this project:

- [ ] **P0 TDD**: tests/runtests.jl exists with file structure tests
- [ ] **P0 Anti-Hallucination**: All Documenter.jl API calls verified against official docs
- [ ] **P0 Fail-Fast**: make.jl includes input validation block at start
- [ ] **P0 Security**: No hardcoded tokens; GITHUB_TOKEN via ENV only
- [ ] **P1 Typing**: All Julia functions have type annotations
- [ ] **P1 Docs**: All Julia functions have docstrings
- [ ] **P2 Structure**: Lines ≤92 chars, functions ≤50 lines
- [ ] **P2 Git**: Commits follow `type(scope): description` format
