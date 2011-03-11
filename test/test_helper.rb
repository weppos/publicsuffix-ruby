require 'rubygems'
require 'test/unit'
require 'rr'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'public_suffix_service'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
