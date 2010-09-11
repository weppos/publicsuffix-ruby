#
# = Public Suffix Service
#
# Domain Name parser based on the Public Suffix List
#
#
# Category::    Net
# Package::     PublicSuffixService
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


module PublicSuffixService

  class Domain
    
    # Splits a string into its possible labels as a domain in reverse order 
    # from the input string
    #
    # domain - the string to be split
    #
    # Examples
    #
    #   domain_to_labels('google.com.uk')
    #   # => ['uk', 'com', 'google']
    #
    # Returns an array of strings representing the possible labels if the input
    # string is found to be a valid domain
    def self.domain_to_labels(domain)
      domain.to_s.split(".").reverse
    end

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
    #   PublicSuffixService::Domain.new("com", "google").name
    #   # => "google.com"
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").name
    #   # => "www.google.com"
    #
    # Returns a String with the domain name.
    def name
      [trd, sld, tld].reject { |part| part.nil? }.join(".")
    end

    # Returns a domain-like representation of this object
    # if the object is a <tt>domain?</tt>,
    # <tt>nil</tt> otherwise.
    #
    #   PublicSuffixService::Domain.new("com").domain
    #   # => nil
    #
    #   PublicSuffixService::Domain.new("com", "google").domain
    #   # => "google.com"
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").domain
    #   # => "www.google.com"
    #
    # This method doesn't validate the input. It handles the domain
    # as a valid domain name and simply applies the necessary transformations.
    #
    #   # This is an invalid domain
    #   PublicSuffixService::Domain.new("zip", "google").domain
    #   # => "google.zip"
    #
    # This method returns a FQD, not just the domain part.
    # To get the domain part, use <tt>#sld</tt> (aka second level domain).
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").domain
    #   # => "google.com"
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").sld
    #   # => "google"
    #
    # Returns a String or nil.
    def domain
      return unless domain?
      [sld, tld].join(".")
    end

    # Returns a domain-like representation of this object
    # if the object is a <tt>subdomain?</tt>,
    # <tt>nil</tt> otherwise.
    #
    #   PublicSuffixService::Domain.new("com").subdomain
    #   # => nil
    #
    #   PublicSuffixService::Domain.new("com", "google").subdomain
    #   # => nil
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").subdomain
    #   # => "www.google.com"
    #
    # This method doesn't validate the input. It handles the domain
    # as a valid domain name and simply applies the necessary transformations.
    #
    #   # This is an invalid domain
    #   PublicSuffixService::Domain.new("zip", "google", "www").subdomain
    #   # => "www.google.zip"
    #
    # This method returns a FQD, not just the domain part.
    # To get the domain part, use <tt>#tld</tt> (aka third level domain).
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").subdomain
    #   # => "www.google.com"
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").trd
    #   # => "www"
    #
    # Returns a String or nil.
    def subdomain
      return unless subdomain?
      [trd, sld, tld].join(".")
    end

    # Gets the rule matching this domain in the default PublicSuffixService::RuleList.
    #
    # Returns an instance of PublicSuffixService::Rule::Base if a rule matches current domain,
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
    #   PublicSuffixService::Domain.new("com").domain?
    #   # => false
    #
    #   PublicSuffixService::Domain.new("com", "google").domain?
    #   # => true
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").domain?
    #   # => true
    #
    #   # This is an invalid domain, but returns true
    #   # because this method doesn't validate the content.
    #   PublicSuffixService::Domain.new("zip", "google").domain?
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
    #   PublicSuffixService::Domain.new("com").subdomain?
    #   # => false
    #
    #   PublicSuffixService::Domain.new("com", "google").subdomain?
    #   # => false
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").subdomain?
    #   # => true
    #
    #   # This is an invalid domain, but returns true
    #   # because this method doesn't validate the content.
    #   PublicSuffixService::Domain.new("zip", "google", "www").subdomain?
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
    # See also <tt>#domain?</tt> and <tt>#valid?</tt>.
    #
    # Examples
    #
    #   PublicSuffixService::Domain.new("com").domain?
    #   # => false
    #
    #   PublicSuffixService::Domain.new("com", "google").domain?
    #   # => true
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").domain?
    #   # => true
    #
    #   # This is an invalid domain
    #   PublicSuffixService::Domain.new("zip", "google").false?
    #   # => true
    #
    # Returns true if this instance looks like a domain and is valid.
    def valid_domain?
      domain? && valid?
    end

    # Checks whether <tt>self</tt> looks like a subdomain and validates
    # according to default <tt>RuleList</tt>.
    #
    # See also <tt>#subdomain?</tt> and <tt>#valid?</tt>.
    #
    # Examples
    #
    #   PublicSuffixService::Domain.new("com").subdomain?
    #   # => false
    #
    #   PublicSuffixService::Domain.new("com", "google").subdomain?
    #   # => false
    #
    #   PublicSuffixService::Domain.new("com", "google", "www").subdomain?
    #   # => true
    #
    #   # This is an invalid domain
    #   PublicSuffixService::Domain.new("zip", "google", "www").subdomain?
    #   # => false
    #
    # Returns true if this instance looks like a domain and is valid.
    def valid_subdomain?
      subdomain? && valid?
    end

  end

end
