#
# = DomainName
#
# Domain Name parser based on the Public Suffix List
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
require 'domain_name/errors'
require 'domain_name/rule'
require 'domain_name/rule_list'


class DomainName

  NAME            = 'DomainName'
  GEM             = 'domain_name'
  AUTHORS         = ['Simone Carletti <weppos@weppos.net>']


  attr_reader :name


  def initialize(name, &block)
    @name   = name
    @ruled  = false
    @parsed = false
    yield(self) if block_given?
  end

  def to_s
    name.to_s
  end


  def rule
    return @rule if @ruled
    @rule ||= RuleList.default.find(self)
  end

  def rule!
    rule  || raise(Error, "The domain cannot be found in the TLD definition file")
  end


  # Returns whether <tt>self</tt> is valid
  # according to default <tt>RuleList</tt>.
  def valid?
    parse
    !(@tld.nil?)
  end

  # Returns whether <tt>self</tt> is a valid domain
  # according to default <tt>RuleList</tt>.
  #
  #   DomainName.new("google.com").valid_domain?
  #   # => true
  #   DomainName.new("www.google.com").valid_domain?
  #   # => true
  #   DomainName.new("google.zip").valid_domain?
  #   # => false
  #   DomainName.new("www.google.zip").valid_domain?
  #   # => false
  #
  def valid_domain?
    parse
    !(@tld.nil? || @sld.nil?)
  end

  # Returns whether <tt>self</tt> is a valid subdomain
  # according to default <tt>RuleList</tt>.
  #
  #   DomainName.new("google.com").valid_subdomain?
  #   # => false
  #   DomainName.new("www.google.com").valid_subdomain?
  #   # => true
  #   DomainName.new("google.zip").valid_subdomain?
  #   # => false
  #   DomainName.new("www.google.zip").valid_subdomain?
  #   # => false
  #
  def valid_subdomain?
    parse
    !(@tld.nil? || @sld.nil? || @trd.nil?)
  end


  # Returns a domain-like representation of this object
  # if the object is a <tt>valid_domain?</tt>,
  # <tt>nil</tt> otherwise.
  def domain
    return unless valid_domain?
    [@sld, @tld].join(".")
  end

  # Returns a subdomain-like representation of this object
  # if the object is a <tt>subvalid_domain?</tt>,
  # <tt>nil</tt> otherwise.
  def subdomain
    return unless valid_subdomain?
    [@trd, @sld, @tld].join(".")
  end


  def tld
    parse!
    @tld
  end

  def sld
    parse!
    @sld
  end

  def trd
    parse!
    @trd
  end


  def parse
    return self if @parsed
    return self if rule.nil?

    full, tld = rule.decompose(self)

    # If we have 0 parts left, there is just a tld and no domain or subdomain
    # If we have 1 part, it's the domain, and there is no subdomain
    # If we have 2+ parts, the last part is the domain, the other parts (combined) are the subdomain
    parts   = full.split(".")
    @tld    = tld
    @sld    = parts.empty? ? nil : parts.pop
    @trd    = parts.empty? ? nil : parts.join(".")

    @parsed = true
    self
  end

  def parse!
    (parse && rule) || raise(InvalidDomain, "`#{name}' is not a valid domain")
    self
  end


  # Returns whether <tt>domain</tt> is a valid domain
  # according to default <tt>RuleList</tt>.
  #
  #   DomainName.valid?("google.com")
  #   # => true
  #   
  #   DomainName.valid?("www.google.com")
  #   # => true
  #   
  #   DomainName.valid?("http://www.google.com")
  #   # => false
  #   
  #   DomainName.valid?("x.yz")
  #   # => false
  #
  def self.valid?(domain)
    new(domain).valid?
  end

  # Parses <tt>domain</tt> and returns a new <tt>DomainName</tt> instance.
  #
  #   DomainName.parse("google.com")
  #   # => #<DomainName ...>
  #   
  #   DomainName.parse("www.google.com")
  #   # => #<DomainName ...>
  #   
  #   DomainName.parse("http://www.google.com")
  #   # => raises
  #   
  #   DomainName.parse("x.yz")
  #   # => raises
  #
  # ==== Raises
  #
  # DomainName::Error:: if <tt>domain</tt> is not a valid domain
  #
  def self.parse(domain)
     new(domain).parse!
  end

end
