require 'test_helper'

class PublicSuffixServiceTest < Test::Unit::TestCase

  def test_self_parse_a_domain_with_tld_and_sld
    domain = PublicSuffixService.parse("google.com")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal nil,       domain.trd

    domain = PublicSuffixService.parse("google.co.uk")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "google",  domain.sld
    assert_equal nil,       domain.trd
  end

  def test_self_parse_a_domain_with_tld_and_sld_and_trd
    domain = PublicSuffixService.parse("alpha.google.com")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal "alpha",   domain.trd

    domain = PublicSuffixService.parse("alpha.google.co.uk")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "google",  domain.sld
    assert_equal "alpha",   domain.trd
  end

  def test_self_parse_a_domain_with_tld_and_sld_and_4rd
    domain = PublicSuffixService.parse("one.two.google.com")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal "one.two", domain.trd

    domain = PublicSuffixService.parse("one.two.google.co.uk")
    assert_instance_of PublicSuffixService::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "google",  domain.sld
    assert_equal "one.two", domain.trd
  end

  def test_self_parse_should_raise_with_invalid_domain
    error = assert_raise(PublicSuffixService::DomainInvalid) { PublicSuffixService.parse("google.zip") }
    assert_match %r{google\.zip}, error.message
  end


  def test_self_valid_question
    assert  PublicSuffixService.valid?("google.com")
    assert  PublicSuffixService.valid?("www.google.com")
    assert  PublicSuffixService.valid?("google.co.uk")
    assert  PublicSuffixService.valid?("www.google.co.uk")
    assert !PublicSuffixService.valid?("google.zip")
    assert !PublicSuffixService.valid?("www.google.zip")
  end

end