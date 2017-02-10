$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "memory_profiler"
require "public_suffix"
require "public_suffix/trie_array"
require "public_suffix/trie_hash"
require "public_suffix/trie_hash_parts"
require "public_suffix/trie_hash_symbol"

ROOT = File.expand_path("../../", __dir__)
rules = File.read(ROOT + "/data/rules-ascii.txt").split("\n").each

report = MemoryProfiler.report do
  case ARGV.first
  when "hash"
    @trie = PublicSuffix::TrieHash.new
    rules.each { |word| @trie.insert(word.reverse) }
  when "hash-symbol"
    @trie = PublicSuffix::TrieHashSymbol.new
    rules.each { |word| @trie.insert(word.reverse) }
  when "hash-parts"
    @trie = PublicSuffix::TrieHashParts.new
    rules.each { |word| @trie.insert(word.split(".").reverse.join(".")) }
  when "array"
    @trie = PublicSuffix::TrieArray.new
    rules.each { |word| @trie.insert(word.reverse) }
  else
    abort("Please select a Trie to test")
  end
end

report.pretty_print
