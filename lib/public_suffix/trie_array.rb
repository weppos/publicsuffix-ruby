module PublicSuffix
  class TrieArray
    MAPPING = {}.tap do |hash|
      ((0..9).to_a + ("a".."z").to_a + [".", "-", "!", "*"]).each_with_index do |char, index|
        hash[char.to_s] = index
      end
    end

    class Node
      attr_accessor :leaf
      attr_accessor :children

      def initialize(*)
        @children = []
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
        @leaf == true
      end

      def leaf!
        @leaf = true
      end

      private

      def index(key)
        MAPPING[key] or raise "Unknown mapping for `#{key}`"
      end
    end

    def initialize
      @root = self.class::Node.new(nil)
    end

    def insert(word)
      node = @root
      split_word(word).each do |token|
        node = node.put(token)
      end
      node.leaf! && node
    end

    def contains?(word)
      node = _prefix(word)
      node && node.leaf?
    end

    def longest_prefix(word)
      node = @root
      result = ""
      length = 0

      split_word(word).each_with_index do |token, index|
        break unless (child = node.get(token))
        result = merge_word(result, token)
        node   = child
        length = index + 1 if node.leaf?
      end

      return nil if length.zero?
      node.leaf? ? result : result[0, length]
    end

    def _prefix(word)
      node = @root
      split_word(word).each do |token|
        node = node.get(token)
        return nil if node.nil?
      end
      node
    end

    private

    def split_word(word)
      word.each_char
    end

    def merge_word(token1, token2)
      token1 << token2
    end

  end
end

if __FILE__ == $0
  require 'minitest/autorun'

  class TrieArrayTest < Minitest::Test
    def setup
      @trie = PublicSuffix::TrieArray.new
    end

    def test_validation
      @trie.insert("one.two")
      root = @trie.instance_variable_get(:@root)
      assert_instance_of PublicSuffix::TrieArray::Node, root
      assert_instance_of Array, root.children
    end

    def test_insert
      @trie.insert("com")
      refute @trie.contains?("co")
      refute @trie.contains?("om")
      assert @trie.contains?("com")
      refute @trie.contains?("example.com")

      @trie.insert("example.com")
      refute @trie.contains?("co")
      refute @trie.contains?("om")
      assert @trie.contains?("com")
      assert @trie.contains?("example.com")
    end

    def test_prefix
      @trie.insert("one.two.three.four")
      assert_nil @trie._prefix("three.four")
      refute_nil @trie._prefix("one.two")
      assert_nil @trie._prefix("one.two.three.four.five")

      refute @trie._prefix("one.two").leaf?
      assert @trie._prefix("one.two.three.four").leaf?
    end

    def test_longest_prefix
      @trie.insert("a.r.e")
      @trie.insert("a.r.e.a")
      @trie.insert("b.a.s.e")
      @trie.insert("c.a.t")
      @trie.insert("c.a.t.e.r")
      @trie.insert("c.h.i.l.d.r.e.n")
      @trie.insert("b.a.s.e.m.e.n.t")

      assert_equal "c.a.t.e.r", @trie.longest_prefix("c.a.t.e.r.e.r")
      assert_equal "b.a.s.e", @trie.longest_prefix("b.a.s.e.m.e.x.y")
      assert_nil @trie.longest_prefix("c.h.i.l.d")
    end
  end

  class TrieArrayNodeTest < Minitest::Test
    def test_leaf
      node = PublicSuffix::TrieArray::Node.new
      refute node.leaf?

      node.leaf!
      assert node.leaf?
    end

    def test_put
      node = PublicSuffix::TrieArray::Node.new
      refute node.contains?("2")
      node.put("2")
      assert node.contains?("2")

      node = PublicSuffix::TrieArray::Node.new
      aa = node.put("2")
      bb = node.put("2")
      assert node.contains?("2")
      assert_same aa, bb
    end

    def test_get
      node = PublicSuffix::TrieArray::Node.new
      aa = node.put("2")
      assert_same aa, node.get("2")
    end
  end
end
