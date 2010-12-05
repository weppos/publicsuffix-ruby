require 'test_helper'

class PublicSuffixServiceTest < Test::Unit::TestCase

  def test_self_parse_a_domain_with_tld_and_sld
    domain = PublicSuffixService.parse("example.com")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_equal nil,       domain.trd

    domain = PublicSuffixService.parse("example.co.uk")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "example", domain.sld
    assert_equal nil,       domain.trd
  end

  def test_self_parse_a_domain_with_tld_and_sld_and_trd
    domain = PublicSuffixService.parse("alpha.example.com")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_equal "alpha",   domain.trd

    domain = PublicSuffixService.parse("alpha.example.co.uk")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "example", domain.sld
    assert_equal "alpha",   domain.trd
  end

  def test_self_parse_a_domain_with_tld_and_sld_and_4rd
    domain = PublicSuffixService.parse("one.two.example.com")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_equal "one.two", domain.trd

    domain = PublicSuffixService.parse("one.two.example.co.uk")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "example", domain.sld
    assert_equal "one.two", domain.trd
  end

  def test_self_parse_a_fully_qualified_domain_name
    domain = PublicSuffixService.parse("www.example.com.")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_equal "www",     domain.trd
  end

  def test_self_parse_should_raise_with_invalid_domain
    error = assert_raise(PublicSuffixService::DomainInvalid) { PublicSuffixService.parse("example.zip") }
    assert_match %r{example\.zip}, error.message
  end

  def test_self_parse_should_raise_with_unallowed_domain
    error = assert_raise(PublicSuffixService::DomainNotAllowed) { PublicSuffixService.parse("example.do") }
    assert_match %r{example\.do}, error.message
  end


  def test_self_valid
    assert  PublicSuffixService.valid?("google.com")
    assert  PublicSuffixService.valid?("www.google.com")
    assert  PublicSuffixService.valid?("google.co.uk")
    assert  PublicSuffixService.valid?("www.google.co.uk")
  end

  # Returns false when domain has an invalid TLD
  def test_self_valid_with_invalid_tld
    assert !PublicSuffixService.valid?("google.zip")
    assert !PublicSuffixService.valid?("www.google.zip")
  end

  def test_self_valid_with_fully_qualified_domain_name
    assert  PublicSuffixService.valid?("google.com.")
    assert  PublicSuffixService.valid?("google.co.uk.")
    assert !PublicSuffixService.valid?("google.zip.")
  end

end