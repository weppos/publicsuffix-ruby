#
# = DomainName
#
# MissingDescription
#
#
# Category::    Net
# Package::     DomainName
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


require 'domain_name/version'
require 'domain_name/rule'
require 'domain_name/rule_list'


class DomainName

  NAME            = 'DomainName'
  GEM             = 'domain_name'
  AUTHORS         = ['Simone Carletti <weppos@weppos.net>']


  attr_reader :name, :tld, :sld, :trd, :rule


  def initialize(name)
    @name = name
  end  
  
  def labels
    to_s.split(".").reverse
  end

  def to_s
    name.to_s
  end


  def rule
    @rule ||= RuleList.default.find(self)
  end

  def rule!
    rule  || raise(Error, "The domain cannot be found in the TLD definition file")
  end


  protected

    def parse
      case rule!.type

        # "foo.google.com"
        when :normal
          match = /^(.*)\.(#{Regexp.escape(rule.value)})$/.match(name.to_s)
          ignore, full, tld = match.to_a

        # "photos.verybritish.co.uk"
        when :wildcard
          match = /^(.*)\.(.*?\.#{Regexp.escape(rule.value)})$/.match(name.to_s)
          ignore, full, tld = match.to_a

        # "photos.wishlist.parliament.uk"
        when :exception
          match = /^(.*)\.(#{Regexp.escape(rule.value.split('.', 2).last)})$/.match(name.to_s)
          ignore, full, tld = match.to_a

        else
          raise Error, "WTF?!?"
      end

      # If we have 0 parts left, there is just a tld and no domain or subdomain
      # If we have 1 part, it's the domain, and there is no subdomain
      # If we have 2+ parts, the last part is the domain, the other parts (combined) are the subdomain
      parts = full.split(".")
      @tld  = tld
      @sld  = parts.empty? ? nil : parts.pop
      @trd  = parts.empty? ? nil : parts.join(".")

      self
    end


  def self.valid?(domain)
    !Domain.new(domain).rule.nil?
  end

end
