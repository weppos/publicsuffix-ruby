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

  class InvalidDomain < Error
  class DomainInvalid < Error
  end


  # Backward Compatibility
  InvalidDomain = DomainInvalid

end
