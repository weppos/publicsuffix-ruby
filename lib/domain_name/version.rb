#
# = DomainName
#
# Domain Name parser based on the Public Suffix List
#
#
# Category::    Net
# Package::     DomainName
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


class DomainName

  module Version
    MAJOR = 0
    MINOR = 0
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].join('.')
  end

  VERSION         = Version::STRING
  STATUS          = 'dev'
  BUILD           = nil

end