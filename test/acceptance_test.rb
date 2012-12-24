require 'test_helper'

class AcceptanceTest < Test::Unit::TestCase

  ValidCases = {
    "google.com" => [nil, "google", "com"],
    "foo.google.com" => ["foo", "google", "com"],

    "verybritish.co.uk" => [nil, "verybritish", "co.uk"],
    "foo.verybritish.co.uk" => ["foo", "verybritish", "co.uk"],

    "parliament.uk" => [nil, "parliament", "uk"],
    "foo.parliament.uk" => ["foo", "parliament", "uk"],
  }

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
    ["http://www.google.com",   PublicSuffix::DomainInvalid],
    [nil,                       PublicSuffix::DomainInvalid],
    ["",                        PublicSuffix::DomainInvalid],
    ["  ",                      PublicSuffix::DomainInvalid],
  ]

  def test_invalid
    InvalidCases.each do |(name, error)|
      assert_raise(error) { PublicSuffix.parse(name) }
      assert !PublicSuffix.valid?(name)
    end
  end

end