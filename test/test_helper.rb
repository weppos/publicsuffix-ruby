$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'domain_name'

class DomainName
  module TestCase

    private

      def domain_name(name)
        DomainName.new(name)
      end

  end
end

class Test::Unit::TestCase
  include DomainName::TestCase
end