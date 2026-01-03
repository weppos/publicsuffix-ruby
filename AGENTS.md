# Agent Instructions

Instructions for AI coding agents when working on this project.

## Agent Organization

When creating agent instruction files:

- The main file should always be named `AGENTS.md`
- Create a `CLAUDE.md` symlink pointing to `AGENTS.md` for compatibility with Claude Code

## Project Overview

PublicSuffix for Ruby is a Ruby domain name parser based on the Public Suffix List. It provides domain parsing, validation, and extraction with support for private domains, FQDN handling, and custom rule definitions.

## Key Documentation

- **[README.md](README.md)** - Library overview, features, usage examples, and API reference
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines, commit format, testing approach
- **[Public Suffix List](https://publicsuffix.org/)** - Official Public Suffix List documentation
- **[RubyDoc](https://rubydoc.info/gems/public_suffix)** - API documentation

## Project-Specific Context

### Code Style Notes

- Use Conventional Commits format (see [CONTRIBUTING.md](CONTRIBUTING.md#commit-message-guidelines))
- Follow Ruby community style guidelines
- Do not include AI attribution in commit messages or code comments
- Tests are mandatory for all changes

## Project Structure

```
lib/public_suffix/      # Main library code
test/                   # Test suite
data/                   # Public Suffix List data
```
