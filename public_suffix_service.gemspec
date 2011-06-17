# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{public_suffix_service}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Simone Carletti}]
  s.date = %q{2011-06-17}
  s.description = %q{PublicSuffixService can parse and decompose a domain name into top level domain, domain and subdomains.}
  s.email = %q{weppos@weppos.net}
  s.files = [%q{.gemtest}, %q{.gitignore}, %q{.yardopts}, %q{CHANGELOG.md}, %q{Gemfile}, %q{Gemfile.lock}, %q{LICENSE}, %q{README.md}, %q{Rakefile}, %q{lib/public_suffix_service.rb}, %q{lib/public_suffix_service/definitions.txt}, %q{lib/public_suffix_service/domain.rb}, %q{lib/public_suffix_service/errors.rb}, %q{lib/public_suffix_service/rule.rb}, %q{lib/public_suffix_service/rule_list.rb}, %q{lib/public_suffix_service/version.rb}, %q{public_suffix_service.gemspec}, %q{test/acceptance_test.rb}, %q{test/public_suffix_service/domain_test.rb}, %q{test/public_suffix_service/errors_test.rb}, %q{test/public_suffix_service/rule_list_test.rb}, %q{test/public_suffix_service/rule_test.rb}, %q{test/public_suffix_service_test.rb}, %q{test/test_helper.rb}]
  s.homepage = %q{http://www.simonecarletti.com/code/public_suffix_service}
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = %q{1.8.3}
  s.summary = %q{Domain name parser based in the Public Suffix List.}
  s.test_files = [%q{test/acceptance_test.rb}, %q{test/public_suffix_service/domain_test.rb}, %q{test/public_suffix_service/errors_test.rb}, %q{test/public_suffix_service/rule_list_test.rb}, %q{test/public_suffix_service/rule_test.rb}, %q{test/public_suffix_service_test.rb}, %q{test/test_helper.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rr>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<rr>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<rr>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end
