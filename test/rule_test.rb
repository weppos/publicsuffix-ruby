require 'test_helper'

class RuleTest < Test::Unit::TestCase

  def test_initialize_rule_normal
    rule = DomainName::Rule.new("verona.it")
    assert_instance_of DomainName::Rule,    rule
    assert_equal :normal,                   rule.type
    assert_equal "verona.it",               rule.name
    assert_equal "verona.it",               rule.value
    assert_equal %w(verona it).reverse,     rule.labels
  end

  def test_initialize_rule_wildcard
    rule = DomainName::Rule.new("*.aichi.jp")
    assert_instance_of DomainName::Rule,    rule
    assert_equal :wildcard,                 rule.type
    assert_equal "*.aichi.jp",              rule.name
    assert_equal "aichi.jp",                rule.value
    assert_equal %w(aichi jp).reverse,      rule.labels
  end

  def test_initialize_rule_exception
    rule = DomainName::Rule.new("!british-library.uk")
    assert_instance_of DomainName::Rule,          rule
    assert_equal :exception,                      rule.type
    assert_equal "!british-library.uk",           rule.name
    assert_equal "british-library.uk",            rule.value
    assert_equal %w(british-library uk).reverse,  rule.labels
  end


  def test_equality_with_self
    rule = DomainName::Rule.new("foo")
    assert_equal rule, rule
  end

  def test_equality_with_internals
    assert_equal      DomainName::Rule.new("foo"), DomainName::Rule.new("foo")
    assert_not_equal  DomainName::Rule.new("foo"), DomainName::Rule.new("bar")
    assert_not_equal  DomainName::Rule.new("foo"), Class.new { def name; foo; end }.new
  end


  def test_match
    assert  DomainName::Rule.new("uk").match?(domain_name("google.uk"))
    assert !DomainName::Rule.new("gk").match?(domain_name("google.uk"))
    assert !DomainName::Rule.new("google").match?(domain_name("google.uk"))
    assert  DomainName::Rule.new("uk").match?(domain_name("google.co.uk"))
    assert !DomainName::Rule.new("gk").match?(domain_name("google.co.uk"))
    assert !DomainName::Rule.new("co").match?(domain_name("google.co.uk"))
    assert  DomainName::Rule.new("co.uk").match?(domain_name("google.co.uk"))
    assert !DomainName::Rule.new("uk.co").match?(domain_name("google.co.uk"))
    assert !DomainName::Rule.new("go.uk").match?(domain_name("google.co.uk"))
  end

  def test_match_with_wildcard
    assert  DomainName::Rule.new("*.uk").match?(domain_name("google.uk"))
    assert  DomainName::Rule.new("*.uk").match?(domain_name("google.co.uk"))
    assert  DomainName::Rule.new("*.co.uk").match?(domain_name("google.co.uk"))
    assert !DomainName::Rule.new("*.go.uk").match?(domain_name("google.co.uk"))
  end

  def test_match_with_exception
    assert  DomainName::Rule.new("!uk").match?(domain_name("google.co.uk"))
    assert !DomainName::Rule.new("!gk").match?(domain_name("google.co.uk"))
    assert  DomainName::Rule.new("!co.uk").match?(domain_name("google.co.uk"))
    assert !DomainName::Rule.new("!go.uk").match?(domain_name("google.co.uk"))
    assert  DomainName::Rule.new("!british-library.uk").match?(domain_name("british-library.uk"))
    assert !DomainName::Rule.new("!british-library.uk").match?(domain_name("google.co.uk"))
  end

end