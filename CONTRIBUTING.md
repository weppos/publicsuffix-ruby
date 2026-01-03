# Contributing to PublicSuffix for Ruby

Thank you for your interest in contributing to PublicSuffix for Ruby!

## Development Workflow

1. Fork and clone the repository
2. Install dependencies: `bundle install`
3. Create a branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Run tests: `rake test`
6. Commit using Conventional Commits format (see below)
7. Push and create a pull request

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages.

We follow the [Common Changelog](https://common-changelog.org/) format for changelog entries.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Use lowercase for `<type>`. Capitalize the first letter of `<subject>` (sentence-style). See examples below.

### Type

- **feat**: A new feature
- **fix**: A bug fix
- **chore**: Other changes that don't modify src or test files
- **docs**: Documentation only changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding or updating tests
- **build**: Changes to build system or external dependencies
- **ci**: Changes to CI configuration files and scripts

### Scope

- **parser**: List parsing and rule handling
- **domain**: Domain parsing and validation
- **list**: List management and operations
- **rule**: Rule definitions and matching

### Examples

```bash
feat(parser): Add support for wildcard exceptions

fix(domain): Handle FQDN trailing dots correctly

docs: Update usage examples in README

refactor(list): Simplify rule lookup logic
```

### Breaking Changes

Add `BREAKING CHANGE:` in the footer:

```
feat(domain): Change parse return type

BREAKING CHANGE: Domain#parse now returns nil for invalid domains instead of raising.
Update code to check for nil returns.
```

## Testing

### Running Tests

```bash
rake test                        # Run all tests
rake test TEST=test/domain_test.rb  # Run specific test file
```

### Writing Tests

- Tests use Minitest framework
- Place tests in `test/` directory
- Use descriptive test names
- Test both happy paths and error cases
- Include tests for edge cases (empty strings, unicode, etc.)

## Pull Request Process

1. Update documentation for API changes
2. Add tests for new features or bug fixes
3. Ensure all tests pass: `rake test`
4. Use Conventional Commits format
5. Provide clear PR description with context
6. Reference related issues if applicable

## Code Style

- Follow [Ruby Style Guide](https://rubystyle.guide/)
- Use RuboCop configuration if present
- Add YARD documentation for public methods
- Keep methods focused and small

### Ruby-Specific Guidelines

- Follow idiomatic Ruby patterns
- Use meaningful variable and method names
- Prefer `raise` over `fail`
- Use blocks and iterators effectively
- Follow the principle of least surprise
- Prefer methods that return values over side effects

### Documentation

- Add YARD comments for public methods
- Include usage examples in documentation
- Update README.md for user-facing changes
- Keep inline comments minimal - prefer self-documenting code

## Questions?

Open an issue for questions, feature discussions, or bug reports.

Thank you for contributing!
