require_relative 'trie_hash'

module PublicSuffix
  class TrieHashParts < TrieHash
    class Node < TrieHash::Node
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

    private

    def split_word(word)
      word.split(".").each
    end

    def merge_word(tokens)
      tokens.join(".")
    end

  end
end

if __FILE__ == $0
  require 'minitest/autorun'

  class TrieHashTest < Minitest::Test
    def setup
      @trie = PublicSuffix::TrieHashParts.new
    end

    def test_validation
      @trie.insert("one.two")
      root = @trie.instance_variable_get(:@root)
      assert_instance_of PublicSuffix::TrieHashParts::Node, root
      assert_instance_of Hash, root.children
      assert root.children.keys.all? { |key| key.is_a?(String) }
      assert root.children.keys.all? { |key| key.size != 1 }
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

  class TrieHashNodeTest < Minitest::Test
    def test_leaf
      node = PublicSuffix::TrieHashParts::Node.new
      refute node.leaf?

      node.leaf!
      assert node.leaf?
    end

    def test_put
      node = PublicSuffix::TrieHashParts::Node.new
      refute node.contains?("2")
      node.put("2")
      assert node.contains?("2")

      node = PublicSuffix::TrieHashParts::Node.new
      aa = node.put("2")
      bb = node.put("2")
      assert node.contains?("2")
      assert_same aa, bb
    end

    def test_get
      node = PublicSuffix::TrieHashParts::Node.new
      aa = node.put("2")
      assert_same aa, node.get("2")
    end
  end
end
