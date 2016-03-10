source "http://rubygems.org"

gemspec

gem 'rake', '< 11'
gem 'minitest'
gem 'minitest-reporters'
gem 'coveralls', require: false

if !RUBY_VERSION.start_with?("2.0")
  gem 'memory_profiler', require: false
end
