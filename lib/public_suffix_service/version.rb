#--
# Public Suffix Service
#
# Domain Name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2011 Simone Carletti <weppos@weppos.net>
#++


module PublicSuffixService

  module Version
    MAJOR = 0
    MINOR = 8
    PATCH = 4
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join(".")
  end

  VERSION = Version::STRING

end
