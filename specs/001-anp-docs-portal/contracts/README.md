# Contracts: ANP2026 Docs Portal

This feature is a static documentation site with no API endpoints or service contracts.

## Build Contract

The only "contract" is the Documenter.jl build interface:

- **Input**: Markdown files under `docs/src/`, build script `docs/make.jl`
- **Output**: Static HTML site in `docs/build/`
- **Deployment**: `deploydocs()` pushes `docs/build/` contents to `gh-pages` branch

## File Naming Convention

Chapter summary files must follow this pattern:

```
Ch{NN}_{TopicName}_Summary_{LANG}.md
```

Where:
- `{NN}`: Zero-padded chapter number (01-14)
- `{TopicName}`: PascalCase topic identifier
- `{LANG}`: `KR` or `EN`

New files matching this convention placed in `docs/src/summary_kr/` or `docs/src/summary_en/` must be registered in the `pages` array in `docs/make.jl` to appear in navigation.
