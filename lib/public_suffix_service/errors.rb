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


module PublicSuffixService

  class Error < StandardError
  end

  # Raised when trying to parse an invalid domain.
  # A domain is considered invalid when no rule is found
  # in the definition list.
  #
  # Since 0.6.0
  class DomainInvalid < Error
  end

  # Raised when trying to parse a domain
  # which is formally defined by a rule,
  # but the rules set a requirement which is not satisfied
  # by the input you are trying to parse.
  #
  # Since 0.6.0
  #
  # Examples
  #
  #   PublicSuffixService.parse("nic.do")
  #   # => PublicSuffixService::DomainNotAllowed
  #
  #   PublicSuffixService.parse("www.nic.do")
  #   # => PublicSuffixService::Domain
  #
  class DomainNotAllowed < DomainInvalid
  end


  # Backward Compatibility
  InvalidDomain = DomainInvalid

end
