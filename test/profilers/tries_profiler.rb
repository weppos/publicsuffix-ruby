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
  @trie = case ARGV.first
  when "hash"
    PublicSuffix::TrieHash.new
  when "hash-symbol"
    PublicSuffix::TrieHashSymbol.new
  when "hash-parts"
    PublicSuffix::TrieHashParts.new
  when "array"
    PublicSuffix::TrieArray.new
  else
    abort("Please select a Trie to test")
  end
  rules.each { |word| @trie.insert(word) }
end

report.pretty_print
