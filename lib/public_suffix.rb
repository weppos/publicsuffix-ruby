#--
# Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2014 Simone Carletti <weppos@weppos.net>
#++


require 'public_suffix/domain'
require 'public_suffix/version'
require 'public_suffix/errors'
require 'public_suffix/rule'
require 'public_suffix/list'


module PublicSuffix

  NAME            = "Public Suffix"
  GEM             = "public_suffix"
  AUTHORS         = ["Simone Carletti <weppos@weppos.net>"]


  # Parses +domain+ and returns the
  # {PublicSuffix::Domain} instance.
  #
  # @param  [String, #to_s] domain
  #   The domain name or fully qualified domain name to parse.
  # @param  [PublicSuffix::List] list
  #   The rule list to search, defaults to the default {PublicSuffix::List}
  #
  # @return [PublicSuffix::Domain]
  #
  # @example Parse a valid domain
  #   PublicSuffix.parse("google.com")
  #   # => #<PublicSuffix::Domain ...>
  #
  # @example Parse a valid subdomain
  #   PublicSuffix.parse("www.google.com")
  #   # => #<PublicSuffix::Domain ...>
  #
  # @example Parse a fully qualified domain
  #   PublicSuffix.parse("google.com.")
  #   # => #<PublicSuffix::Domain ...>
  #
  # @example Parse a fully qualified domain (subdomain)
  #   PublicSuffix.parse("www.google.com.")
  #   # => #<PublicSuffix::Domain ...>
  #
  # @example Parse an invalid domain
  #   PublicSuffix.parse("x.yz")
  #   # => PublicSuffix::DomainInvalid
  #
  # @example Parse an URL (not supported, only domains)
  #   PublicSuffix.parse("http://www.google.com")
  #   # => PublicSuffix::DomainInvalid
  #
  # @raise [PublicSuffix::Error]
  #   If domain is not a valid domain.
  # @raise [PublicSuffix::DomainNotAllowed]
  #   If a rule for +domain+ is found, but the rule
  #   doesn't allow +domain+.
  #
  def self.parse(domain, list = List.default)
    rule = list.find(domain)

    if rule.nil?
      raise DomainInvalid, "`#{domain}' is not a valid domain"
    end
    if !rule.allow?(domain)
      raise DomainNotAllowed, "`#{domain}' is not allowed according to Registry policy"
    end

    left, right = rule.decompose(domain)

    parts = left.split(".")
    # If we have 0 parts left, there is just a tld and no domain or subdomain
    # If we have 1 part  left, there is just a tld, domain and not subdomain
    # If we have 2 parts left, the last part is the domain, the other parts (combined) are the subdomain
    tld = right
    sld = parts.empty? ? nil : parts.pop
    trd = parts.empty? ? nil : parts.join(".")

    Domain.new(tld, sld, trd)
  end

  # Checks whether +domain+ is assigned and allowed,
  # without actually parsing it.
  #
  # This method doesn't care whether domain is a domain or subdomain.
  # The validation is performed using the default {PublicSuffix::List}.
  #
  # @param  [String, #to_s] domain
  #   The domain name or fully qualified domain name to validate.
  #
  # @return [Boolean]
  #
  # @example Validate a valid domain
  #   PublicSuffix.valid?("example.com")
  #   # => true
  #
  # @example Validate a valid subdomain
  #   PublicSuffix.valid?("www.example.com")
  #   # => true
  #
  # @example Validate a not-assigned domain
  #   PublicSuffix.valid?("example.qqq")
  #   # => false
  #
  # @example Validate a not-allowed domain
  #   PublicSuffix.valid?("example.do")
  #   # => false
  #   PublicSuffix.valid?("www.example.do")
  #   # => true
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
  def self.valid?(domain)
    rule = List.default.find(domain)
    !rule.nil? && rule.allow?(domain)
  end

end
