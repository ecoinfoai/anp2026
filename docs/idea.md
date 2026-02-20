# Project Idea: ANP2026 — 해부생리학 강의자료 포털

## Vision

해부생리학(Anatomy & Physiology) 강의의 보조자료를 체계적으로 관리하고,
Julia Documenter.jl을 통해 GitHub Pages로 퍼블리시하여
학생들이 언제 어디서든 접근할 수 있는 **수업용 보조자료 창고**를 구축한다.

## Problem Statement

- 챕터별 요약 문서(한국어/영어)가 로컬에만 존재하여 학생 접근성이 낮다.
- 문서가 늘어날수록 일관된 구조 유지와 탐색이 어렵다.
- 강의자료 사이트의 대문 페이지가 학생들의 첫인상과 몰입에 중요하지만,
  기본 Documenter 테마는 시각적으로 단조롭다.

## Key Features

1. **Julia Documenter.jl 기반 정적 사이트 생성**
   - `docs/make.jl`로 빌드, `docs/src/` 아래 마크다운 문서 관리
   - 한국어(`summary_kr/`) · 영어(`summary_en/`) 챕터별 요약 자동 통합
   - 사이드바 네비게이션으로 챕터 간 빠른 이동

2. **확장 가능한 문서 구조**
   - 퀴즈, 형성평가, 보충자료 등 새로운 섹션을 쉽게 추가
   - 폴더 규약: `docs/src/summary_kr/`, `docs/src/summary_en/`, `docs/src/quiz/` 등
   - 학기별·주차별 자료를 점진적으로 축적

3. **3D 애니메이션 랜딩 페이지** *(사용자 직접 제작)*
   - 랜딩 페이지 디자인 및 코드는 사용자가 별도로 준비
   - Documenter 빌드 시 `docs/src/assets/`에 배치된 랜딩 파일을 자동 포함
   - 빌드 파이프라인은 사용자가 제공한 랜딩 페이지를 그대로 배포

4. **커스텀 도메인 연결: ecoinfo.ai.kr**
   - 가비아에서 구매한 도메인 `ecoinfo.ai.kr`을 GitHub Pages에 연결
   - `docs/src/assets/CNAME` 파일 배치
   - 가비아 DNS 설정: GitHub Pages IP로 A 레코드 / CNAME 레코드 구성

## Technical Approach

- **Language/Framework**: Julia + Documenter.jl
- **빌드 도구**: `docs/make.jl` (Documenter.makedocs + deploydocs)
- **배포**: GitHub Actions → `gh-pages` 브랜치 → GitHub Pages
- **랜딩 페이지**: 사용자 직접 제작 (빌드 시 assets/에서 통합)
- **도메인**: `ecoinfo.ai.kr` (가비아 DNS → GitHub Pages)

### 프로젝트 구조 (목표)

```
anp2026/
├── Project.toml              # Julia 프로젝트 정의
├── src/
│   └── ANP2026.jl            # 최소 모듈 (Documenter 요구사항)
├── docs/
│   ├── make.jl               # Documenter 빌드 스크립트
│   ├── Project.toml          # docs 의존성 (Documenter)
│   └── src/
│       ├── index.md          # 메인 페이지 (또는 커스텀 랜딩으로 대체)
│       ├── summary_kr/       # 한국어 챕터 요약
│       │   ├── Ch01_Introduction_Summary_KR.md
│       │   ├── Ch02_CellAndTissue_Summary_KR.md
│       │   └── ...
│       ├── summary_en/       # 영어 챕터 요약
│       │   ├── Ch01_Introduction_Summary_EN.md
│       │   ├── Ch02_CellAndTissue_Summary_EN.md
│       │   └── ...
│       └── assets/
│           ├── CNAME          # 커스텀 도메인 파일
│           ├── landing.html   # 3D 애니메이션 랜딩 페이지 (사용자 제작)
│           ├── landing.js     # 랜딩 페이지 스크립트 (사용자 제작)
│           └── custom.css     # 추가 스타일시트 (사용자 제작)
├── .github/
│   └── workflows/
│       └── docs.yml          # GitHub Actions CI/CD
└── tests/
    └── runtests.jl
```

## Implementation Plan

### Phase 1: Julia Documenter 기본 설정
- [ ] `Project.toml` 생성 (패키지명: ANP2026)
- [ ] `src/ANP2026.jl` 최소 모듈 생성
- [ ] `docs/Project.toml` 생성 (Documenter 의존성)
- [ ] `docs/make.jl` 작성 (makedocs + deploydocs)
- [ ] 기존 `docs/summary_kr/`, `docs/summary_en/` 파일을 `docs/src/` 하위로 이동
- [ ] `docs/src/index.md` 작성 (임시 메인 페이지)
- [ ] 로컬 빌드 테스트: `julia --project=docs docs/make.jl`

### Phase 2: GitHub Actions + GitHub Pages 배포
- [ ] `.github/workflows/docs.yml` 작성
- [ ] `gh-pages` 브랜치 자동 배포 설정
- [ ] GitHub 리포지토리 Settings → Pages에서 소스 브랜치 설정
- [ ] 빌드·배포 파이프라인 동작 확인

### Phase 3: 커스텀 도메인 (ecoinfo.ai.kr) 연결
- [ ] `docs/src/assets/CNAME` 파일에 `ecoinfo.ai.kr` 기록
- [ ] 가비아 DNS 설정 안내:
  - A 레코드: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
  - 또는 CNAME 레코드: `<username>.github.io`
- [ ] GitHub Pages Settings에서 커스텀 도메인 입력 및 HTTPS 활성화
- [ ] DNS 전파 후 `https://ecoinfo.ai.kr` 접속 확인

### Phase 4: 3D 애니메이션 랜딩 페이지 통합 *(사용자 제작)*
- [ ] 사용자가 랜딩 페이지 파일(HTML/JS/CSS) 준비
- [ ] `docs/src/assets/`에 랜딩 파일 배치
- [ ] Documenter 빌드 시 랜딩 페이지가 정상 포함되는지 확인
- [ ] 배포 후 `https://ecoinfo.ai.kr` 접속 시 랜딩 페이지 표시 확인

### Phase 5: 콘텐츠 확장 체계
- [ ] 퀴즈, 형성평가 등 추가 섹션 폴더 구조 확립
- [ ] 새 문서 추가 가이드라인 문서화
- [ ] 학기별 자료 업데이트 워크플로우 정립

## Success Criteria

- [ ] `julia --project=docs docs/make.jl`로 로컬 빌드 성공
- [ ] GitHub Actions로 `gh-pages` 브랜치 자동 배포 동작
- [ ] `https://ecoinfo.ai.kr`에서 사이트 정상 접속
- [ ] 대문 페이지에 3D 애니메이션이 렌더링됨
- [ ] 14개 챕터(KR/EN) 요약 문서가 사이드바에서 탐색 가능
- [ ] 새 마크다운 문서 추가 시 자동으로 사이트에 반영

## Open Questions

1. 영어/한국어 문서를 탭으로 전환할 것인가, 별도 섹션으로 분리할 것인가?
2. 퀴즈·형성평가 문서도 Documenter에 통합할 것인가, 별도 앱으로 분리할 것인가?
3. `ecoinfo.ai.kr`의 서브도메인 활용 계획이 있는가? (예: `api.ecoinfo.ai.kr`)

---

*다음 단계: Phase 1부터 순차적으로 구현을 진행합니다.*
```bash
# Phase 1 시작
julia -e 'using Pkg; Pkg.generate("ANP2026")'
# 또는 Claude Code에서:
# /speckit.specify "Read docs/idea.md and create specification"
```
