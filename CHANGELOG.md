# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [8.0.0] - 2026-06-07

### Added
- Persistent config file support (`~/.har_extractor.conf`)
- `--help`, `--version`, `--config`, `--reset-config` CLI flags
- Auto-save user preferences
- Domain icons for API/Auth/CDN/Socket types
- Statistics summary in export footer

### Changed
- Optimized filtering with bash `case` statements
- Simplified jq formatting for reliability
- Improved error handling

### Fixed
- Empty output bug from malformed jq filter
- Silent failure on invalid HAR files
- Progress display for large HAR files

## [7.0.0] - 2026-06-07

### Added
- Single jq pass for domain extraction
- Ultra-fast processing (10x speedup)

### Fixed
- Termux `/tmp` read-only filesystem errors

## [6.0.0] - 2026-06-07

### Added
- Interactive filter configuration
- Domain grouping with request counts
- Multi-selection support (single, multiple, range, all)

## [5.0.0] - 2026-06-07

### Added
- Initial public release
- Asset filtering
- Request/response export