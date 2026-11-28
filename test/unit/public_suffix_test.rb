# frozen_string_literal: true

require "test_helper"

class PublicSuffixTest < Minitest::Test

  def test_private_domains_enabled_by_default
    domain = PublicSuffix.parse("www.example.blogspot.com")

    assert_equal "blogspot.com", domain.tld

    domain = PublicSuffix.parse("example.s3.cn-north-1.amazonaws.com.cn")

    assert_equal "s3.cn-north-1.amazonaws.com.cn", domain.tld
  end

  def test_private_domains_disable
    data = File.read(PublicSuffix::List::DEFAULT_LIST_PATH)
    PublicSuffix::List.default = PublicSuffix::List.parse(data, private_domains: false)
    domain = PublicSuffix.parse("www.example.blogspot.com")

    assert_equal "com", domain.tld
  ensure
    PublicSuffix::List.default = nil
  end


  def test_self_parse_a_domain_with_tld_and_sld
    domain = PublicSuffix.parse("example.com")

    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_nil              domain.trd

    domain = PublicSuffix.parse("example.co.uk")

    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "co.uk",   domain.tld
    assert_equal "example", domain.sld
    assert_nil              domain.trd
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

  def test_self_parse_name_fqdn
    domain = PublicSuffix.parse("www.example.com.")

    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "com",     domain.tld
    assert_equal "example", domain.sld
    assert_equal "www",     domain.trd
  end

  def test_self_parse_with_custom_list
    list = PublicSuffix::List.new
    list << PublicSuffix::Rule.factory("test")

    domain = PublicSuffix.parse("www.example.test", list: list)

    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "test",    domain.tld
    assert_equal "example", domain.sld
    assert_equal "www",     domain.trd
  end

  def test_self_parse_with_notlisted_name
    domain = PublicSuffix.parse("example.tldnotlisted")

    assert_instance_of PublicSuffix::Domain, domain
    assert_equal "tldnotlisted",    domain.tld
    assert_equal "example",         domain.sld
    assert_nil                      domain.trd
  end

  def test_self_parse_with_unallowed_domain
    error = assert_raises(PublicSuffix::DomainNotAllowed) { PublicSuffix.parse("example.er") }
    assert_match(/example\.er/, error.message)
  end

  def test_self_parse_with_uri
    error = assert_raises(PublicSuffix::DomainInvalid) { PublicSuffix.parse("http://google.com") }
    assert_match(%r{http://google\.com}, error.message)
  end


  def test_self_valid
    assert PublicSuffix.valid?("google.com")
    assert PublicSuffix.valid?("www.google.com")
    assert PublicSuffix.valid?("google.co.uk")
    assert PublicSuffix.valid?("www.google.co.uk")
  end

  def test_self_valid_with_notlisted_name
    assert PublicSuffix.valid?("google.tldnotlisted")
    assert PublicSuffix.valid?("www.google.tldnotlisted")
  end


  def test_self_domain
    assert_equal "google.com",    PublicSuffix.domain("google.com")
    assert_equal "google.com",    PublicSuffix.domain("www.google.com")
    assert_equal "google.co.uk",  PublicSuffix.domain("google.co.uk")
    assert_equal "google.co.uk",  PublicSuffix.domain("www.google.co.uk")
  end

  def test_self_domain_with_notlisted_name
    assert_equal "example.tldnotlisted", PublicSuffix.domain("example.tldnotlisted")
  end

  def test_self_domain_with_unallowed_name
    assert_nil PublicSuffix.domain("example.er")
  end

  def test_self_domain_with_blank_sld
    assert_nil PublicSuffix.domain("com")
    assert_nil PublicSuffix.domain(".com")
  end


  def test_self_valid_with_a_byte_string
    assert PublicSuffix.valid?("evil.\u516C\u53F8.cn".b)
    refute PublicSuffix.valid?("\u516C\u53F8.cn".b)
  end

  def test_self_domain_with_a_byte_string
    name = "evil.\u516C\u53F8.cn"

    assert_equal name, PublicSuffix.domain(name.b)
    assert_equal "google.co.uk", PublicSuffix.domain("www.google.co.uk".b)
  end

  def test_self_domain_with_a_list_parsed_from_a_byte_string
    list = PublicSuffix::List.parse("\u516C\u53F8.cn".b)
    name = "evil.\u516C\u53F8.cn"

    assert_equal name, PublicSuffix.domain(name, list: list)
    assert_equal name, PublicSuffix.domain(name.b, list: list)
  end

  def test_self_domain_with_another_encoding
    assert_equal "google.co.uk", PublicSuffix.domain("www.google.co.uk".encode("UTF-16LE"))
  end

  def test_self_domain_with_an_invalid_encoding
    assert_nil PublicSuffix.domain("www.google.co.uk\xFF".dup.force_encoding("UTF-8"))
  end

  def test_self_parse_with_an_invalid_encoding
    error = assert_raises(PublicSuffix::DomainInvalid) do
      PublicSuffix.parse("www.google.co.uk\xFF".dup.force_encoding("UTF-8"))
    end

    assert_match(/UTF-8/, error.message)
  end

  def test_self_normalize
    [
      ["com", "com"],
      ["example.com", "example.com"],
      ["www.example.com", "www.example.com"],

      ["example.com.",  "example.com"],     # strip FQDN
      [" example.com ", "example.com"],     # strip spaces
      ["Example.COM",   "example.com"],     # downcase
    ].each do |input, output|
      assert_equal output, PublicSuffix.normalize(input)
    end
  end

  def test_normalize_blank
    [
      nil,
      "",
      " ",
    ].each do |input|
      error = PublicSuffix.normalize(input)

      assert_instance_of PublicSuffix::DomainInvalid, error
      assert_equal "Name is blank", error.message
    end
  end

  def test_normalize_scheme
    [
      "https://google.com",
    ].each do |input|
      error = PublicSuffix.normalize(input)

      assert_instance_of PublicSuffix::DomainInvalid, error
      assert_match(/scheme/, error.message)
    end
  end

  def test_normalize_leading_dot
    [
      ".google.com",
    ].each do |input|
      error = PublicSuffix.normalize(input)

      assert_instance_of PublicSuffix::DomainInvalid, error
      assert_match "Name starts with a dot", error.message
    end
  end

  def test_normalize_with_a_byte_string
    name = "evil.\u516C\u53F8.cn"
    normalized = PublicSuffix.normalize(name.b)

    assert_equal name, normalized
    assert_equal Encoding::UTF_8, normalized.encoding
  end

  def test_normalize_with_another_encoding
    [
      ["example.com".encode("UTF-16LE"), "example.com"],
      ["example.com".encode("US-ASCII"), "example.com"],
      ["caf\u00E9.example.com".encode("ISO-8859-1"), "caf\u00E9.example.com"],
    ].each do |input, output|
      assert_equal output, PublicSuffix.normalize(input)
    end
  end

  def test_normalize_with_an_invalid_encoding
    [
      "example.com\xFF".dup.force_encoding("UTF-8"),
      "example.com\xFF".dup.force_encoding("BINARY"),
    ].each do |input|
      error = PublicSuffix.normalize(input)

      assert_instance_of PublicSuffix::DomainInvalid, error
      assert_equal "Name is not valid UTF-8", error.message
    end
  end

end
