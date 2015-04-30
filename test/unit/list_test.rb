require 'test_helper'

class PublicSuffix::ListTest < Minitest::Unit::TestCase

  def setup
    @list = PublicSuffix::List.new
  end

  def teardown
    PublicSuffix::List.clear
  end


  def test_initialize
    assert_instance_of PublicSuffix::List, @list
    assert_equal 0, @list.length
  end

  def test_initialize_create_index_when_empty
    assert_equal({}, @list.indexes)
  end

  def test_indexes
    assert !list.indexes.empty?
    assert_equal [1,2,3,4], list.indexes.delete('uk')
    assert_equal [0], list.indexes.delete('com')
    assert list.indexes.empty?
  end


  def test_equality_with_self
    list = PublicSuffix::List.new
    assert_equal list, list
  end

  def test_equality_with_internals
    rule = PublicSuffix::Rule.factory("com")
    assert_equal PublicSuffix::List.new.add(rule), PublicSuffix::List.new.add(rule)
  end

  def test_add
    assert_equal @list, @list.add(PublicSuffix::Rule.factory(""))
    assert_equal @list, @list <<  PublicSuffix::Rule.factory("")
    assert_equal 2, @list.length
  end

  def test_add_should_recreate_index
    @list = PublicSuffix::List.parse("com")
    assert_equal PublicSuffix::Rule.factory("com"), @list.find("google.com")
    assert_equal nil, @list.find("google.net")

    @list << PublicSuffix::Rule.factory("net")
    assert_equal PublicSuffix::Rule.factory("com"), @list.find("google.com")
    assert_equal PublicSuffix::Rule.factory("net"), @list.find("google.net")
  end

  def test_add_should_not_duplicate_indices
    @list = PublicSuffix::List.parse("com")
    @list.add(PublicSuffix::Rule.factory("net"))

    assert_equal @list.indexes["com"], [0]
  end

  def test_empty?
    assert  @list.empty?
    @list.add(PublicSuffix::Rule.factory(""))
    assert !@list.empty?
  end

  def test_size
    assert_equal 0, @list.length
    assert_equal @list, @list.add(PublicSuffix::Rule.factory(""))
    assert_equal 1, @list.length
  end

  def test_clear
    assert_equal 0, @list.length
    assert_equal @list, @list.add(PublicSuffix::Rule.factory(""))
    assert_equal 1, @list.length
    assert_equal @list, @list.clear
    assert_equal 0, @list.length
  end


  def test_find
    assert_equal PublicSuffix::Rule.factory("com"),  list.find("google.com")
    assert_equal PublicSuffix::Rule.factory("com"),  list.find("foo.google.com")
    assert_equal PublicSuffix::Rule.factory("*.uk"), list.find("google.uk")
    assert_equal PublicSuffix::Rule.factory("*.uk"), list.find("google.co.uk")
    assert_equal PublicSuffix::Rule.factory("*.uk"), list.find("foo.google.co.uk")
    assert_equal PublicSuffix::Rule.factory("!british-library.uk"), list.find("british-library.uk")
    assert_equal PublicSuffix::Rule.factory("!british-library.uk"), list.find("foo.british-library.uk")
  end

  def test_select
    assert_equal 2, list.select("british-library.uk").size
  end

  def test_select_returns_empty_when_domain_is_nil
    assert_equal [], list.select(nil)
  end

  def test_select_returns_empty_when_domain_is_blank
    assert_equal [], list.select("")
    assert_equal [], list.select("  ")
  end

  def test_select_returns_empty_when_domain_has_scheme
    assert_equal [], list.select("http://google.com")
    assert_not_equal [], list.select("google.com")
  end


  def test_self_default_getter
    assert_equal     nil, PublicSuffix::List.class_eval { @default }
    PublicSuffix::List.default
    assert_not_equal nil, PublicSuffix::List.class_eval { @default }
  end

  def test_self_default_setter
    PublicSuffix::List.default
    assert_not_equal nil, PublicSuffix::List.class_eval { @default }
    PublicSuffix::List.default = nil
    assert_equal     nil, PublicSuffix::List.class_eval { @default }
  end

  def test_self_clear
    PublicSuffix::List.default
    assert_not_equal nil, PublicSuffix::List.class_eval { @default }
    PublicSuffix::List.clear
    assert_equal     nil, PublicSuffix::List.class_eval { @default }
  end

  def test_self_reload
    PublicSuffix::List.default
    PublicSuffix::List.expects(:default_definition).returns("")

    PublicSuffix::List.reload
    assert_equal PublicSuffix::List.new, PublicSuffix::List.default
  end

  def test_self_parse
    list = PublicSuffix::List.parse(<<EOS)
// ***** BEGIN LICENSE BLOCK *****
// Version: MPL 1.1/GPL 2.0/LGPL 2.1
//
// ***** END LICENSE BLOCK *****

// ac : http://en.wikipedia.org/wiki/.ac
ac
com.ac

// ad : http://en.wikipedia.org/wiki/.ad
ad

// ar : http://en.wikipedia.org/wiki/.ar
*.ar
!congresodelalengua3.ar
EOS

    assert_instance_of PublicSuffix::List, list
    assert_equal 5, list.length
    assert_equal %w(ac com.ac ad *.ar !congresodelalengua3.ar).map { |name| PublicSuffix::Rule.factory(name) }, list.to_a
  end

  def test_self_parse_should_create_cache
    assert_equal PublicSuffix::Rule.factory("com"), list.find("google.com")
  end


private

  def list
    @_list ||= PublicSuffix::List.parse(<<EOS)
// com : http://en.wikipedia.org/wiki/.com
com

// uk : http://en.wikipedia.org/wiki/.uk
*.uk
*.sch.uk
!bl.uk
!british-library.uk
EOS
  end

end
