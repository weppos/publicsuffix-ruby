#--
# Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2014 Simone Carletti <weppos@weppos.net>
#++


module PublicSuffix

  class Error < StandardError
  end

  # Raised when trying to parse an invalid domain.
  # A domain is considered invalid when no rule is found
  # in the definition list.
  #
  # @example
  #
  #   PublicSuffix.parse("nic.test")
  #   # => PublicSuffix::DomainInvalid
  #
  #   PublicSuffix.parse("http://www.nic.it")
  #   # => PublicSuffix::DomainInvalid
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
  #   PublicSuffix.parse("nic.do")
  #   # => PublicSuffix::DomainNotAllowed
  #
  #   PublicSuffix.parse("www.nic.do")
  #   # => PublicSuffix::Domain
  #
  class DomainNotAllowed < DomainInvalid
  end


  # Backward Compatibility
  #
  # @deprecated Use {PublicSuffix::DomainInvalid}.
  #
  InvalidDomain = DomainInvalid

end
