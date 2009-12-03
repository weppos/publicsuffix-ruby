require 'test_helper'

class DomainNameTest < Test::Unit::TestCase

  def test_labels
    assert_equal %w(uk co google), domain_name("google.co.uk").labels
    assert_equal %w(uk google), domain_name("google.uk").labels
  end

  def test_to_s
    assert_equal "google.uk", domain_name("google.uk").to_s
    assert_equal "google.co.uk", domain_name("google.co.uk").to_s
  end


  def test_rule
    assert_kind_of DomainName::Rule::Base, domain_name("google.com").rule
  end

  def test_rule_missing
    assert_equal nil, domain_name("google.zip").rule
  end

  def test_rule_bang
    assert_kind_of DomainName::Rule::Base, domain_name("google.com").rule!
  end

  def test_rule_bang_missing
    assert_raise(DomainName::Error) { domain_name("google.zip").rule! } 
  end

  def test_valid
    assert  domain_name("google.com").valid?
    assert !domain_name("google.zip").valid?
  end


  def test_tld
    assert_raise(DomainName::InvalidDomain) { domain_name("google.zip").tld }
    assert_equal "com", domain_name("google.com").tld
  end

  def test_sld
    assert_raise(DomainName::InvalidDomain) { domain_name("google.zip").sld }
    assert_equal "google", domain_name("google.com").sld
  end

  def test_tld
    assert_raise(DomainName::InvalidDomain) { domain_name("google.zip").trd }
    assert_equal nil, domain_name("google.com").trd
    assert_equal "www", domain_name("www.google.com").trd
  end


  def test_parse
    domain = domain_name("google.zip")
    assert_equal domain, domain.parse
    assert_equal nil, domain.rule

    domain = domain_name("google.com")
    assert_equal domain, domain.parse
    assert_not_equal nil, domain.rule
  end

  def test_parse_bang
    domain = domain_name("google.zip")
    assert_raise(DomainName::InvalidDomain) { domain.parse! }
    assert_equal nil, domain.rule

    domain = domain_name("google.com")
    assert_equal domain, domain.parse
    assert_not_equal nil, domain.rule
  end


  def test_self_valid
    assert  DomainName.valid?("google.com")
    assert !DomainName.valid?("google.zip")
  end

end