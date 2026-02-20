# Quickstart: ANP2026 Docs Portal

**Branch**: `001-anp-docs-portal`
**Date**: 2026-02-20

## Prerequisites

- Julia 1.10+ installed (`julia --version`)
- Git configured with GitHub access
- GitHub repository created (remote not yet configured)

## Step 1: Initialize Julia Package

```bash
# From repo root
cd /home/kjeong/localgit/anp2026

# Generate UUID for Project.toml
julia -e 'using UUIDs; println(uuid4())'
```

Create `Project.toml` with the generated UUID, and `src/ANP2026.jl` with a minimal module.

## Step 2: Set Up Docs Environment

```bash
# Move existing summaries into docs/src/
mkdir -p docs/src/summary_kr docs/src/summary_en docs/src/assets
mv docs/summary_kr/*.md docs/src/summary_kr/
mv docs/summary_en/*.md docs/src/summary_en/

# Install Documenter in docs environment
julia --project=docs -e 'using Pkg; Pkg.add("Documenter")'
```

Create `docs/src/index.md` (home page) and `docs/make.jl` (build script).

## Step 3: Local Build Test

```bash
julia --project=docs docs/make.jl
```

Open `docs/build/index.html` in a browser to verify the site renders correctly with all 28 chapters in the sidebar.

## Step 4: GitHub Actions Setup

Create `.github/workflows/docs.yml` with the CI/CD workflow. Push to `main` branch.

## Step 5: GitHub Pages Configuration

1. Go to GitHub repo Settings > Pages
2. Source: "Deploy from a branch"
3. Branch: `gh-pages` / `/ (root)`

## Step 6: Custom Domain

1. In `docs/make.jl`, set `deploydocs(cname = "ecoinfo.ai.kr")`
2. At Gabia DNS: add CNAME record `ecoinfo.ai.kr` → `<username>.github.io`
3. In GitHub Settings > Pages: set custom domain to `ecoinfo.ai.kr`, enable HTTPS

## Step 7: Landing Page (When Ready)

1. Place landing assets in `docs/src/assets/landing/`
2. The build script automatically integrates them on next deploy
3. If removed, site falls back to default Documenter index

## Verification Checklist

- [ ] `julia --project=docs docs/make.jl` builds without errors
- [ ] All 14 KR chapters appear in sidebar under "한국어 요약 (Korean)"
- [ ] All 14 EN chapters appear in sidebar under "English Summaries"
- [ ] Chapter content renders with correct formatting
- [ ] `https://ecoinfo.ai.kr` loads with valid HTTPS
- [ ] Content updates auto-deploy within 10 minutes of push
