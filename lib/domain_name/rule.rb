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

    attr_reader :name, :value, :type, :labels

    def initialize(name)
      @name   = name.to_s

      case self.name[0..0]
        when "*"  then  
          @type  = :wildcard
          @value = self.name[2..-1]
        when "!"  then
          @type  = :exception
          @value = self.name[1..-1]
        else
          @type  = :normal
          @value = self.name
      end

      @labels = self.value.split(".").reverse
    end


    # Returns true if two rules are equal.
    def ==(other)
      return false unless other.is_a?(Rule)
      self.equal?(other) ||
      self.name == other.name
    end
    alias :eql? :==


    def match?(domain_name)
      l1 = labels
      l2 = domain_name.labels
      odiff(l1, l2).empty?
    end

    def length
      if wildcard?
        labels.length + 1
      elsif exception?
        labels.length - 1
      else
        labels.length
      end
    end

    %w(normal wildcard exception).each do |method|
      define_method "#{method}?" do
        type.to_s == method
      end
    end


    protected

      def odiff(one, two)
        ii = 0
        while(ii < one.size && one[ii] == two[ii])
          ii += 1
        end
        one[ii..one.count]
      end

  end

end