require "rubygems"
require "bundler"

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
require "public_suffix"


# By default, run tests and linter.
task default: [:test, :rubocop]

spec = Gem::Specification.new do |s|
  s.name              = "public_suffix"
  s.version           = PublicSuffix::VERSION
  s.summary           = "Domain name parser based on the Public Suffix List."
  s.description       = "PublicSuffix can parse and decompose a domain name into top level domain, domain and subdomains."

  s.required_ruby_version = ">= 2.0"

  s.author            = "Simone Carletti"
  s.email             = "weppos@weppos.net"
  s.homepage          = "https://simonecarletti.com/code/publicsuffix-ruby"
  s.license           = "MIT"

  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths     = %w( lib )

  s.add_development_dependency("rake")
  s.add_development_dependency("mocha")
  s.add_development_dependency("yard")
end


require "rubygems/package_task"

Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") { |f| f << spec.to_ruby }
end

desc "Remove any temporary products, including gemspec"
task clean: [:clobber] do
  rm "#{spec.name}.gemspec" if File.file?("#{spec.name}.gemspec")
end

desc "Remove any generated file"
task clobber: [:clobber_package]

desc "Package the library and generates the gemspec"
task package: [:gemspec]


require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs = %w( lib test )
  t.pattern = "test/**/*_test.rb"
  t.verbose = !ENV["VERBOSE"].nil?
  t.warning = !ENV["WARNING"].nil?
end

require "rubocop/rake_task"

RuboCop::RakeTask.new


require "yard"
require "yard/rake/yardoc_task"

YARD::Rake::YardocTask.new(:yardoc) do |y|
  y.options = %w( --output-dir yardoc )
end

namespace :yardoc do
  task :clobber do
    rm_r "yardoc" rescue nil
  end
end
task clobber: ["yardoc:clobber"]


desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r public_suffix.rb"
end


desc "Downloads the Public Suffix List file from the repository and stores it locally."
task :"update-list" do
  require "net/http"

  DEFINITION_URL = "https://raw.githubusercontent.com/publicsuffix/list/master/public_suffix_list.dat".freeze

  File.open("data/list.txt", "w+") do |f|
    response = Net::HTTP.get_response(URI.parse(DEFINITION_URL))
    response.body
    f.write(response.body)
  end
end
