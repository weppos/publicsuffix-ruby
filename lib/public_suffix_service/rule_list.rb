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

  # A {PublicSuffixService::RuleList} is a collection of one
  # or more {PublicSuffixService::Rule}.
  #
  # Given a {PublicSuffixService::RuleList},
  # you can add or remove {PublicSuffixService::Rule},
  # iterate all items in the list or search for the first rule
  # which matches a specific domain name.
  #
  #   # Create a new list
  #   list =  PublicSuffixService::RuleList.new
  #
  #   # Push two rules to the list
  #   list << PublicSuffixService::Rule.factory("it")
  #   list << PublicSuffixService::Rule.factory("com")
  #
  #   # Get the size of the list
  #   list.size
  #   # => 2
  #
  #   # Search for the rule matching given domain
  #   list.find("example.com")
  #   # => #<PublicSuffixService::Rule::Normal>
  #   list.find("example.org")
  #   # => nil
  #
  # You can create as many {PublicSuffixService::RuleList} you want.
  # The {PublicSuffixService::RuleList.default} rule list is used
  # to tokenize and validate a domain.
  #
  # {PublicSuffixService::RuleList} implements +Enumerable+ module.
  #
  class RuleList
    include Enumerable

    # Gets the list of rules.
    #
    # @return [Array<PublicSuffixService::Rule::*>]
    attr_reader :list

    # Gets the naive index, a hash that with the keys being the first label of
    # every rule pointing to an array of integers (indexes of the rules in @list)
    #
    # @return [Array]
    attr_reader :indexes


    # Initializes an empty {PublicSuffixService::RuleList}.
    #
    # @yield [self] Yields on self.
    # @yieldparam [PublicSuffixService::RuleList] self The newly creates instance
    #
    def initialize(&block)
      @list    = []
      @indexes = {}
      yield(self) if block_given?
      create_index!
    end

    # Creates a naive index for +@list+. Just a hash that will tell
    # us where the elements of +@list+ are relative to its first
    # {PublicSuffixService::Rule#labels} element.
    #
    # For instance if @list[5] and @list[4] are the only elements of the list
    # where Rule#labels.first is 'us' @indexes['us'] #=> [5,4], that way in 
    # select we can avoid mapping every single rule against the candidate domain.
    def create_index!
      @list.map{|l| l.labels.first }.each_with_index do |elm, inx|
        if !@indexes.has_key?(elm)
          @indexes[elm] = [inx]
        else
          @indexes[elm] << inx
        end
      end
    end

    # Checks whether two lists are equal.
    #
    # RuleList <tt>one</tt> is equal to <tt>two</tt>, if <tt>two</tt> is an instance of 
    # {PublicSuffixService::RuleList} and each {PublicSuffixService::Rule::*}
    # in list <tt>one</tt> is available in list <tt>two</tt>,
    # in the same order.
    #
    # @param  [PublicSuffixService::RuleList] other The rule list to compare.
    #
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(RuleList)
      self.equal?(other) ||
      self.list == other.list
    end
    alias :eql? :==

    # Iterates each rule in the list.
    def each(*args, &block)
      @list.each(*args, &block)
    end

    # Gets the list as array.
    #
    # @return [Array<PublicSuffixService::Rule::*>]
    def to_a
      @list
    end

    # Adds the given object to the list.
    #
    # @param  [PublicSuffixService::Rule::*] rule The rule to add to the list.
    #
    # @return [self]
    def add(rule)
      @list << rule
      self
    end
    alias << add

    # Gets the number of elements in the list.
    #
    # Returns an Integer.
    def size
      @list.size
    end
    alias length size

    # Checks whether the list is empty.
    #
    # @return [Boolean]
    def empty?
      @list.empty?
    end

    # Removes all elements.
    #
    # @return [self]
    def clear
      @list.clear
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
    # @return [PublicSuffixService::Rule::*, nil]
    def find(domain)
      rules = select(domain)
      rules.select { |r|   r.type == :exception }.first ||
      rules.inject { |t,r| t.length > r.length ? t : r }
    end

    # Selects all the rules matching given domain.
    #
    # Will use +@indexes+ to try only the rules that share the same first label,
    # that will speed up things when using +RuleList.find('foo')+ a lot.
    #
    # @param  [String, #to_s] domain The domain name.
    #
    # @return [Array<PublicSuffixService::Rule::*>]
    def select(domain)
      indices = (@indexes[Domain.domain_to_labels(domain).first] || [])
      @list.values_at(*indices).select { |rule| rule.match?(domain) }
    end


    @@default = nil

    class << self

      # Gets the default rule list.
      # Initializes a new {PublicSuffixService::RuleList} parsing the content
      # of {PublicSuffixService::RuleList.default_definition}, if required.
      #
      # @return [PublicSuffixService::RuleList]
      def default
        @@default ||= parse(default_definition)
      end

      # Sets the default rule list to +value+.
      #
      # @param  [PublicSuffixService::RuleList] value The new rule list.
      #
      # @return [PublicSuffixService::RuleList]
      def default=(value)
        @@default = value
      end

      # Sets the default rule list to +nil+.
      #
      # @return [self]
      def clear
        self.default = nil
        self
      end

      # Resets the default rule list and reinitialize it
      # parsing the content of {PublicSuffixService::RuleList.default_definition}.
      #
      # @return [PublicSuffixService::RuleList]
      def reload
        self.clear.default
      end

      # Gets the default definition list.
      # Can be any <tt>IOStream</tt> including a <tt>File</tt>
      # or a simple <tt>String</tt>.
      # The object must respond to <tt>#each_line</tt>.
      #
      # @return [File]
      def default_definition
        File.new(File.join(File.dirname(__FILE__), "definitions.dat"))
      end


      # Parse given +input+ treating the content as Public Suffic List.
      #
      # See http://publicsuffix.org/format/ for more details about input format.
      #
      # @param  [String] input The rule list to parse.
      #
      # @return [Array<PublicSuffixService::Rule::*>]
      def parse(input)
        new do |list|
          input.each_line do |line|
            line.strip!

            # strip blank lines
            if line.empty?
              next
            # strip comments
            elsif line =~ %r{^//}
              next
            # append rule
            else
              list << Rule.factory(line)
            end
          end
        end
      end

    end

  end

end
