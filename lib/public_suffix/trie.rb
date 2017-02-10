# rubocop:disable Style/Documentation

module PublicSuffix
  class Trie
    class Node
      attr_accessor :children
      attr_accessor :entry

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

      def leaf!(entry)
        @entry = entry
      end

      private

      def index(key)
        key.to_s
      end
    end

    def initialize
      @root = self.class::Node.new
    end

    def insert(word, entry)
      node = @root
      split_word(word).each do |token|
        node = node.put(token)
      end
      node.leaf!(entry) && node
    end

    def contains?(word)
      node = _prefix(word)
      node && node.leaf?
    end

    def longest_prefix(word)
      node = @root
      result = []
      length = 0

      split_word(word).each_with_index do |token, index|
        break unless (child = node.get(token))
        result << token
        node   = child
        length = index + 1 if node.leaf?
      end

      return nil if length.zero?

      result = result[0, length] if !node.leaf?
      merge_word(result)
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
      word.split(".").each
    end

    def merge_word(tokens)
      tokens.join(".")
    end

  end
end

if __FILE__ == $PROGRAM_NAME
  require "minitest/autorun"

  module PublicSuffix
    class Rule
      class Entry
      end
    end
  end

  class TrieTest < Minitest::Test
    def setup
      @trie = PublicSuffix::Trie.new
    end

    def test_validation
      @trie.insert("one.two", PublicSuffix::Rule::Entry.new)
      root = @trie.instance_variable_get(:@root)
      assert_instance_of PublicSuffix::Trie::Node, root
      assert_instance_of Hash, root.children
      assert root.children.keys.all? { |key| key.is_a?(String) }
    end

    def test_insert
      @trie.insert("com", PublicSuffix::Rule::Entry.new)
      refute @trie.contains?("co")
      refute @trie.contains?("om")
      assert @trie.contains?("com")
      refute @trie.contains?("example.com")

      @trie.insert("example.com", PublicSuffix::Rule::Entry.new)
      refute @trie.contains?("co")
      refute @trie.contains?("om")
      assert @trie.contains?("com")
      assert @trie.contains?("example.com")
    end

    def test_prefix
      @trie.insert("one.two.three.four", PublicSuffix::Rule::Entry.new)
      assert_nil @trie._prefix("three.four")
      refute_nil @trie._prefix("one.two")
      assert_nil @trie._prefix("one.two.three.four.five")

      refute @trie._prefix("one.two").leaf?
      assert @trie._prefix("one.two.three.four").leaf?
    end

    def test_longest_prefix
      @trie.insert("a.r.e", PublicSuffix::Rule::Entry.new)
      @trie.insert("a.r.e.a", PublicSuffix::Rule::Entry.new)
      @trie.insert("b.a.s.e", PublicSuffix::Rule::Entry.new)
      @trie.insert("c.a.t", PublicSuffix::Rule::Entry.new)
      @trie.insert("c.a.t.e.r", PublicSuffix::Rule::Entry.new)
      @trie.insert("c.h.i.l.d.r.e.n", PublicSuffix::Rule::Entry.new)
      @trie.insert("b.a.s.e.m.e.n.t", PublicSuffix::Rule::Entry.new)

      assert_equal "c.a.t.e.r", @trie.longest_prefix("c.a.t.e.r.e.r")
      assert_equal "b.a.s.e", @trie.longest_prefix("b.a.s.e.m.e.x.y")
      assert_nil @trie.longest_prefix("c.h.i.l.d")
    end
  end

  class TrieHashNodeTest < Minitest::Test
    def test_leaf
      node = PublicSuffix::Trie::Node.new
      refute node.leaf?

      node.leaf!(PublicSuffix::Rule::Entry.new)
      assert node.leaf?
    end

    def test_put
      node = PublicSuffix::Trie::Node.new
      refute node.contains?("2")
      node.put("2")
      assert node.contains?("2")

      node = PublicSuffix::Trie::Node.new
      aa = node.put("2")
      bb = node.put("2")
      assert node.contains?("2")
      assert_same aa, bb
    end

    def test_get
      node = PublicSuffix::Trie::Node.new
      aa = node.put("2")
      assert_same aa, node.get("2")
    end
  end
end
