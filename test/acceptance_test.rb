require 'test_helper'

class AcceptanceTest < Minitest::Unit::TestCase

  ValidCases = [
      ["google.com",              [nil, "google", "com"]],
      ["foo.google.com",          ["foo", "google", "com"]],

      ["verybritish.co.uk",       [nil, "verybritish", "co.uk"]],
      ["foo.verybritish.co.uk",   ["foo", "verybritish", "co.uk"]],

      ["parliament.uk",           [nil, "parliament", "uk"]],
      ["foo.parliament.uk",       ["foo", "parliament", "uk"]],
  ]

  def test_valid
    ValidCases.each do |name, results|
      domain = PublicSuffix.parse(name)
      trd, sld, tld = results
      assert_equal tld, domain.tld, "Invalid tld for '#{name}'"
      assert_equal sld, domain.sld, "Invalid sld for '#{name}'"
      assert_equal trd, domain.trd, "Invalid trd for '#{name}'"
      assert PublicSuffix.valid?(name)
    end
  end


  InvalidCases = [
      ["nic.ke",                  PublicSuffix::DomainNotAllowed],
      [nil,                       PublicSuffix::DomainInvalid],
      ["",                        PublicSuffix::DomainInvalid],
      ["  ",                      PublicSuffix::DomainInvalid],
  ]

  def test_invalid
    InvalidCases.each do |(name, error)|
      assert_raises(error) { PublicSuffix.parse(name) }
      assert !PublicSuffix.valid?(name)
    end
  end


  RejectedCases = [
      ["www. .com",           true],
      ["foo.co..uk",          true],
      ["goo,gle.com",         true],
      ["-google.com",         true],
      ["google-.com",         true],

      # This case was covered in GH-15.
      # I decide to cover this case because it's not easily reproducible with URI.parse
      # and can lead to several false positives.
      ["http://google.com",   false],
  ]

  def test_rejected
    RejectedCases.each do |name, expected|
      assert_equal expected, PublicSuffix.valid?(name)
      assert !valid_domain?(name), "#{name} expected to be invalid"
    end
  end

  
  CaseCases = [
      ["Www.google.com",          ["www", "google", "com"]],
      ["www.Google.com",          ["www", "google", "com"]],
      ["www.google.Com",          ["www", "google", "com"]],
  ]

  def test_ignore_case
    CaseCases.each do |name, results|
      domain = PublicSuffix.parse(name)
      trd, sld, tld = results
      assert_equal tld, domain.tld, "Invalid tld for `#{name}'"
      assert_equal sld, domain.sld, "Invalid sld for `#{name}'"
      assert_equal trd, domain.trd, "Invalid trd for `#{name}'"
      assert PublicSuffix.valid?(name)
    end
  end


  def valid_uri?(name)
    uri = URI.parse(name)
    uri.host != nil
  rescue
    false
  end

  def valid_domain?(name)
    uri = URI.parse(name)
    uri.host != nil && uri.scheme.nil?
  rescue
    false
  end

end