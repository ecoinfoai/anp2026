# Data Model: ANP2026 Docs Portal

**Date**: 2026-02-20
**Branch**: `001-anp-docs-portal`

## Overview

This is a static documentation site with no database or runtime state. The "data model" describes the content entities and their file-system representation.

## Entities

### Chapter Summary

A markdown document covering one anatomy & physiology chapter.

| Attribute | Type | Constraints |
|-----------|------|-------------|
| Chapter Number | Integer (01-14) | Unique within language; zero-padded two digits |
| Language | Enum (KR, EN) | Exactly one per file |
| Title | String | Derived from first heading in markdown file |
| Body Content | Markdown | Valid markdown; may contain headings, lists, tables, images |
| File Path | String | Pattern: `docs/src/summary_{kr,en}/Ch{NN}_{TopicName}_Summary_{KR,EN}.md` |

**Identity rule**: A chapter summary is uniquely identified by (Chapter Number, Language).

**Naming convention**: `Ch{NN}_{TopicName}_Summary_{LANG}.md` where:
- `{NN}` = zero-padded chapter number (01-14)
- `{TopicName}` = PascalCase topic name (e.g., `CellAndTissue`, `Heart_CirculatorySystem`)
- `{LANG}` = `KR` or `EN`

### Content Section

A logical grouping of related documents in the sidebar navigation.

| Attribute | Type | Constraints |
|-----------|------|-------------|
| Section Name | String | Display label in sidebar (e.g., "한국어 요약 (Korean)") |
| Display Order | Integer | Position in sidebar; defined by order in `pages` array |
| Folder Path | String | Relative to `docs/src/` (e.g., `summary_kr/`, `summary_en/`) |
| Pages | List of (Title, FilePath) | Ordered list of documents in section |

**Current sections**:
1. Home (`index.md`)
2. 한국어 요약 (Korean) — 14 chapters
3. English Summaries — 14 chapters

**Future sections** (extensible): Quiz, Formative Assessment, Supplementary Materials

### Landing Page (Optional)

A set of instructor-created static assets serving as the visual entry point.

| Attribute | Type | Constraints |
|-----------|------|-------------|
| HTML File | File | `docs/src/assets/landing/landing.html` |
| Script Files | File(s) | `docs/src/assets/landing/*.js` |
| Style Files | File(s) | `docs/src/assets/landing/*.css` |
| Present | Boolean | Determined by existence of `landing.html` at build time |

**Lifecycle**: Landing page presence is checked at build time. If present, it replaces the generated `index.html`. If absent, the default Documenter index page is used.

## Relationships

```
Content Section 1──* Chapter Summary
  (one section contains many chapter summaries)

Landing Page 0..1──1 Site
  (site has zero or one landing page)
```

## File System Layout (Source)

```
docs/src/
├── index.md                              # Default home page
├── home.md                               # Documentation home (for landing page link target)
├── summary_kr/
│   ├── Ch01_Introduction_Summary_KR.md
│   ├── Ch02_CellAndTissue_Summary_KR.md
│   └── ... (14 files)
├── summary_en/
│   ├── Ch01_Introduction_Summary_EN.md
│   ├── Ch02_CellAndTissue_Summary_EN.md
│   └── ... (14 files)
└── assets/
    └── landing/                          # Optional, instructor-provided
        ├── landing.html
        ├── landing.js
        └── landing.css
```
