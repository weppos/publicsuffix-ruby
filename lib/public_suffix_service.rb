#--
# Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2011 Simone Carletti <weppos@weppos.net>
#++


warn("The PublicSuffixService object has been deprecated. Please use PublicSuffix instead.")

require 'public_suffix'

PublicSuffixService = PublicSuffix
