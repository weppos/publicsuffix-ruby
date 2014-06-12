require 'rubygems'
require 'bundler'

$:.unshift(File.dirname(__FILE__) + "/lib")
require 'public_suffix'


# Common package properties
PKG_NAME    = PublicSuffix::GEM
PKG_VERSION = PublicSuffix::VERSION


# Run test by default.
task default: :test


spec = Gem::Specification.new do |s|
  s.name              = PKG_NAME
  s.version           = PKG_VERSION
  s.summary           = "Domain name parser based on the Public Suffix List."
  s.description       = "PublicSuffix can parse and decompose a domain name into top level domain, domain and subdomains."

  s.required_ruby_version = ">= 1.9.3"

  s.author            = "Simone Carletti"
  s.email             = "weppos@weppos.net"
  s.homepage          = "http://simonecarletti.com/code/publicsuffix"
  s.license           = "MIT"

  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths     = %w( lib )

  s.add_development_dependency("rake")
  s.add_development_dependency("mocha")
  s.add_development_dependency("yard")
end


require 'rubygems/package_task'

Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

desc "Remove any temporary products, including gemspec"
task clean: [:clobber] do
  rm "#{spec.name}.gemspec" if File.file?("#{spec.name}.gemspec")
end

desc "Remove any generated file"
task clobber: [:clobber_package]

desc "Package the library and generates the gemspec"
task package: [:gemspec]


require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = !!ENV["VERBOSE"]
  t.warning = !!ENV["WARNING"]
end


require 'yard'
require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new(:yardoc) do |y|
  y.options = ["--output-dir", "yardoc"]
end

namespace :yardoc do
  task :clobber do
    rm_r "yardoc" rescue nil
  end
end

task clobber: "yardoc:clobber"


desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r public_suffix.rb"
end


desc <<-DESC
  Downloads the Public Suffix List file from the repository and stores it locally.
DESC
task :upddef do
  require "net/http"

  DEFINITION_URL = "https://publicsuffix.org/list/effective_tld_names.dat"

  File.open("lib/definitions.txt", "w+") do |f|
    response = Net::HTTP.get_response(URI.parse(DEFINITION_URL))
    response.body
    f.write(response.body)
  end
end
