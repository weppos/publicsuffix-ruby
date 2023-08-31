# frozen_string_literal: true

require_relative "lib/public_suffix/version"

Gem::Specification.new do |s|
  s.name = "public_suffix"
  s.version = PublicSuffix::VERSION
  s.authors = ["Simone Carletti"]
  s.email = ["weppos@weppos.net"]

  s.summary = "Domain name parser based on the Public Suffix List."
  s.description = "PublicSuffix can parse and decompose a domain name into top level domain, domain and subdomains."
  s.homepage = "https://simonecarletti.com/code/publicsuffix-ruby"
  s.licenses = ["MIT"]
  s.required_ruby_version = ">= 2.6"

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/weppos/publicsuffix-ruby/issues",
    "changelog_uri" => "https://github.com/weppos/publicsuffix-ruby/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://rubydoc.info/gems/#{s.name}/#{s.version}",
    "homepage_uri" => s.homepage,
    "source_code_uri" => "https://github.com/weppos/publicsuffix-ruby/tree/v#{s.version}",
  }

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ .git .rubocop Gemfile Rakefile])
    end
  end
  s.require_paths = ["lib"]
  s.extra_rdoc_files = %w( LICENSE.txt )
end
