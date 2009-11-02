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


class DomainName

  class RuleList
    include Enumerable

    attr_reader :list


    def initialize(&block)
      @list = []
      yield(self) if block_given?
    end


    # Returns true if two rules are equal.
    def ==(other)
      return false unless other.is_a?(RuleList)
      self.equal?(other) ||
      self.list == other.list
    end
    alias :eql? :==

    def each(*args, &block)
      @list.each(*args, &block)
    end

    def to_a
      @list
    end

    # Adds the given object to the set and returns self.
    def add(rule)
      @list << rule
      self
    end
    alias << add
    
    # Returns the number of elements.
    def size
      @list.size
    end
    alias length size

    # Returns true if the set contains no elements.
    def empty?
      @list.empty?
    end

    # Removes all elements and returns self.
    def clear
      @list.clear
      self
    end


    def find(domain_name)
      rules = select(domain_name)
      rules.select { |r|   r.type == :exception }.first ||
      rules.inject { |t,r| t.length > r.length ? t : r }
    end

    def select(domain_name)
      @list.select { |rule| rule.match?(domain_name) }
    end


    @@default = nil

    class << self

      # Returns the default <tt>RuleList</tt>.
      # Initializes a new <tt>RuleList</tt> parsing the content of <tt>default_definition</tt> if necessary.
      def default
        @@default ||= parse(default_definition)
      end

      # Sets the default <tt>RuleList</tt> to <tt>value</tt>.
      def default=(value)
        @@default = value
      end

      # Sets the default <tt>RuleList</tt> to <tt>nil</tt>.
      def clear
        self.default = nil
        self
      end

      # Resets the default <tt>RuleList</tt> and reinitialize it
      # parsing the content of <tt>default_definition</tt>.
      def reload
        self.clear.default
      end

      # Returns the default definition list.
      # Can be any IOStream including a <tt>String</tt> or a simple <tt>String</tt>.
      def default_definition
        File.new(File.join(File.dirname(__FILE__), "definitions.dat"))
      end


      # Parse given <tt>input</tt> treating the content as Public Suffic List.
      # See http://publicsuffix.org/format/ for more details about input format.
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
              list << Rule.new(line)
            end
          end
        end
      end

    end

  end

end