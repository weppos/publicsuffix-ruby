#--
# Public Suffix Service
#
# Domain Name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2011 Simone Carletti <weppos@weppos.net>
#++


module PublicSuffixService

  class Error < StandardError
  end

  # Raised when trying to parse an invalid domain.
  # A domain is considered invalid when no rule is found
  # in the definition list.
  #
  # @example
  #
  #   PublicSuffixService.parse("nic.test")
  #   # => PublicSuffixService::DomainInvalid
  #
  #   PublicSuffixService.parse("http://www.nic.it")
  #   # => PublicSuffixService::DomainInvalid
  #
  # @since 0.6.0
  #
  class DomainInvalid < Error
  end

  # Raised when trying to parse a domain
  # which is formally defined by a rule,
  # but the rules set a requirement which is not satisfied
  # by the input you are trying to parse.
  #
  # @example
  #
  #   PublicSuffixService.parse("nic.do")
  #   # => PublicSuffixService::DomainNotAllowed
  #
  #   PublicSuffixService.parse("www.nic.do")
  #   # => PublicSuffixService::Domain
  #
  # @since 0.6.0
  #
  class DomainNotAllowed < DomainInvalid
  end


  # Backward Compatibility
  #
  # @deprecated Use {PublicSuffixService::DomainInvalid}.
  #
  InvalidDomain = DomainInvalid

end
