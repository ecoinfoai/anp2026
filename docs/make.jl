# docs/make.jl — Documenter.jl build script for ANP2026 해부생리학 portal
#
# Implements FR-001, FR-002, FR-003, FR-005, FR-008
#   FR-001: Serve all 14 Korean chapter summaries via sidebar navigation
#   FR-002: Serve all 14 English chapter summaries via sidebar navigation
#   FR-003: Sidebar organized numerically Ch01-Ch14 with labeled sections
#   FR-005: Build pipeline reports clear error messages on failure
#   FR-008: Display default main page when no custom landing page present
#
# Usage (local):  julia --project=docs docs/make.jl
# Usage (CI):     Called automatically by .github/workflows/docs.yml

using Documenter

# ============================================================
# FAIL-FAST VALIDATION BLOCK
# Validates required structure before build starts.
# FV-001, FV-002, FV-003 from failure-cases.md
# ============================================================

const SRC_DIR = joinpath(@__DIR__, "src")

if !isdir(SRC_DIR)
    error(
        "Documentation source directory not found: $SRC_DIR. " *
        "Why: docs/src/ must exist before running the build. " *
        "In make.jl at startup. " *
        "Fix: run content migration (see specs/001-anp-docs-portal/quickstart.md Phase 2)."
    )
end

const KR_DIR = joinpath(SRC_DIR, "summary_kr")
const EN_DIR = joinpath(SRC_DIR, "summary_en")

if !isdir(KR_DIR)
    error(
        "Korean summaries directory not found: $KR_DIR. " *
        "Why: docs/src/summary_kr/ must contain Ch01-Ch14 markdown files. " *
        "In make.jl at startup. " *
        "Fix: move Korean chapter files to docs/src/summary_kr/."
    )
end

if !isdir(EN_DIR)
    error(
        "English summaries directory not found: $EN_DIR. " *
        "Why: docs/src/summary_en/ must contain Ch01-Ch14 markdown files. " *
        "In make.jl at startup. " *
        "Fix: move English chapter files to docs/src/summary_en/."
    )
end

const KR_FILES = filter(f -> startswith(f, "Ch") && endswith(f, ".md"),
                        readdir(KR_DIR))
const EN_FILES = filter(f -> startswith(f, "Ch") && endswith(f, ".md"),
                        readdir(EN_DIR))

if isempty(KR_FILES)
    error(
        "No Korean chapter files found in $KR_DIR. " *
        "Why: expected files matching Ch01-Ch14 pattern (e.g. Ch01_Introduction_Summary_KR.md). " *
        "In make.jl at startup. " *
        "Fix: verify content migration completed successfully."
    )
end

if isempty(EN_FILES)
    error(
        "No English chapter files found in $EN_DIR. " *
        "Why: expected files matching Ch01-Ch14 pattern (e.g. Ch01_Introduction_Summary_EN.md). " *
        "In make.jl at startup. " *
        "Fix: verify content migration completed successfully."
    )
end

@info "ANP2026 build starting" korean_chapters=length(KR_FILES) english_chapters=length(EN_FILES)

# ============================================================
# SIDEBAR PAGE DEFINITIONS
# Maps display titles to file paths relative to docs/src/
# ============================================================

# Korean chapter summaries — Ch01 through Ch14
# Implements FR-001, FR-003
const SUMMARY_KR_PAGES = [
    "Ch01. 서론"          => "summary_kr/Ch01_Introduction_Summary_KR.md",
    "Ch02. 세포와 조직"   => "summary_kr/Ch02_CellAndTissue_Summary_KR.md",
    "Ch03. 피부"          => "summary_kr/Ch03_Skin_Summary_KR.md",
    "Ch04. 혈액"          => "summary_kr/Ch04_Blood_Summary_KR.md",
    "Ch05. 심장과 순환계" => "summary_kr/Ch05_Heart_CirculatorySystem_Summary_KR.md",
    "Ch06. 골격과 관절계" => "summary_kr/Ch06_SkeletalAndJointSystem_Summary_KR.md",
    "Ch07. 소화계"        => "summary_kr/Ch07_DigestiveSystem_Summary_KR.md",
    "Ch08. 호흡계"        => "summary_kr/Ch08_RespiratorySystem_Summary_KR.md",
    "Ch09. 근육계"        => "summary_kr/Ch09_MuscularSystem_Summary_KR.md",
    "Ch10. 내분비계"      => "summary_kr/Ch10_EndocrineSystem_Summary_KR.md",
    "Ch11. 비뇨계"        => "summary_kr/Ch11_UrinarySystem_Summary_KR.md",
    "Ch12. 생식과 발생"   => "summary_kr/Ch12_ReproductionDevelopment_Summary_KR.md",
    "Ch13. 신경계"        => "summary_kr/Ch13_NervousSystem_Summary_KR.md",
    "Ch14. 감각계"        => "summary_kr/Ch14_SensorySystem_Summary_KR.md",
]

# English chapter summaries — Ch01 through Ch14
# Implements FR-002, FR-003
const SUMMARY_EN_PAGES = [
    "Ch01. Introduction"           => "summary_en/Ch01_Introduction_Summary_EN.md",
    "Ch02. Cell and Tissue"        => "summary_en/Ch02_CellAndTissue_Summary_EN.md",
    "Ch03. Skin"                   => "summary_en/Ch03_Skin_Summary_EN.md",
    "Ch04. Blood"                  => "summary_en/Ch04_Blood_Summary_EN.md",
    "Ch05. Heart & Circulatory"    => "summary_en/Ch05_Heart_CirculatorySystem_Summary_EN.md",
    "Ch06. Skeletal & Joint"       => "summary_en/Ch06_SkeletalAndJointSystem_Summary_EN.md",
    "Ch07. Digestive System"       => "summary_en/Ch07_DigestiveSystem_Summary_EN.md",
    "Ch08. Respiratory System"     => "summary_en/Ch08_RespiratorySystem_Summary_EN.md",
    "Ch09. Muscular System"        => "summary_en/Ch09_MuscularSystem_Summary_EN.md",
    "Ch10. Endocrine System"       => "summary_en/Ch10_EndocrineSystem_Summary_EN.md",
    "Ch11. Urinary System"         => "summary_en/Ch11_UrinarySystem_Summary_EN.md",
    "Ch12. Reproduction & Dev."    => "summary_en/Ch12_ReproductionDevelopment_Summary_EN.md",
    "Ch13. Nervous System"         => "summary_en/Ch13_NervousSystem_Summary_EN.md",
    "Ch14. Sensory System"         => "summary_en/Ch14_SensorySystem_Summary_EN.md",
]

# ============================================================
# BUILD DOCUMENTATION
# Implements FR-001, FR-002, FR-003, FR-008
# ============================================================

makedocs(
    sitename = "ANP2026 해부생리학",
    format = Documenter.HTML(
        # prettyurls: true in CI (clean URLs), false locally (browse build/ directly)
        prettyurls = get(ENV, "CI", nothing) == "true",
        # canonical URL for SEO and custom domain
        canonical = "https://ecoinfo.ai.kr",
        # collapselevel=1: keep Korean/English sections collapsed by default
        # (28 pages would clutter the sidebar if fully expanded)
        collapselevel = 1,
    ),
    # Suppress warnings not relevant to documentation-only projects
    # :missing_docs — no Julia API to document
    # :cross_references — markdown not written for Documenter cross-refs
    warnonly = [:missing_docs, :cross_references],
    pages = [
        "Home" => "index.md",
        "한국어 요약 (Korean)" => SUMMARY_KR_PAGES,
        "English Summaries"   => SUMMARY_EN_PAGES,

        # ── HOW TO ADD A NEW SECTION (FR-009) ────────────────────────────────
        # 1. Create a new folder under docs/src/ (e.g., docs/src/quiz/)
        # 2. Add your markdown files there
        # 3. Uncomment and adapt the example below, then push to main
        #
        # "퀴즈 (Quiz)" => [
        #     "Ch01 Quiz" => "quiz/Ch01_Quiz.md",
        #     "Ch02 Quiz" => "quiz/Ch02_Quiz.md",
        # ],
        # ─────────────────────────────────────────────────────────────────────
    ],
)

@info "ANP2026 build complete" output_dir=joinpath(@__DIR__, "build")

# ============================================================
# DEPLOY TO GITHUB PAGES
# Implements FR-004, FR-006, FR-011
# cname: writes CNAME to gh-pages root on every deploy (survives force-push)
# ============================================================

deploydocs(
    repo = "github.com/ecoinfoai/anp2026.git",
    devbranch = "main",
    # Implements FR-011: CNAME preserved across every gh-pages force-push
    cname = "ecoinfo.ai.kr",
    push_preview = false,
)
