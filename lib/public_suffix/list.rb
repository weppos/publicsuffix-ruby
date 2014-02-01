#--
# Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2014 Simone Carletti <weppos@weppos.net>
#++


module PublicSuffix

  # A {PublicSuffix::List} is a collection of one
  # or more {PublicSuffix::Rule}.
  #
  # Given a {PublicSuffix::List},
  # you can add or remove {PublicSuffix::Rule},
  # iterate all items in the list or search for the first rule
  # which matches a specific domain name.
  #
  #   # Create a new list
  #   list =  PublicSuffix::List.new
  #
  #   # Push two rules to the list
  #   list << PublicSuffix::Rule.factory("it")
  #   list << PublicSuffix::Rule.factory("com")
  #
  #   # Get the size of the list
  #   list.size
  #   # => 2
  #
  #   # Search for the rule matching given domain
  #   list.find("example.com")
  #   # => #<PublicSuffix::Rule::Normal>
  #   list.find("example.org")
  #   # => nil
  #
  # You can create as many {PublicSuffix::List} you want.
  # The {PublicSuffix::List.default} rule list is used
  # to tokenize and validate a domain.
  #
  # {PublicSuffix::List} implements +Enumerable+ module.
  #
  class List
    include Enumerable

    class << self
      attr_accessor :default
      attr_accessor :default_definition
    end

    # Gets the default rule list.
    # Initializes a new {PublicSuffix::List} parsing the content
    # of {PublicSuffix::List.default_definition}, if required.
    #
    # @return [PublicSuffix::List]
    def self.default
      @default ||= parse(default_definition)
    end

    # Sets the default rule list to +value+.
    #
    # @param [PublicSuffix::List] value
    #   The new rule list.
    #
    # @return [PublicSuffix::List]
    def self.default=(value)
      @default = value
    end

    # Shows if support for private (non-ICANN) domains is enabled or not
    #
    # @return [Boolean]
    def self.private_domains?
      @private_domains != false
    end

    # Enables/disables support for private (non-ICANN) domains
    # Implicitly reloads the list
    # @param [Boolean] enable/disable support
    #
    # @return [PublicSuffix::List]
    def self.private_domains=(value)
      @private_domains = !!value
      self.clear
    end

    # Sets the default rule list to +nil+.
    #
    # @return [self]
    def self.clear
      self.default = nil
      self
    end

    # Resets the default rule list and reinitialize it
    # parsing the content of {PublicSuffix::List.default_definition}.
    #
    # @return [PublicSuffix::List]
    def self.reload
      self.clear.default
    end

    # Gets the default definition list.
    # Can be any <tt>IOStream</tt> including a <tt>File</tt>
    # or a simple <tt>String</tt>.
    # The object must respond to <tt>#each_line</tt>.
    #
    # @return [File]
    def self.default_definition
      @default_definition || File.new(File.join(File.dirname(__FILE__), "..", "definitions.txt"), "r:utf-8")
    end

    # Parse given +input+ treating the content as Public Suffix List.
    #
    # See http://publicsuffix.org/format/ for more details about input format.
    #
    # @param [String] input The rule list to parse.
    #
    # @return [Array<PublicSuffix::Rule::*>]
    def self.parse(input)
      new do |list|
        input.each_line do |line|
          line.strip!
          break if !private_domains? && line.include?('===BEGIN PRIVATE DOMAINS===')
          # strip blank lines
          if line.empty?
            next
          # strip comments
          elsif line =~ %r{^//}
            next
          # append rule
          else
            list.add(Rule.factory(line), false)
          end
        end
      end
    end


    # Gets the array of rules.
    #
    # @return [Array<PublicSuffix::Rule::*>]
    attr_reader :rules

    # Gets the naive index, a hash that with the keys being the first label of
    # every rule pointing to an array of integers (indexes of the rules in @rules).
    #
    # @return [Array]
    attr_reader :indexes


    # Initializes an empty {PublicSuffix::List}.
    #
    # @yield [self] Yields on self.
    # @yieldparam [PublicSuffix::List] self The newly created instance.
    #
    def initialize(&block)
      @rules   = []
      @indexes = {}
      yield(self) if block_given?
      create_index!
    end

    # Creates a naive index for +@rules+. Just a hash that will tell
    # us where the elements of +@rules+ are relative to its first
    # {PublicSuffix::Rule::Base#labels} element.
    #
    # For instance if @rules[5] and @rules[4] are the only elements of the list
    # where Rule#labels.first is 'us' @indexes['us'] #=> [5,4], that way in 
    # select we can avoid mapping every single rule against the candidate domain.
    def create_index!
      @rules.map { |l| l.labels.first }.each_with_index do |elm, inx|
        if !@indexes.has_key?(elm)
          @indexes[elm] = [inx]
        else
          @indexes[elm] << inx
        end
      end
    end

    # Checks whether two lists are equal.
    #
    # List <tt>one</tt> is equal to <tt>two</tt>, if <tt>two</tt> is an instance of
    # {PublicSuffix::List} and each +PublicSuffix::Rule::*+
    # in list <tt>one</tt> is available in list <tt>two</tt>, in the same order.
    #
    # @param [PublicSuffix::List] other
    #   The List to compare.
    #
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(List)
      self.equal?(other) ||
      self.rules == other.rules
    end
    alias :eql? :==

    # Iterates each rule in the list.
    def each(*args, &block)
      @rules.each(*args, &block)
    end

    # Gets the list as array.
    #
    # @return [Array<PublicSuffix::Rule::*>]
    def to_a
      @rules
    end

    # Adds the given object to the list
    # and optionally refreshes the rule index.
    #
    # @param [PublicSuffix::Rule::*] rule
    #   The rule to add to the list.
    # @param [Boolean] index
    #   Set to true to recreate the rule index
    #   after the rule has been added to the list.
    #
    # @return [self]
    #
    # @see #create_index!
    #
    def add(rule, index = true)
      @rules << rule
      create_index! if index == true
      self
    end
    alias << add

    # Gets the number of elements in the list.
    #
    # @return [Integer]
    def size
      @rules.size
    end
    alias length size

    # Checks whether the list is empty.
    #
    # @return [Boolean]
    def empty?
      @rules.empty?
    end

    # Removes all elements.
    #
    # @return [self]
    def clear
      @rules.clear
      self
    end


    # Returns the most appropriate rule for domain.
    #
    # From the Public Suffix List documentation:
    #
    # * If a hostname matches more than one rule in the file,
    #   the longest matching rule (the one with the most levels) will be used.
    # * An exclamation mark (!) at the start of a rule marks an exception to a previous wildcard rule.
    #   An exception rule takes priority over any other matching rule.
    #
    # == Algorithm description
    #
    # * Match domain against all rules and take note of the matching ones.
    # * If no rules match, the prevailing rule is "*".
    # * If more than one rule matches, the prevailing rule is the one which is an exception rule.
    # * If there is no matching exception rule, the prevailing rule is the one with the most labels.
    # * If the prevailing rule is a exception rule, modify it by removing the leftmost label.
    # * The public suffix is the set of labels from the domain
    #   which directly match the labels of the prevailing rule (joined by dots).
    # * The registered domain is the public suffix plus one additional label.
    #
    # @param  [String, #to_s] domain The domain name.
    #
    # @return [PublicSuffix::Rule::*, nil]
    def find(domain)
      rules = select(domain)
      rules.select { |r|   r.type == :exception }.first ||
      rules.inject { |t,r| t.length > r.length ? t : r }
    end

    # Selects all the rules matching given domain.
    #
    # Will use +@indexes+ to try only the rules that share the same first label,
    # that will speed up things when using +List.find('foo')+ a lot.
    #
    # @param  [String, #to_s] domain The domain name.
    #
    # @return [Array<PublicSuffix::Rule::*>]
    def select(domain)
      # raise DomainInvalid, "Blank domain"
      return [] if domain.to_s !~ /[^[:space:]]/
      # raise DomainInvalid, "`#{domain}' is not expected to contain a scheme"
      return [] if domain.include?("://")

      indices = (@indexes[Domain.domain_to_labels(domain).first] || [])
      @rules.values_at(*indices).select { |rule| rule.match?(domain) }
    end

  end
end
