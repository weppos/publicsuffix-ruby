# = Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2018 Simone Carletti <weppos@weppos.net>

require_relative "public_suffix/domain"
require_relative "public_suffix/version"
require_relative "public_suffix/errors"
require_relative "public_suffix/rules"
require_relative "public_suffix/list"

# PublicSuffix is a Ruby domain name parser based on the Public Suffix List.
#
# The [Public Suffix List](https://publicsuffix.org) is a cross-vendor initiative
# to provide an accurate list of domain name suffixes.
#
# The Public Suffix List is an initiative of the Mozilla Project,
# but is maintained as a community resource. It is available for use in any software,
# but was originally created to meet the needs of browser manufacturers.
module PublicSuffix

  DOT   = ".".freeze
  BANG  = "!".freeze
  STAR  = "*".freeze

  # Parses +name+ and returns the {PublicSuffix::Domain} instance.
  #
  # @example Parse a valid domain
  #   PublicSuffix.parse("google.com")
  #   # => #<PublicSuffix::Domain:0x007fec2e51e588 @sld="google", @tld="com", @trd=nil>
  #
  # @example Parse a valid subdomain
  #   PublicSuffix.parse("www.google.com")
  #   # => #<PublicSuffix::Domain:0x007fec276d4cf8 @sld="google", @tld="com", @trd="www">
  #
  # @example Parse a fully qualified domain
  #   PublicSuffix.parse("google.com.")
  #   # => #<PublicSuffix::Domain:0x007fec257caf38 @sld="google", @tld="com", @trd=nil>
  #
  # @example Parse a fully qualified domain (subdomain)
  #   PublicSuffix.parse("www.google.com.")
  #   # => #<PublicSuffix::Domain:0x007fec27b6bca8 @sld="google", @tld="com", @trd="www">
  #
  # @example Parse an invalid (unlisted) domain
  #   PublicSuffix.parse("x.yz")
  #   # => #<PublicSuffix::Domain:0x007fec2f49bec0 @sld="x", @tld="yz", @trd=nil>
  #
  # @example Parse an invalid (unlisted) domain with strict checking (without applying the default * rule)
  #   PublicSuffix.parse("x.yz", default_rule: nil)
  #   # => PublicSuffix::DomainInvalid: `x.yz` is not a valid domain
  #
  # @example Parse an URL (not supported, only domains)
  #   PublicSuffix.parse("http://www.google.com")
  #   # => PublicSuffix::DomainInvalid: http://www.google.com is not expected to contain a scheme
  #
  #
  # @param  [String, #to_s] name The domain name or fully qualified domain name to parse.
  # @param  [PublicSuffix::List] list The rule list to search, defaults to the default {PublicSuffix::List}
  # @param  [Boolean] ignore_private
  # @return [PublicSuffix::Domain]
  #
  # @raise [PublicSuffix::DomainInvalid]
  #   If domain is not a valid domain.
  # @raise [PublicSuffix::DomainNotAllowed]
  #   If a rule for +domain+ is found, but the rule doesn't allow +domain+.
  def self.parse(name, list: List.default, ignore_private: false)
    what = normalize(name)
    raise what if what.is_a?(DomainInvalid)

    rule = list.find(what, ignore_private: ignore_private)

    # rubocop:disable Style/IfUnlessModifier
    if rule.nil?
      raise DomainInvalid, "`#{what}` is not a valid domain"
    end
    # rubocop:enable Style/IfUnlessModifier

    decompose(what, rule)
  end

  # Checks whether +domain+ is assigned and allowed, without actually parsing it.
  #
  # This method doesn't care whether domain is a domain or subdomain.
  # The validation is performed using the default {PublicSuffix::List}.
  #
  # @example Validate a valid domain
  #   PublicSuffix.valid?("example.com")
  #   # => true
  #
  # @example Validate a valid subdomain
  #   PublicSuffix.valid?("www.example.com")
  #   # => true
  #
  # @example Validate a not-listed domain
  #   PublicSuffix.valid?("example.tldnotlisted")
  #   # => true
  #
  # @example Validate a not-listed domain with strict checking (without applying the default * rule)
  #   PublicSuffix.valid?("example.tldnotlisted")
  #   # => true
  #   PublicSuffix.valid?("example.tldnotlisted", default_rule: nil)
  #   # => false
  #
  # @example Validate a fully qualified domain
  #   PublicSuffix.valid?("google.com.")
  #   # => true
  #   PublicSuffix.valid?("www.google.com.")
  #   # => true
  #
  # @example Check an URL (which is not a valid domain)
  #   PublicSuffix.valid?("http://www.example.com")
  #   # => false
  #
  #
  # @param  [String, #to_s] name The domain name or fully qualified domain name to validate.
  # @param  [Boolean] ignore_private
  # @return [Boolean]
  def self.valid?(name, list: List.default, ignore_private: false)
    !normalize(name).is_a?(DomainInvalid)
  end

  # Attempt to parse the name and returns the domain, if valid.
  #
  # This method doesn't raise. Instead, it returns nil if the domain is not valid for whatever reason.
  #
  # @param  [String, #to_s] name The domain name or fully qualified domain name to parse.
  # @param  [PublicSuffix::List] list The rule list to search, defaults to the default {PublicSuffix::List}
  # @param  [Boolean] ignore_private
  # @return [String]
  def self.domain(name, **options)
    parse(name, **options).domain
  rescue PublicSuffix::Error
    nil
  end


  # private

  def self.decompose(name, rule)
    rule_len = rule.split(DOT).length
    parts = name.split(DOT)

    # If we have 0 parts left, there is just a tld and no domain or subdomain
    # If we have 1 part  left, there is just a tld, domain and not subdomain
    # If we have 2 parts left, the last part is the domain, the other parts (combined) are the subdomain
    tld = rule.empty?  ? nil : parts.pop(rule_len).join(DOT)
    sld = parts.empty? ? nil : parts.pop
    trd = parts.empty? ? nil : parts.join(DOT)

    Domain.new(tld, sld, trd)
  end

  # Pretend we know how to deal with user input.
  def self.normalize(name)
    name = name.to_s.dup
    name.strip!
    name.chomp!(DOT)
    name.downcase!

    return DomainInvalid.new("Name is blank") if name.empty?
    return DomainInvalid.new("Name starts with a dot") if name.start_with?(DOT)
    return DomainInvalid.new("%s is not expected to contain a scheme" % name) if name.include?("://")
    name
  end

end
