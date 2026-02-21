$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "memory_profiler"
require "public_suffix"
require "public_suffix/trie"

list = PublicSuffix::List.default
puts "#{list.size} rules:"

report = MemoryProfiler.report do
  @trie = PublicSuffix::Trie.new
  list.instance_variable_get(:@rules).keys { |word| @trie.insert(word.split(".").reverse.join(".")) }
end

report.pretty_print
