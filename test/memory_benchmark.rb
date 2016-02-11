$:.unshift File.expand_path('../../lib', __FILE__)

require 'memory_profiler'
require 'public_suffix'

report = MemoryProfiler.report do
  PublicSuffix::List.default
end

report.pretty_print
