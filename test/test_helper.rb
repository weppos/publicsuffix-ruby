require 'rubygems'
require 'minitest/autorun'
require 'mocha/setup'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'public_suffix'

Minitest::Unit::TestCase.class_eval do
  def assert_not_equal(exp, act, msg = nil)
    assert_operator(exp, :!=, act, msg)
  end unless method_exists?(:assert_not_equal)
end
