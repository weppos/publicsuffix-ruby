require "rubygems"
require "rake/testtask"
require "rake/gempackagetask"
begin
  require "hanna/rdoctask"
rescue LoadError
  require "rake/rdoctask"
end

$:.unshift(File.dirname(__FILE__) + "/lib")
require "public_suffix_service"


# Common package properties
PKG_NAME    = ENV['PKG_NAME']    || PublicSuffixService::GEM
PKG_VERSION = ENV['PKG_VERSION'] || PublicSuffixService::VERSION
RUBYFORGE_PROJECT = nil

if ENV['SNAPSHOT'].to_i == 1
  PKG_VERSION << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end


# Run all the tests in the /test folder
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

# Run test by default.
task :default => ["test"]


# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  s.name              = PKG_NAME
  s.version           = PKG_VERSION
  s.summary           = "Domain Name parser based on the Public Suffix List"
  s.author            = "Simone Carletti"
  s.email             = "weppos@weppos.net"
  s.homepage          = "http://www.simonecarletti.com/code/public_suffix_service"
  s.description       = <<-EOD
    Intelligent domain name parser based in the Public Suffic List. \
    PublicSuffixService can parse and decompose a domain name into top level domain, \
    domain and subdomains.
  EOD

  s.has_rdoc          = true
  # You should probably have a README of some kind. Change the filename
  # as appropriate
  s.extra_rdoc_files  = Dir.glob("*.rdoc")
  s.rdoc_options      = %w(--main README.rdoc)

  # Add any extra files to include in the gem (like your README)
  s.files             = %w(Rakefile) + Dir.glob("*.{rdoc,gemspec}") + Dir.glob("{test,lib}/**/*")
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  # s.add_dependency("some_other_gem", "~> 0.1.0")

  # If your tests use any gems, include them here
  s.add_development_dependency("rr")
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

desc "Remove any temporary products, including gemspec"
task :clean => [:clobber] do
  rm "#{spec.name}.gemspec" if File.file?("#{spec.name}.gemspec")
end

desc "Remove any generated file"
task :clobber => [:clobber_rdoc, :clobber_package]

desc "Package the library and generates the gemspec"
task :package => [:gemspec]


begin
  require "yard"
  require "yard/rake/yardoc_task"

  YARD::Rake::YardocTask.new(:yardoc) do |y|
    y.options = ["--output-dir", "yardoc"]
  end

  namespace :yardoc do
    desc "Publish YARD documentation to the site"
    task :publish => ["yardoc:clobber", "yardoc"] do
      ENV["username"] || raise(ArgumentError, "Missing ssh username")
      sh "rsync -avz --delete yardoc/ #{ENV["username"]}@code:/var/www/apps/code/#{PKG_NAME}/api"
    end

    desc "Remove YARD products"
    task :clobber do
      rm_r "yardoc" rescue nil
    end
  end

  task :clobber => "yardoc:clobber"
rescue LoadError
  puts "YARD is not available"
end


begin
  require "rcov/rcovtask"

  desc "Create a code coverage report"
  Rcov::RcovTask.new do |t|
    t.test_files = FileList["test/**/*_test.rb"]
    t.ruby_opts << "-Itest -x rr,rcov,Rakefile"
    t.verbose = true
  end
rescue LoadError
  puts "RCov is not available"
end


desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r public_suffix_service.rb"
end


desc <<-DESC
  Downloads the Public Suffix List file from the repository \
  and stores it locally.
DESC
task :download_definitions do
  require "net/http"

  DEFINITION_URL = "http://mxr.mozilla.org/mozilla-central/source/netwerk/dns/effective_tld_names.dat?raw=1"

  File.open("lib/public_suffix_service/definitions.dat", "w+") do |f|
    response = Net::HTTP.get_response(URI.parse(DEFINITION_URL))
    f.write(response.body)
  end
end
