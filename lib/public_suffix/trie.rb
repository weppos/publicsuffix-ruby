module PublicSuffix

  # Implements a Trie data structure used to store the List.
  class Trie

    # @return [PublicSuffix::Node]
    attr_reader :root

    def initialize
      @root = self.class::Node.new
    end

    def insert(word, type:, private:)
      node = @root
      word.split(DOT).reverse.each do |token|
        node = node.put(token)
      end
      node.end!(type: type, private: private) && node
    end

    def longest_prefix(word, ignore_private: false)
      node = @root

      results = []
      leaf = nil
      excp = nil

      word.split(DOT).reverse.each_with_index do |token, index|
        break unless (child = node.get(token))
        results << [child, token]
        node = child

        if node.end? && (ignore_private == false || node.private == false)
          leaf = index + 1
          excp = index + 1 if node.type == Rule::Exception
        end
      end

      return nil if leaf.nil?

      path = excp ? results[0, excp] : results[0, leaf]
      node = path.last.first

      tokens = []
      (path.size - 1).downto(0).each do |index|
        tokens << path[index].last
      end
      node.type.new(value: tokens.join(DOT), private: node.private)
    end


    # Node is a node of the Trie and contains references to all the children nodes.
    #
    # A node marked as "end" represents the final part of a rule. It contains the rule information
    # such as the rule type and whether it belongs to PRIVATE.
    class Node
      attr_accessor :children
      attr_accessor :type
      attr_accessor :private

      def initialize
        @children = nil
      end

      def contains?(key)
        return false if @children.nil?
        !@children[index(key)].nil?
      end

      def put(key)
        @children ||= {}
        @children[index(key)] ||= self.class.new
      end

      def get(key)
        return nil if @children.nil?
        @children[index(key)]
      end

      def end?
        !@type.nil?
      end

      def end!(type:, private:)
        @type = type
        @private = private
      end

      private

      def index(key)
        key
      end
    end

  end
end
