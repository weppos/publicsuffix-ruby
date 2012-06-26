# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "public_suffix"
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Simone Carletti"]
  s.date = "2012-06-26"
  s.description = "PublicSuffix can parse and decompose a domain name into top level domain, domain and subdomains."
  s.email = "weppos@weppos.net"
  s.files = [".gemtest", ".gitignore", ".travis.yml", ".yardopts", "CHANGELOG.md", "Gemfile", "LICENSE", "README.md", "Rakefile", "lib/public_suffix.rb", "lib/public_suffix/definitions.txt", "lib/public_suffix/domain.rb", "lib/public_suffix/errors.rb", "lib/public_suffix/list.rb", "lib/public_suffix/rule.rb", "lib/public_suffix/version.rb", "public_suffix.gemspec", "test/acceptance_test.rb", "test/test_helper.rb", "test/unit/domain_test.rb", "test/unit/errors_test.rb", "test/unit/list_test.rb", "test/unit/public_suffix_test.rb", "test/unit/rule_test.rb"]
  s.homepage = "http://www.simonecarletti.com/code/public_suffix"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "1.8.24"
  s.summary = "Domain name parser based in the Public Suffix List."
  s.test_files = ["test/acceptance_test.rb", "test/test_helper.rb", "test/unit/domain_test.rb", "test/unit/errors_test.rb", "test/unit/list_test.rb", "test/unit/public_suffix_test.rb", "test/unit/rule_test.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end
