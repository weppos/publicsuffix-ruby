require 'test_helper'

class PublicSuffixTest < Minitest::Unit::TestCase

  def test_self_parse_a_domain_with_tld_and_sld
    domain = PublicSuffix.parse("example.com")
    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_equal nil,       domain.trd

    domain = PublicSuffix.parse("example.co.uk")
    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "example", domain.sld
    assert_equal nil,       domain.trd
  end

  def test_self_parse_a_domain_with_tld_and_sld_and_trd
    domain = PublicSuffix.parse("alpha.example.com")
    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_equal "alpha",   domain.trd

    domain = PublicSuffix.parse("alpha.example.co.uk")
    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "example", domain.sld
    assert_equal "alpha",   domain.trd
  end

  def test_self_parse_a_domain_with_tld_and_sld_and_4rd
    domain = PublicSuffix.parse("one.two.example.com")
    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_equal "one.two", domain.trd

    domain = PublicSuffix.parse("one.two.example.co.uk")
    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "example", domain.sld
    assert_equal "one.two", domain.trd
  end

  def test_self_parse_a_fully_qualified_domain_name
    domain = PublicSuffix.parse("www.example.com.")
    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_equal "www",     domain.trd
  end

  def test_private_domains_are_enabled_by_default
    domain = PublicSuffix.parse("www.example.blogspot.com")
    assert_equal "blogspot.com",    domain.tld
  end

  def test_disable_support_for_private_domains
    begin
      PublicSuffix::List.private_domains = false
      domain = PublicSuffix.parse("www.example.blogspot.com")
      assert_equal "com",    domain.tld
    ensure
      PublicSuffix::List.private_domains = true
    end
  end

  def test_self_parse_a_domain_with_custom_list
    list = PublicSuffix::List.new
    list << PublicSuffix::Rule.factory("test")

    domain = PublicSuffix.parse("www.example.test", list)
    assert_equal "test",    domain.tld
    assert_equal "example", domain.sld
    assert_equal "www",     domain.trd
  end

  def test_self_parse_raises_with_invalid_domain
    error = assert_raises(PublicSuffix::DomainInvalid) { PublicSuffix.parse("example.qqq") }
    assert_match %r{example\.qqq}, error.message
  end

  def test_self_parse_raises_with_unallowed_domain
    error = assert_raises(PublicSuffix::DomainNotAllowed) { PublicSuffix.parse("example.ke") }
    assert_match %r{example\.ke}, error.message
  end

  def test_self_raises_with_uri
    error = assert_raises(PublicSuffix::DomainInvalid) { PublicSuffix.parse("http://google.com") }
    assert_match %r{http://google\.com}, error.message
  end


  def test_self_valid
    assert  PublicSuffix.valid?("google.com")
    assert  PublicSuffix.valid?("www.google.com")
    assert  PublicSuffix.valid?("google.co.uk")
    assert  PublicSuffix.valid?("www.google.co.uk")
  end

  # Returns false when domain has an invalid TLD
  def test_self_valid_with_invalid_tld
    assert !PublicSuffix.valid?("google.qqq")
    assert !PublicSuffix.valid?("www.google.qqq")
  end

  def test_self_valid_with_fully_qualified_domain_name
    assert  PublicSuffix.valid?("google.com.")
    assert  PublicSuffix.valid?("google.co.uk.")
    assert !PublicSuffix.valid?("google.qqq.")
  end

end
