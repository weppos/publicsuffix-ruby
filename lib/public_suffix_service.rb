#--
# Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2011 Simone Carletti <weppos@weppos.net>
#++


warn("DEPRECATION WARNING: The PublicSuffixService gem is now known as PublicSuffix. Please install `public_suffix` instead of `public_suffix_service`.")

require 'public_suffix'

PublicSuffixService = PublicSuffix
