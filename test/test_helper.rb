$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'rr'
require 'public_suffix_service'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
