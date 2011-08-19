#--
# Public Suffix Service
#
# Domain Name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2011 Simone Carletti <weppos@weppos.net>
#++


warn("The PublicSuffixService::RuleList object has been deprecated and will be removed in PublicSuffixService 1.0. Please use PublicSuffixService::List instead.")

module PublicSuffixService
  RuleList = List
end
