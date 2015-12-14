#
# Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2015 Simone Carletti <weppos@weppos.net>
#

module PublicSuffix

  module Version
    MAJOR = 1
    MINOR = 5
    PATCH = 3
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join(".")
  end

  VERSION = Version::STRING

end
