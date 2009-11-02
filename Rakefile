$:.unshift(File.dirname(__FILE__) + "/lib")

require 'rubygems'
require 'rake'
require 'echoe'
require 'domain_name'


# Common package properties
PKG_NAME    = ENV['PKG_NAME']    || DomainName::GEM
PKG_VERSION = ENV['PKG_VERSION'] || DomainName::VERSION
RUBYFORGE_PROJECT = 'domain_name'

if ENV['SNAPSHOT'].to_i == 1
  PKG_VERSION << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end


Echoe.new(PKG_NAME, PKG_VERSION) do |p|
  p.author        = "Simone Carletti"
  p.email         = "weppos@weppos.net"
  p.summary       = "Domain Name parser based on the Public Suffix List"
  p.url           = "http://code.simonecarletti.com/domain-name"
  p.project       = RUBYFORGE_PROJECT
  p.description   = <<-EOD
Intelligent Domain Name parser based in the Public Suffic List. \
Domain Name can parse and decompose a domain name into top level domain, \
domain and subdomains.
EOD

  p.need_zip      = true

  p.development_dependencies += ["rake  ~>0.8",
                                 "echoe ~>3.2",
                                 "mocha ~>0.9"]

  p.rcov_options  = ["-Itest -x mocha,rcov,Rakefile"]
end


desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r domain_name.rb"
end

begin
  require 'code_statistics'
  desc "Show library's code statistics"
  task :stats do
    CodeStatistics.new(["DomainName", "lib"],
                       ["Tests", "test"]).to_s
  end
rescue LoadError
  puts "CodeStatistics (Rails) is not available"
end

Dir["tasks/**/*.rake"].each do |file|
  load(file)
end
