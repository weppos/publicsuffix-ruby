# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{public_suffix_service}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Simone Carletti"]
  s.date = %q{2010-05-31}
  s.description = %q{    Intelligent Domain Name parser based in the Public Suffic List.     Domain Name can parse and decompose a domain name into top level domain,     domain and subdomains.
}
  s.email = %q{weppos@weppos.net}
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "LICENSE.rdoc", "README.rdoc"]
  s.files = ["Rakefile", "CHANGELOG.rdoc", "LICENSE.rdoc", "README.rdoc", "public_suffix_service.gemspec", "test/acceptance_test.rb", "test/public_suffix_service/domain_test.rb", "test/public_suffix_service/rule_list_test.rb", "test/public_suffix_service/rule_test.rb", "test/public_suffix_service_test.rb", "test/test_helper.rb", "lib/public_suffix_service/definitions.dat", "lib/public_suffix_service/domain.rb", "lib/public_suffix_service/errors.rb", "lib/public_suffix_service/rule.rb", "lib/public_suffix_service/rule_list.rb", "lib/public_suffix_service/version.rb", "lib/public_suffix_service.rb"]
  s.homepage = %q{http://www.simonecarletti.com/code/public_suffix_service}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Domain Name parser based on the Public Suffix List}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
