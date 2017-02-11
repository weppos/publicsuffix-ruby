# rubocop:disable Style/Documentation

module PublicSuffix
  class Trie
    class Node
      attr_accessor :children
      attr_accessor :type
      attr_accessor :private

      def initialize
        @children = {}
      end

      def contains?(key)
        !@children[index(key)].nil?
      end

      def put(key)
        @children[index(key)] ||= self.class.new
      end

      def get(key)
        @children[index(key)]
      end

      def leaf?
        !@type.nil?
      end

      def leaf!(type:, private:)
        @type = type
        @private = private
      end

      private

      def index(key)
        key
      end
    end


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
      node.leaf!(type: type, private: private) && node
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

        if node.leaf? && (ignore_private == false || node.private == false)
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

  end
end
