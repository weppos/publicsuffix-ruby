$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "memory_profiler"
require "public_suffix"

report = MemoryProfiler.report do
  case ENV["SWITCH"]
  when "trie"
    @data = Containers::Trie.new
    @data.push("com".reverse, 1)
    # @data.push("blogspot.com".reverse, 1)
    # @data.push("it".reverse, 1)
  when "hash"
    @data = {}
    @data["commcgvjhbjhbhbhjbkhbjbjkbkjbjkbjkbjbjkbjbjbj"] = 1
    # @data["blogspot.com"] = 1
    # @data["it"] = 1
  end
end

report.pretty_print

puts ""
puts @data.inspect

require 'objspace'
puts ObjectSpace.memsize_of({ "foo" => 1 })