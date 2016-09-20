if ENV["COVERALL"]
  require "coveralls"
  Coveralls.wear!
end

require "minitest/autorun"
require "mocha/setup"

require "public_suffix"
