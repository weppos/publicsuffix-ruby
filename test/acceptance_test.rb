require 'test_helper'

class AcceptanceTest < Test::Unit::TestCase

  CASES = {
    "google.com" => [nil, "google", "com"],
    "foo.google.com" => ["foo", "google", "com"],

    "verybritish.co.uk" => [nil, "verybritish", "co.uk"],
    "foo.verybritish.co.uk" => ["foo", "verybritish", "co.uk"],

    "parliament.uk" => [nil, "parliament", "uk"],
    "foo.parliament.uk" => ["foo", "parliament", "uk"],
  }

  def test_all
    CASES.each do |name, results|
      domain = DomainName.parse(name)
      trd, sld, tld = results
      assert_equal tld, domain.tld, "Invalid tld for '#{name}'"
      assert_equal sld, domain.sld, "Invalid sld for '#{name}'"
      assert_equal trd, domain.trd, "Invalid trd for '#{name}'"
    end
  end

end