$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require_relative "object_binsize"
require "public_suffix"
require "public_suffix/trie"

list = PublicSuffix::List.default
rules = list.instance_variable_get(:@rules)

@trie = PublicSuffix::Trie.new
rules.keys.each { |word| @trie.insert(word.split(".").reverse.join(".")) }

prof = ObjectBinsize.new
prof.report(rules, label: "@rules")
prof.report(@trie, label: "@trie")
