"""
Build verification tests for ANP2026 documentation portal.

TDD-RED phase: Some tests will FAIL until implementation is complete.
Expected failures at this stage:
  - "docs/make.jl exists" (not yet created)
  - "Korean chapter files exist" (not yet migrated)
  - "English chapter files exist" (not yet migrated)

Run with: julia tests/runtests.jl
"""

using Test

const REPO_ROOT = dirname(dirname(abspath(@__FILE__)))

@testset "ANP2026 Documentation Build Verification" begin

    # ──────────────────────────────────────────────
    # Phase 1 checks: Package scaffold
    # ──────────────────────────────────────────────
    @testset "Julia package scaffold" begin
        @test isfile(joinpath(REPO_ROOT, "Project.toml"))
        @test isfile(joinpath(REPO_ROOT, "src", "ANP2026.jl"))
        @test isfile(joinpath(REPO_ROOT, "docs", "Project.toml"))
    end

    # ──────────────────────────────────────────────
    # Phase 2 checks: Content migration
    # (Will FAIL until T006/T007 complete)
    # ──────────────────────────────────────────────
    @testset "Korean chapter summaries exist (14 files)" begin
        kr_dir = joinpath(REPO_ROOT, "docs", "src", "summary_kr")
        @test isdir(kr_dir)
        kr_files = filter(f -> startswith(f, "Ch") && endswith(f, ".md"),
                          readdir(kr_dir))
        @test length(kr_files) == 14
        # Verify Ch01 through Ch14 are all present
        for ch in 1:14
            ch_str = lpad(string(ch), 2, '0')
            matching = filter(f -> startswith(f, "Ch$(ch_str)"), kr_files)
            @test length(matching) >= 1
        end
    end

    @testset "English chapter summaries exist (14 files)" begin
        en_dir = joinpath(REPO_ROOT, "docs", "src", "summary_en")
        @test isdir(en_dir)
        en_files = filter(f -> startswith(f, "Ch") && endswith(f, ".md"),
                          readdir(en_dir))
        @test length(en_files) == 14
        # Verify Ch01 through Ch14 are all present
        for ch in 1:14
            ch_str = lpad(string(ch), 2, '0')
            matching = filter(f -> startswith(f, "Ch$(ch_str)"), en_files)
            @test length(matching) >= 1
        end
    end

    # ──────────────────────────────────────────────
    # Phase 3 checks: Build script
    # (Will FAIL until T011 complete)
    # ──────────────────────────────────────────────
    @testset "Build script exists" begin
        @test isfile(joinpath(REPO_ROOT, "docs", "make.jl"))
    end

    @testset "Docs source structure" begin
        src_dir = joinpath(REPO_ROOT, "docs", "src")
        @test isdir(src_dir)
        @test isfile(joinpath(src_dir, "index.md"))
    end

end
