#--
# Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2014 Simone Carletti <weppos@weppos.net>
#++


module PublicSuffix

  module Version
    MAJOR = 1
    MINOR = 4
    PATCH = 6
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join(".")
  end

  VERSION = Version::STRING

end
