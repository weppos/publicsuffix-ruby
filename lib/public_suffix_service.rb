#
# = Public Suffix Service
#
# Domain Name parser based on the Public Suffix List
#
#
# Category::    Net
# Package::     PublicSuffixService
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


require 'public_suffix_service/domain'
require 'public_suffix_service/version'
require 'public_suffix_service/errors'
require 'public_suffix_service/rule'
require 'public_suffix_service/rule_list'


module PublicSuffixService

  NAME            = "Public Suffix Service"
  GEM             = "public_suffix_service"
  AUTHORS         = ["Simone Carletti <weppos@weppos.net>"]


  # Parses +domain+ and returns the
  # {PublicSuffixService::Domain} instance.
  #
  # Parsing uses the default {PublicSuffixService::RuleList}.
  #
  # @param  [String, #to_s] domain
  #   The domain name or fully qualified domain name to parse.
  #
  # @return [PublicSuffixService::Domain]
  #
  # @example Parse a valid domain
  #   PublicSuffixService.parse("google.com")
  #   # => #<PubliSuffixService::Domain ...>
  # 
  # @example Parse a valid subdomain
  #   PublicSuffixService.parse("www.google.com")
  #   # => #<PubliSuffixService::Domain ...>
  # 
  # @example Parse a fully qualified domain
  #   PublicSuffixService.parse("google.com.")
  #   # => #<PubliSuffixService::Domain ...>
  # 
  # @example Parse a fully qualified domain (subdomain)
  #   PublicSuffixService.parse("www.google.com.")
  #   # => #<PubliSuffixService::Domain ...>
  #
  # @example Parse an invalid domain
  #   PublicSuffixService.parse("x.yz")
  #   # => PublicSuffixService::DomainInvalid
  #
  # @example Parse an URL (not supported, only domains)
  #   PublicSuffixService.parse("http://www.google.com")
  #   # => PublicSuffixService::DomainInvalid
  #
  # @raise [PublicSuffixService::Error]
  #   If domain is not a valid domain.
  # @raise [PublicSuffixService::DomainNotAllowed]
  #   If a rule for +domain+ is found, but the rule
  #   doesn't allow +domain+.
  #
  def self.parse(domain)
    rule = RuleList.default.find(domain)
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
  # The validation is performed using the default {PublicSuffixService::RuleList}.
  #
  # @param  [String, #to_s] domain
  #   The domain name or fully qualified domain name to validate.
  #
  # @return [Boolean]
  #
  # @example Validate a valid domain
  #   PublicSuffixService.valid?("example.com")
  #   # => true
  #
  # @example Validate a valid subdomain
  #   PublicSuffixService.valid?("www.example.com")
  #   # => true
  #
  # @example Validate a not-assigned domain
  #   PublicSuffixService.valid?("example.zip")
  #   # => false
  #
  # @example Validate a not-allowed domain
  #   PublicSuffixService.valid?("example.do")
  #   # => false
  #   PublicSuffixService.valid?("www.example.do")
  #   # => true
  # 
  # @example Validate a fully qualified domain
  #   PublicSuffixService.valid?("google.com.")
  #   # => true
  #   PublicSuffixService.valid?("www.google.com.")
  #   # => true
  #
  # @example Check an URL (which is not a valid domain)
  #   PublicSuffixService.valid?("http://www.example.com")
  #   # => false
  #
  def self.valid?(domain)
    rule = RuleList.default.find(domain)
    !rule.nil? && rule.allow?(domain)
  end

end
