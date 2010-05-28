require 'test_helper'

class DomainNameTest < Test::Unit::TestCase

  def test_initialize_with_tld
    domain = DomainName.new("com")
    assert_equal "com",     domain.tld
    assert_equal nil,       domain.sld
    assert_equal nil,       domain.trd
  end

  def test_initialize_with_tld_and_sld
    domain = DomainName.new("com", "google")
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal nil,       domain.trd
  end

  def test_initialize_with_tld_and_sld_and_trd
    domain = DomainName.new("com", "google", "www")
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal "www",     domain.trd
  end


  def test_to_s
    assert_equal "com",             DomainName.new("com").to_s
    assert_equal "google.com",      DomainName.new("com", "google").to_s
    assert_equal "www.google.com",  DomainName.new("com", "google", "www").to_s
  end

  def test_to_a
    assert_equal [nil, nil, "com"],         DomainName.new("com").to_a
    assert_equal [nil, "google", "com"],    DomainName.new("com", "google").to_a
    assert_equal ["www", "google", "com"],  DomainName.new("com", "google", "www").to_a
  end


  def test_tld
    assert_equal "com", DomainName.new("com", "google", "www").tld
  end

  def test_sld
    assert_equal "google", DomainName.new("com", "google", "www").sld
  end

  def test_tld
    assert_equal "www", DomainName.new("com", "google", "www").trd
  end


  def test_name
    assert_equal "com",             DomainName.new("com").name
    assert_equal "google.com",      DomainName.new("com", "google").name
    assert_equal "www.google.com",  DomainName.new("com", "google", "www").name
  end

  def test_domain
    assert_equal nil, DomainName.new("com").domain
    assert_equal nil, DomainName.new("zip").domain
    assert_equal "google.com", DomainName.new("com", "google").domain
    assert_equal "google.zip", DomainName.new("zip", "google").domain
    assert_equal "google.com", DomainName.new("com", "google", "www").domain
    assert_equal "google.zip", DomainName.new("zip", "google", "www").domain
  end

  def test_subdomain
    assert_equal nil, DomainName.new("com").subdomain
    assert_equal nil, DomainName.new("zip").subdomain
    assert_equal nil, DomainName.new("com", "google").subdomain
    assert_equal nil, DomainName.new("zip", "google").subdomain
    assert_equal "www.google.com", DomainName.new("com", "google", "www").subdomain
    assert_equal "www.google.zip", DomainName.new("zip", "google", "www").subdomain
  end

  def test_rule
    assert_equal nil,                             DomainName.new("zip").rule
    assert_equal DomainName::Rule.factory("com"), DomainName.new("com").rule
    assert_equal DomainName::Rule.factory("com"), DomainName.new("com", "google").rule
    assert_equal DomainName::Rule.factory("com"), DomainName.new("com", "google", "www").rule
  end


  def test_domain_question
    assert  DomainName.new("com", "google").domain?
    assert  DomainName.new("zip", "google").domain?
    assert  DomainName.new("com", "google", "www").domain?
    assert !DomainName.new("com").domain?
  end

  def test_subdomain_question
    assert  DomainName.new("com", "google", "www").subdomain?
    assert  DomainName.new("zip", "google", "www").subdomain?
    assert !DomainName.new("com").subdomain?
    assert !DomainName.new("com", "google").subdomain?
  end

  def test_is_a_domain_question
    assert  DomainName.new("com", "google").is_a_domain?
    assert  DomainName.new("zip", "google").is_a_domain?
    assert !DomainName.new("com", "google", "www").is_a_domain?
    assert !DomainName.new("com").is_a_domain?
  end

  def test_is_a_subdomain_question
    assert  DomainName.new("com", "google", "www").is_a_subdomain?
    assert  DomainName.new("zip", "google", "www").is_a_subdomain?
    assert !DomainName.new("com").is_a_subdomain?
    assert !DomainName.new("com", "google").is_a_subdomain?
  end

  def test_valid_question
    assert  DomainName.new("com").valid?
    assert  DomainName.new("com", "google").valid?
    assert  DomainName.new("com", "google", "www").valid?
    assert !DomainName.new("zip").valid?
    assert !DomainName.new("zip", "google").valid?
    assert !DomainName.new("zip", "google", "www").valid?
  end

  def test_valid_domain_question
    assert  DomainName.new("com", "google").valid_domain?
    assert !DomainName.new("zip", "google").valid_domain?
    assert  DomainName.new("com", "google", "www").valid_domain?
    assert !DomainName.new("com").valid_domain?
  end

  def test_valid_subdomain_question
    assert  DomainName.new("com", "google", "www").valid_subdomain?
    assert !DomainName.new("zip", "google", "www").valid_subdomain?
    assert !DomainName.new("com").valid_subdomain?
    assert !DomainName.new("com", "google").valid_subdomain?
  end



  def test_self_parse_a_domain_with_tld_and_sld
    domain = DomainName.parse("google.com")
    assert_instance_of DomainName, domain
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal nil,       domain.trd

    domain = DomainName.parse("google.co.uk")
    assert_instance_of DomainName, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "google",  domain.sld
    assert_equal nil,       domain.trd
  end

  def test_self_parse_a_domain_with_tld_and_sld_and_trd
    domain = DomainName.parse("alpha.google.com")
    assert_instance_of DomainName, domain
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal "alpha",   domain.trd

    domain = DomainName.parse("alpha.google.co.uk")
    assert_instance_of DomainName, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "google",  domain.sld
    assert_equal "alpha",   domain.trd
  end

  def test_self_parse_a_domain_with_tld_and_sld_and_4rd
    domain = DomainName.parse("one.two.google.com")
    assert_instance_of DomainName, domain
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal "one.two", domain.trd

    domain = DomainName.parse("one.two.google.co.uk")
    assert_instance_of DomainName, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "google",  domain.sld
    assert_equal "one.two", domain.trd
  end

  def test_self_parse_should_raise_with_invalid_domain
    error = assert_raise(DomainName::InvalidDomain) { DomainName.parse("google.zip") }
    assert_match %r{google\.zip}, error.message
  end


  def test_self_valid_question
    assert  DomainName.valid?("google.com")
    assert  DomainName.valid?("www.google.com")
    assert  DomainName.valid?("google.co.uk")
    assert  DomainName.valid?("www.google.co.uk")
    assert !DomainName.valid?("google.zip")
    assert !DomainName.valid?("www.google.zip")
  end

end