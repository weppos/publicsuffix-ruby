# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{public_suffix_service}
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Simone Carletti"]
  s.date = %q{2011-03-11}
  s.description = %q{    Intelligent domain name parser based in the Public Suffic List.     PublicSuffixService can parse and decompose a domain name into top level domain,     domain and subdomains.
}
  s.email = %q{weppos@weppos.net}
  s.files = [".gitignore", ".yardopts", "CHANGELOG.md", "Gemfile", "Gemfile.lock", "LICENSE", "README.md", "Rakefile", "lib/public_suffix_service.rb", "lib/public_suffix_service/definitions.dat", "lib/public_suffix_service/domain.rb", "lib/public_suffix_service/errors.rb", "lib/public_suffix_service/rule.rb", "lib/public_suffix_service/rule_list.rb", "lib/public_suffix_service/version.rb", "public_suffix_service.gemspec", "test/acceptance_test.rb", "test/public_suffix_service/domain_test.rb", "test/public_suffix_service/errors_test.rb", "test/public_suffix_service/rule_list_test.rb", "test/public_suffix_service/rule_test.rb", "test/public_suffix_service_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://www.simonecarletti.com/code/public_suffix_service}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.1}
  s.summary = %q{Domain Name parser based on the Public Suffix List}
  s.test_files = ["test/acceptance_test.rb", "test/public_suffix_service/domain_test.rb", "test/public_suffix_service/errors_test.rb", "test/public_suffix_service/rule_list_test.rb", "test/public_suffix_service/rule_test.rb", "test/public_suffix_service_test.rb", "test/test_helper.rb"]

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
