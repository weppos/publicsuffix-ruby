require 'test_helper'

class PublicSuffix::DomainTest < Minitest::Unit::TestCase

  def setup
    @klass = PublicSuffix::Domain
  end

  # Tokenizes given input into labels.
  def test_self_domain_to_labels
    assert_equal  %w( com live spaces someone ),
                  PublicSuffix::Domain.domain_to_labels("someone.spaces.live.com")
    assert_equal  %w( com zoho wiki leontina23samiko ),
                  PublicSuffix::Domain.domain_to_labels("leontina23samiko.wiki.zoho.com")
  end

  # Converts input into String.
  def test_self_domain_to_labels_converts_input_to_string
    assert_equal  %w( com live spaces someone ),
                  PublicSuffix::Domain.domain_to_labels(:"someone.spaces.live.com")
  end

  # Ignores trailing .
  def test_self_domain_to_labels_ignores_trailing_dot
    assert_equal  %w( com live spaces someone ),
                  PublicSuffix::Domain.domain_to_labels("someone.spaces.live.com")
    assert_equal  %w( com live spaces someone ),
                  PublicSuffix::Domain.domain_to_labels(:"someone.spaces.live.com")
  end


  def test_initialize_with_tld
    domain = @klass.new("com")
    assert_equal "com",     domain.tld
    assert_equal nil,       domain.sld
    assert_equal nil,       domain.trd
  end

  def test_initialize_with_tld_and_sld
    domain = @klass.new("com", "google")
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal nil,       domain.trd
  end

  def test_initialize_with_tld_and_sld_and_trd
    domain = @klass.new("com", "google", "www")
    assert_equal "com",     domain.tld
    assert_equal "google",  domain.sld
    assert_equal "www",     domain.trd
  end


  def test_to_s
    assert_equal "com",             @klass.new("com").to_s
    assert_equal "google.com",      @klass.new("com", "google").to_s
    assert_equal "www.google.com",  @klass.new("com", "google", "www").to_s
  end

  def test_to_a
    assert_equal [nil, nil, "com"],         @klass.new("com").to_a
    assert_equal [nil, "google", "com"],    @klass.new("com", "google").to_a
    assert_equal ["www", "google", "com"],  @klass.new("com", "google", "www").to_a
  end


  def test_tld
    assert_equal "com", @klass.new("com", "google", "www").tld
  end

  def test_sld
    assert_equal "google", @klass.new("com", "google", "www").sld
  end

  def test_trd
    assert_equal "www", @klass.new("com", "google", "www").trd
  end


  def test_name
    assert_equal "com",             @klass.new("com").name
    assert_equal "google.com",      @klass.new("com", "google").name
    assert_equal "www.google.com",  @klass.new("com", "google", "www").name
  end

  def test_domain
    assert_equal nil, @klass.new("com").domain
    assert_equal nil, @klass.new("qqq").domain
    assert_equal "google.com", @klass.new("com", "google").domain
    assert_equal "google.qqq", @klass.new("qqq", "google").domain
    assert_equal "google.com", @klass.new("com", "google", "www").domain
    assert_equal "google.qqq", @klass.new("qqq", "google", "www").domain
  end

  def test_subdomain
    assert_equal nil, @klass.new("com").subdomain
    assert_equal nil, @klass.new("qqq").subdomain
    assert_equal nil, @klass.new("com", "google").subdomain
    assert_equal nil, @klass.new("qqq", "google").subdomain
    assert_equal "www.google.com", @klass.new("com", "google", "www").subdomain
    assert_equal "www.google.qqq", @klass.new("qqq", "google", "www").subdomain
  end

  def test_rule
    assert_equal nil, @klass.new("qqq").rule
    assert_equal PublicSuffix::Rule.factory("com"), @klass.new("com").rule
    assert_equal PublicSuffix::Rule.factory("com"), @klass.new("com", "google").rule
    assert_equal PublicSuffix::Rule.factory("com"), @klass.new("com", "google", "www").rule
  end


  def test_domain_question
    assert  @klass.new("com", "google").domain?
    assert  @klass.new("qqq", "google").domain?
    assert  @klass.new("com", "google", "www").domain?
    assert !@klass.new("com").domain?
  end

  def test_subdomain_question
    assert  @klass.new("com", "google", "www").subdomain?
    assert  @klass.new("qqq", "google", "www").subdomain?
    assert !@klass.new("com").subdomain?
    assert !@klass.new("com", "google").subdomain?
  end

  def test_is_a_domain_question
    assert  @klass.new("com", "google").is_a_domain?
    assert  @klass.new("qqq", "google").is_a_domain?
    assert !@klass.new("com", "google", "www").is_a_domain?
    assert !@klass.new("com").is_a_domain?
  end

  def test_is_a_subdomain_question
    assert  @klass.new("com", "google", "www").is_a_subdomain?
    assert  @klass.new("qqq", "google", "www").is_a_subdomain?
    assert !@klass.new("com").is_a_subdomain?
    assert !@klass.new("com", "google").is_a_subdomain?
  end

  def test_valid_question
    assert !@klass.new("com").valid?
    assert  @klass.new("com", "example").valid?
    assert  @klass.new("com", "example", "www").valid?

    # not-assigned
    assert !@klass.new("qqq").valid?
    assert !@klass.new("qqq", "example").valid?
    assert !@klass.new("qqq", "example", "www").valid?

    # not-allowed
    assert !@klass.new("ke").valid?
    assert !@klass.new("ke", "example").valid?
    assert  @klass.new("ke", "example", "www").valid?
  end

  def test_valid_domain_question
    assert  @klass.new("com", "google").valid_domain?
    assert !@klass.new("qqq", "google").valid_domain?
    assert  @klass.new("com", "google", "www").valid_domain?
    assert !@klass.new("com").valid_domain?
  end

  def test_valid_subdomain_question
    assert  @klass.new("com", "google", "www").valid_subdomain?
    assert !@klass.new("qqq", "google", "www").valid_subdomain?
    assert !@klass.new("com").valid_subdomain?
    assert !@klass.new("com", "google").valid_subdomain?
  end

end
