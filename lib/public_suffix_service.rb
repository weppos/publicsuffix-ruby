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


  # Parses <tt>domain</tt> and returns the
  # PubliSuffixService::Domain instance.
  #
  # domain - The String domain name to parse.
  #
  # Examples
  #
  #   PublicSuffixService.parse("google.com")
  #   # => #<PubliSuffixService::Domain ...>
  #   
  #   PublicSuffixService.parse("www.google.com")
  #   # => #<PubliSuffixService::Domain ...>
  #   
  #   PublicSuffixService.parse("http://www.google.com")
  #   # => PublicSuffixService::InvalidDomain
  #   
  #   PublicSuffixService.parse("x.yz")
  #   # => PublicSuffixService::InvalidDomain
  #
  # Raises PublicSuffixService::Error if domain is not a valid domain
  #
  # Returns the PubliSuffixService::Domain domain.
  def self.parse(domain)
    rule = RuleList.default.find(domain) || raise(InvalidDomain, "`#{domain}' is not a valid domain")

    left, right = rule.decompose(domain)
    parts       = left.split(".")

    # If we have 0 parts left, there is just a tld and no domain or subdomain
    # If we have 1 part  left, there is just a tld, domain and not subdomain
    # If we have 2 parts left, the last part is the domain, the other parts (combined) are the subdomain
    tld = right
    sld = parts.empty? ? nil : parts.pop
    trd = parts.empty? ? nil : parts.join(".")

    Domain.new(tld, sld, trd)
  end

  # Checks whether <tt>domain</tt> is a valid domain name.
  #
  # This method doesn't care whether domain is a domain or subdomain.
  # The check is performed using the default PublicSuffixService::RuleList.
  #
  # domain - The String domain name to parse.
  #
  # Examples
  #
  #   PublicSuffixService.valid?("google.com")
  #   # => true
  #   
  #   PublicSuffixService.valid?("www.google.com")
  #   # => true
  #   
  #   PublicSuffixService.valid?("http://www.google.com")
  #   # => false
  #   
  #   PublicSuffixService.valid?("x.yz")
  #   # => false
  #
  # Returns Boolean.
  def self.valid?(domain)
    !RuleList.default.find(domain).nil?
  end

end
