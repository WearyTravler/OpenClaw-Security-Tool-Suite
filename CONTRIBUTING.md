# Contributing to Chitinwall

Thank you for your interest in contributing!

## Areas Where Help is Needed

- Detection patterns for new attack vectors
- IoC feeds (C2 infrastructure, malicious publishers)
- Test skills (defanged malicious samples)
- Dashboard UI improvements
- Documentation

## Development Setup

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Run tests: `cargo test --all`
6. Submit a pull request

## Detection Pattern Guidelines

When submitting new detection patterns:

1. Include regex pattern
2. Provide test cases (malicious + benign)
3. Document the attack vector
4. Specify severity level

See `data/patterns.toml` for examples.

## Code Style

- Run `cargo fmt` before committing
- Follow Rust API guidelines
- Add tests for new features
