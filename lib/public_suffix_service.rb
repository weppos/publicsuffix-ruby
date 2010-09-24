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
  # @param  [String, #to_s] domain The domain name to parse.
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
  # @example Parse an invalid domain
  #   PublicSuffixService.parse("x.yz")
  #   # => PublicSuffixService::DomainInvalid
  #
  # @example Parse an URL (not supported, only domains)
  #   PublicSuffixService.parse("http://www.google.com")
  #   # => PublicSuffixService::DomainInvalid
  #
  # @raise [PublicSuffixService::Error] if domain is not a valid domain.
  #
  def self.parse(domain)
    rule = RuleList.default.find(domain) || raise(DomainInvalid, "`#{domain}' is not a valid domain")

    left, right = rule.decompose(domain)
    if right.nil?
      raise DomainNotAllowed, "Rule `#{rule.name}' doesn't allow `#{domain}'"
    end

    parts = left.split(".")
    # If we have 0 parts left, there is just a tld and no domain or subdomain
    # If we have 1 part  left, there is just a tld, domain and not subdomain
    # If we have 2 parts left, the last part is the domain, the other parts (combined) are the subdomain
    tld = right
    sld = parts.empty? ? nil : parts.pop
    trd = parts.empty? ? nil : parts.join(".")

    Domain.new(tld, sld, trd)
  end

  # Checks whether +domain+ is a valid domain name,
  # without actually parsing it.
  #
  # This method doesn't care whether domain is a domain or subdomain.
  # The check is performed using the default {PublicSuffixService::RuleList}.
  #
  # @param  [String, #to_s] domain The domain name to parse.
  #
  # @return [Boolean]
  #
  # @example Check a valid domain
  #   PublicSuffixService.valid?("google.com")
  #   # => true
  #
  # @example Check a valid subdomain
  #   PublicSuffixService.valid?("www.google.com")
  #   # => true
  #
  # @example Check an invalid domain
  #   PublicSuffixService.valid?("x.yz")
  #   # => false
  #
  # @example Check an URL (which is not a valid domain)
  #   PublicSuffixService.valid?("http://www.google.com")
  #   # => false
  #
  def self.valid?(domain)
    !RuleList.default.find(domain).nil?
  end

end
