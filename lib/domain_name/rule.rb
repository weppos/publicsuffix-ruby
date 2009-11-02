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

  class Rule

    def self.factory(name)
      klass = case name.to_s[0..0]
        when "*"  then  "wildcard"
        when "!"  then  "exception"
        else            "normal"
      end
      const_get(klass.capitalize).new(name)
    end

    
    class Base

      attr_reader :name, :value, :type, :labels

      def initialize(name, value = nil)
        @name   = name.to_s
        @value  = value || @name
        @type   = self.class.name.split("::").last.downcase.to_sym
        @labels = @value.split(".").reverse
      end


      # Returns <tt>true</tt> if two rules are equal.
      def ==(other)
        return false unless other.is_a?(self.class)
        self.equal?(other) ||
        self.name == other.name
      end
      alias :eql? :==


      # Returns <tt>true</tt> if this rule matches <tt>domain_name</tt>.
      def match?(domain_name)
        l1 = labels
        l2 = domain_name.labels
        odiff(l1, l2).empty?
      end

      # Returns the length of this rule for comparison.
      # The rule usually matches the number of rule <tt>parts</tt>.
      def length
        parts.length
      end

      def parts
        raise NotImplementedError
      end

      def decompose(domain)
        raise NotImplementedError
      end


      private

        def odiff(one, two)
          ii = 0
          while(ii < one.size && one[ii] == two[ii])
            ii += 1
          end
          one[ii..one.count]
        end

    end

    class Normal < Base

      def initialize(name)
        super(name, name)
      end

      # dot-split rule value and returns all rule parts
      # in the order they appear in the value.
      def parts
        @parts ||= @value.split(".")
      end

      def decompose(domain)
        domain.name =~ /^(.*)\.(#{parts.join('\.')})$/
        [$1, $2]
      end

    end

    class Wildcard < Base

      def initialize(name)
        super(name, name.to_s[2..-1])
      end

      # dot-split rule value and returns all rule parts
      # in the order they appear in the value.
      def parts
        @parts ||= @value.split(".")
      end

      def length
        parts.length + 1 # * counts as 1
      end

      def decompose(domain)
        domain.name =~ /^(.*)\.(.*?\.#{parts.join('\.')})$/
        [$1, $2]
      end

    end

    class Exception < Base

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
      def parts
        @parts ||= @value.split(".")[1..-1]
      end

      def decompose(domain)
        domain.name =~  /^(.*)\.(#{parts.join('\.')})$/
        [$1, $2]
      end

    end

  end

end