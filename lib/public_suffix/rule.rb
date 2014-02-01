#--
# Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2014 Simone Carletti <weppos@weppos.net>
#++


module PublicSuffix

  # A Rule is a special object which holds a single definition
  # of the Public Suffix List.
  #
  # There are 3 types of ruleas, each one represented by a specific
  # subclass within the +PublicSuffix::Rule+ namespace.
  #
  # To create a new Rule, use the {PublicSuffix::Rule#factory} method.
  #
  #   PublicSuffix::Rule.factory("ar")
  #   # => #<PublicSuffix::Rule::Normal>
  #
  class Rule

    # Takes the +name+ of the rule, detects the specific rule class
    # and creates a new instance of that class.
    # The +name+ becomes the rule +value+.
    #
    # @param  [String] name The rule definition.
    #
    # @return [PublicSuffix::Rule::*] A rule instance.
    #
    # @example Creates a Normal rule
    #   PublicSuffix::Rule.factory("ar")
    #   # => #<PublicSuffix::Rule::Normal>
    #
    # @example Creates a Wildcard rule
    #   PublicSuffix::Rule.factory("*.ar")
    #   # => #<PublicSuffix::Rule::Wildcard>
    #
    # @example Creates an Exception rule
    #   PublicSuffix::Rule.factory("!congresodelalengua3.ar")
    #   # => #<PublicSuffix::Rule::Exception>
    #
    def self.factory(name)
      klass = case name.to_s[0..0]
        when "*"  then  "wildcard"
        when "!"  then  "exception"
        else            "normal"
      end
      const_get(klass.capitalize).new(name)
    end


    #
    # = Abstract rule class
    #
    # This represent the base class for a Rule definition
    # in the {Public Suffix List}[http://publicsuffix.org].
    # 
    # This is intended to be an Abstract class
    # and you shouldn't create a direct instance. The only purpose
    # of this class is to expose a common interface
    # for all the available subclasses.
    #
    # * {PublicSuffix::Rule::Normal}
    # * {PublicSuffix::Rule::Exception}
    # * {PublicSuffix::Rule::Wildcard}
    #
    # == Properties
    #
    # A rule is composed by 4 properties:
    #
    # name    - The name of the rule, corresponding to the rule definition
    #           in the public suffix list
    # value   - The value, a normalized version of the rule name.
    #           The normalization process depends on rule tpe.
    # type    - The rule type (:normal, :wildcard, :exception)
    # labels  - The canonicalized rule name
    #
    # Here's an example
    #
    #   PublicSuffix::Rule.factory("*.google.com")
    #   #<PublicSuffix::Rule::Wildcard:0x1015c14b0
    #       @labels=["com", "google"],
    #       @name="*.google.com",
    #       @type=:wildcard,
    #       @value="google.com"
    #   >
    #
    # == Rule Creation
    #
    # The best way to create a new rule is passing the rule name
    # to the <tt>PublicSuffix::Rule.factory</tt> method.
    #
    #   PublicSuffix::Rule.factory("com")
    #   # => PublicSuffix::Rule::Normal
    #
    #   PublicSuffix::Rule.factory("*.com")
    #   # => PublicSuffix::Rule::Wildcard
    #
    # This method will detect the rule type and create an instance
    # from the proper rule class.
    #
    # == Rule Usage
    #
    # A rule describes the composition of a domain name
    # and explains how to tokenize the domain name
    # into tld, sld and trd.
    #
    # To use a rule, you first need to be sure the domain you want to tokenize
    # can be handled by the current rule.
    # You can use the <tt>#match?</tt> method.
    #
    #   rule = PublicSuffix::Rule.factory("com")
    #   
    #   rule.match?("google.com")
    #   # => true
    #   
    #   rule.match?("google.com")
    #   # => false
    #
    # Rule order is significant. A domain can match more than one rule.
    # See the {Public Suffix Documentation}[http://publicsuffix.org/format/]
    # to learn more about rule priority.
    #
    # When you have the right rule, you can use it to tokenize the domain name.
    # 
    #   rule = PublicSuffix::Rule.factory("com")
    # 
    #   rule.decompose("google.com")
    #   # => ["google", "com"]
    # 
    #   rule.decompose("www.google.com")
    #   # => ["www.google", "com"]
    #
    # @abstract
    #
    class Base

      attr_reader :name, :value, :type, :labels

      # Initializes a new rule with name and value.
      # If value is +nil+, name also becomes the value for this rule.
      #
      # @param [String] name
      #   The name of the rule
      # @param [String] value
      #   The value of the rule. If nil, defaults to +name+.
      #
      def initialize(name, value = nil)
        @name   = name.to_s
        @value  = value || @name
        @type   = self.class.name.split("::").last.downcase.to_sym
        @labels = Domain.domain_to_labels(@value)
      end

      # Checks whether this rule is equal to <tt>other</tt>.
      #
      # @param [PublicSuffix::Rule::*] other
      #   The rule to compare.
      #
      # @return [Boolean]
      #   Returns true if this rule and other are instances of the same class
      #   and has the same value, false otherwise.
      def ==(other)
        return false unless other.is_a?(self.class)
        self.equal?(other) ||
        self.name == other.name
      end
      alias :eql? :==


      # Checks if this rule matches +domain+.
      #
      # @param [String, #to_s] domain
      #   The domain name to check.
      #
      # @return [Boolean]
      #
      # @example
      #   rule = Rule.factory("com")
      #   # #<PublicSuffix::Rule::Normal>
      #   rule.match?("example.com")
      #   # => true
      #   rule.match?("example.net")
      #   # => false
      #
      def match?(domain)
        l1 = labels
        l2 = Domain.domain_to_labels(domain)
        odiff(l1, l2).empty?
      end

      # Checks if this rule allows +domain+.
      #
      # @param [String, #to_s] domain
      #   The domain name to check.
      #
      # @return [Boolean]
      #
      # @example
      #   rule = Rule.factory("*.do")
      #   # => #<PublicSuffix::Rule::Wildcard>
      #   rule.allow?("example.do")
      #   # => false
      #   rule.allow?("www.example.do")
      #   # => true
      #
      def allow?(domain)
        !decompose(domain).last.nil?
      end


      # Gets the length of this rule for comparison.
      # The length usually matches the number of rule +parts+.
      #
      # Subclasses might actually override this method.
      #
      # @return [Integer] The number of parts.
      def length
        parts.length
      end

      #
      # @raise  [NotImplementedError]
      # @abstract
      def parts
        raise NotImplementedError
      end

      #
      # @param [String, #to_s] domain
      #   The domain name to decompose.
      #
      # @return [Array<String, nil>]
      #
      # @raise  [NotImplementedError]
      # @abstract
      def decompose(domain)
        raise NotImplementedError
      end


      private

        def odiff(one, two)
          ii = 0
          while(ii < one.size && one[ii] == two[ii])
            ii += 1
          end
          one[ii..one.length]
        end

    end

    class Normal < Base

      # Initializes a new rule with +name+.
      #
      # @param [String] name
      #   The name of this rule.
      #
      def initialize(name)
        super(name, name)
      end

      # dot-split rule value and returns all rule parts
      # in the order they appear in the value.
      #
      # @return [Array<String>]
      def parts
        @parts ||= @value.split(".")
      end

      # Decomposes the domain according to rule properties.
      #
      # @param [String, #to_s] domain
      #   The domain name to decompose.
      #
      # @return [Array<String>]
      #   The array with [trd + sld, tld].
      #
      def decompose(domain)
        domain.to_s.chomp(".") =~ /^(.*)\.(#{parts.join('\.')})$/
        [$1, $2]
      end

    end

    class Wildcard < Base

      # Initializes a new rule with +name+.
      #
      # @param [String] name
      #   The name of this rule.
      #
      def initialize(name)
        super(name, name.to_s[2..-1])
      end

      # dot-split rule value and returns all rule parts
      # in the order they appear in the value.
      #
      # @return [Array<String>]
      def parts
        @parts ||= @value.split(".")
      end

      # Overwrites the default implementation to cope with
      # the +*+ char.
      #
      # @return [Integer] The number of parts.
      def length
        parts.length + 1 # * counts as 1
      end

      # Decomposes the domain according to rule properties.
      #
      # @param [String, #to_s] domain
      #   The domain name to decompose.
      #
      # @return [Array<String>]
      #   The array with [trd + sld, tld].
      #
      def decompose(domain)
        domain.to_s.chomp(".") =~ /^(.*)\.(.*?\.#{parts.join('\.')})$/
        [$1, $2]
      end

    end

    class Exception < Base

      # Initializes a new rule with +name+.
      #
      # @param  [String] name   The name of this rule.
      #
      def initialize(name)
        super(name, name.to_s[1..-1])
      end

      # dot-split rule value and returns all rule parts
      # in the order they appear in the value.
      # The leftmost label is not considered a label.
      #
      # See http://publicsuffix.org/format/:
      # If the prevailing rule is a exception rule,
      # modify it by removing the leftmost label. 
      #
      # @return [Array<String>]
      def parts
        @parts ||= @value.split(".")[1..-1]
      end

      # Decomposes the domain according to rule properties.
      #
      # @param [String, #to_s] domain
      #   The domain name to decompose.
      #
      # @return [Array<String>]
      #   The array with [trd + sld, tld].
      #
      def decompose(domain)
        domain.to_s.chomp(".") =~ /^(.*)\.(#{parts.join('\.')})$/
        [$1, $2]
      end

    end

  end

end
