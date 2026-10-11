# Contributing to HAR Extractor

Thanks for your interest in contributing! 🎉

## How to Contribute

### 🐛 Bug Reports

Open an issue with:
- Your OS and Bash version (`bash --version`)
- The HAR file structure (remove sensitive data)
- Steps to reproduce
- Expected vs actual behavior

### ✨ Feature Requests

Open an issue describing:
- The problem you're solving
- Proposed solution
- Alternative approaches

### 🔧 Pull Requests

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Test on Termux/Linux/macOS
4. Run `shellcheck har.sh` and fix warnings
5. Commit (`git commit -m 'feat: add amazing feature'`)
6. Push (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation
- `refactor:` code refactor
- `perf:` performance
- `test:` tests
- `chore:` maintenance

## Code Style

- Use `shellcheck` for linting
- Follow Google Shell Style Guide
- Use `local` for function variables
- Always quote variables: `"$var"`
- Use `[[ ]]` over `[ ]`

## Testing

Test with HAR files of various sizes:
- Small (< 100 entries)
- Medium (100-500 entries)
- Large (500+ entries)

## Code of Conduct

Be respectful. Be kind. We're all here to learn.