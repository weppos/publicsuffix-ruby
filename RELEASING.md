# Releasing

This document describes the steps to release a new version of PublicSuffix.

## Prerequisites

- You have commit access to the repository
- You have push access to the repository
- You have a GPG key configured for signing tags
- You have permission to publish to RubyGems

## Release process

1. **Determine the new version** using [Semantic Versioning](https://semver.org/)

   ```shell
   VERSION=X.Y.Z
   ```

   - **MAJOR** version for incompatible API changes
   - **MINOR** version for backwards-compatible functionality additions
   - **PATCH** version for backwards-compatible bug fixes

2. **Update the version file** with the new version

   Edit `lib/public_suffix/version.rb` and update the `VERSION` constant:

   ```ruby
   VERSION = "X.Y.Z"
   ```

3. **Update the changelog** with the new version

   Edit `CHANGELOG.md` and add a new section for the release:

   ```markdown
   ## vX.Y.Z

   - Description of changes
   ```

4. **Install dependencies**

   ```shell
   bundle install
   ```

   or simply:

   ```shell
   bundle
   ```

5. **Run tests** and confirm they pass

   ```shell
   bundle exec rake test
   ```

6. **Commit the new version**

   ```shell
   git add lib/public_suffix/version.rb CHANGELOG.md Gemfile.lock
   git commit -m "Release $VERSION"
   ```

7. **Create a signed tag**

   ```shell
   git tag -a v$VERSION -s -m "Release $VERSION"
   ```

8. **Push the changes and tag**

   ```shell
   git push origin main
   git push origin v$VERSION
   ```

9. **Build and publish the gem**

   ```shell
   bundle exec rake release
   ```

   This will:
   - Build the gem
   - Push it to RubyGems
   - Create a GitHub release

## Post-release

- Verify the new version appears on [RubyGems](https://rubygems.org/gems/public_suffix)
- Verify the GitHub release was created
- Announce the release if necessary
