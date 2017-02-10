$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require_relative "object_binsize"
require "public_suffix/trie_array"
require "public_suffix/trie_hash"
require "public_suffix/trie_hash_parts"
require "public_suffix/trie_hash_symbol"

ROOT = File.expand_path("../../", __dir__)
rules = File.read(ROOT + "/data/rules-ascii.txt").split("\n").each


@trie_hash    = PublicSuffix::TrieHash.new
@trie_symbol  = PublicSuffix::TrieHashSymbol.new
@trie_parts   = PublicSuffix::TrieHashParts.new
@trie_array   = PublicSuffix::TrieArray.new

rules.each do |word|
  @trie_hash.insert(word)
  @trie_symbol.insert(word)
  @trie_parts.insert(word)
  @trie_array.insert(word)
end

prof = ObjectBinsize.new
prof.report(@trie_hash, label: "@trie_hash")
prof.report(@trie_symbol, label: "@trie_symbol")
prof.report(@trie_parts, label: "@trie_parts")
prof.report(@trie_array, label: "@trie_array")
