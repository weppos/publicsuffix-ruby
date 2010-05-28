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


  def initialize(*args, &block)
    @tld, @sld, @trd = args
    yield(self) if block_given?
  end

  # Gets a String representation of this object.
  #
  # Returns a String with the domain name.
  def to_s
    name
  end

  def to_a
    [trd, sld, tld]
  end


  # Gets the Top Level Domain part, aka the extension.
  #
  # Returns a String if tld is set, nil otherwise.
  def tld
    @tld
  end

  # Gets the Second Level Domain part, aka the domain part.
  #
  # Returns a String if sld is set, nil otherwise.
  def sld
    @sld
  end

  # Gets the Third Level Domain part, aka the subdomain part.
  #
  # Returns a String if trd is set, nil otherwise.
  def trd
    @trd
  end


  # Gets the domain name.
  #
  # Examples
  #
  #   DomainName.new("com", "google").name
  #   # => "google.com"
  #
  #   DomainName.new("com", "google", "www").name
  #   # => "www.google.com"
  #
  # Returns a String with the domain name.
  def name
    [trd, sld, tld].reject { |part| part.nil? }.join(".")
  end

  # Returns a domain-like representation of this object
  # if the object is a <tt>domain?</tt>,
  # <tt>nil</tt> otherwise.
  def domain
    return unless domain?
    [sld, tld].join(".")
  end

  # Returns a subdomain-like representation of this object
  # if the object is a <tt>subdomain?</tt>,
  # <tt>nil</tt> otherwise.
  def subdomain
    return unless subdomain?
    [trd, sld, tld].join(".")
  end

  # Gets the rule matching this domain in the default DomainName::RuleList.
  #
  # Returns an instance of DomainName::Rule::Base if a rule matches current domain,
  # nil if no rule is found.
  def rule
    RuleList.default.find(name)
  end


  # Checks whether <tt>self</tt> looks like a domain.
  #
  # This method doesn't actually validate the domain.
  # It only checks whether the instance contains
  # a value for the <tt>tld</tt> and <tt>sld</tt> attributes.
  # If you also want to validate the domain, use <tt>#valid_domain?</tt> instead.
  #
  # Examples
  #
  #   DomainName.new("com").domain?
  #   # => false
  #
  #   DomainName.new("com", "google").domain?
  #   # => true
  #
  #   DomainName.new("com", "google", "www").domain?
  #   # => true
  #
  #   # This is an invalid domain, but returns true
  #   # because this method doesn't validate the content.
  #   DomainName.new("zip", "google").domain?
  #   # => true
  #
  # Returns true if this instance looks like a domain.
  def domain?
    !(tld.nil? || sld.nil?)
  end

  # Checks whether <tt>self</tt> looks like a subdomain.
  #
  # This method doesn't actually validate the subdomain.
  # It only checks whether the instance contains
  # a value for the <tt>tld</tt>, <tt>sld</tt> and <tt>trd</tt> attributes.
  # If you also want to validate the domain, use <tt>#valid_subdomain?</tt> instead.
  #
  # Examples
  #
  #   DomainName.new("com").subdomain?
  #   # => false
  #
  #   DomainName.new("com", "google").subdomain?
  #   # => false
  #
  #   DomainName.new("com", "google", "www").subdomain?
  #   # => true
  #
  #   # This is an invalid domain, but returns true
  #   # because this method doesn't validate the content.
  #   DomainName.new("zip", "google", "www").subdomain?
  #   # => true
  #
  # Returns true if this instance looks like a subdomain.
  def subdomain?
    !(tld.nil? || sld.nil? || trd.nil?)
  end

  # Checks whether <tt>self</tt> is exclusively a domain,
  # and not a subdomain.
  def is_a_domain?
    domain? && !subdomain?
  end

  # Checks whether <tt>self</tt> is exclusively a subdomain.
  def is_a_subdomain?
    subdomain?
  end

  # Checks whether <tt>self</tt> is valid
  # according to default <tt>RuleList</tt>.
  #
  # Note: this method triggers a new rule lookup in the default RuleList,
  # which is a quite intensive task.
  #
  # Returns true if this instance is valid.
  def valid?
    !rule.nil?
  end

  # Checks whether <tt>self</tt> looks like a domain and validates
  # according to default <tt>RuleList</tt>.
  #
  # See also <tt>DomainName#domain?</tt> and <tt>DomainName#valid?</tt>.
  #
  # Examples
  #
  #   DomainName.new("com").domain?
  #   # => false
  #
  #   DomainName.new("com", "google").domain?
  #   # => true
  #
  #   DomainName.new("com", "google", "www").domain?
  #   # => true
  #
  #   # This is an invalid domain
  #   DomainName.new("zip", "google").false?
  #   # => true
  #
  # Returns true if this instance looks like a domain and is valid.
  def valid_domain?
    domain? && valid?
  end

  # Checks whether <tt>self</tt> looks like a subdomain and validates
  # according to default <tt>RuleList</tt>.
  #
  # See also <tt>DomainName#subdomain?</tt> and <tt>DomainName#valid?</tt>.
  #
  # Examples
  #
  #   DomainName.new("com").subdomain?
  #   # => false
  #
  #   DomainName.new("com", "google").subdomain?
  #   # => false
  #
  #   DomainName.new("com", "google", "www").subdomain?
  #   # => true
  #
  #   # This is an invalid domain
  #   DomainName.new("zip", "google", "www").subdomain?
  #   # => false
  #
  # Returns true if this instance looks like a domain and is valid.
  def valid_subdomain?
    subdomain? && valid?
  end


  # Parses <tt>domain</tt> and returns a new <tt>DomainName</tt> instance.
  #
  # domain - A String with the domain name to parse.
  #
  #   DomainName.parse("google.com")
  #   # => #<DomainName ...>
  #   
  #   DomainName.parse("www.google.com")
  #   # => #<DomainName ...>
  #   
  #   DomainName.parse("http://www.google.com")
  #   # => DomainName::InvalidDomain
  #   
  #   DomainName.parse("x.yz")
  #   # => DomainName::InvalidDomain
  #
  # Raises DomainName::Error if domain is not a valid domain
  def self.parse(domain)
    rule = RuleList.default.find(domain) || raise(InvalidDomain, "`#{domain}' is not a valid domain")

    left, right = rule.decompose(domain)
    parts       = left.split(".")

    # If we have 0 parts left, there is just a tld and no domain or subdomain
    # If we have 1 part  left, there is just a tld, domain and not subdomain
    # If we have 2 parts left, the last part is the domain, the other parts (combined) are the subdomain
    tld = right
    sld = parts.empty? ? nil : parts.pop
    trd = parts.empty? ? nil : parts.join(".")

    new(tld, sld, trd)
  end

  # Checks whether <tt>domain</tt> is a valid domain name.
  #
  # This method doesn't care whether domain is a domain or subdomain.
  # The check is performed using the default <tt>DomainName::RuleList</tt>.
  #
  # domain - A String with the domain name to check.
  #
  # Examples
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
  # Returns true if <tt>domain</tt> is a valid domain.
  def self.valid?(domain)
    !RuleList.default.find(domain).nil?
  end

end
