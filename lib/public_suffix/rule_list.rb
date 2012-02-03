#--
# Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2012 Simone Carletti <weppos@weppos.net>
#++


warn("The PublicSuffix::RuleList object has been deprecated and will be removed in PublicSuffix 1.1. Please use PublicSuffix::List instead.")

module PublicSuffix
  RuleList = List
end
