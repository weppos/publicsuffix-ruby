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
    MINOR = 2
    PATCH = 0
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join(".")
  end

  VERSION = Version::STRING

end