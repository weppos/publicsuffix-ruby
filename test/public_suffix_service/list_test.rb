require 'test_helper'

class PublicSuffixService::ListTest < Test::Unit::TestCase

  def setup
    @list = PublicSuffixService::List.new
  end

  def teardown
    PublicSuffixService::List.clear
  end


  def test_initialize
    assert_instance_of PublicSuffixService::List, @list
    assert_equal 0, @list.length
  end

  def test_initialize_create_index_when_empty
    assert_equal({}, @list.indexes)
  end

  def test_indexes
    @list = PublicSuffixService::List.parse(<<EOS)
// com : http://en.wikipedia.org/wiki/.com
com

// uk : http://en.wikipedia.org/wiki/.uk
*.uk
*.sch.uk
!bl.uk
!british-library.uk
EOS

    assert !@list.indexes.empty?
    assert_equal [1,2,3,4], @list.indexes.delete('uk')
    assert_equal [0], @list.indexes.delete('com')
    assert @list.indexes.empty?
  end


  def test_equality_with_self
    list = PublicSuffixService::List.new
    assert_equal list, list
  end

  def test_equality_with_internals
    rule = PublicSuffixService::Rule.factory("com")
    assert_equal PublicSuffixService::List.new.add(rule), PublicSuffixService::List.new.add(rule)
  end


  def test_add
    assert_equal @list, @list.add(PublicSuffixService::Rule.factory(""))
    assert_equal @list, @list <<  PublicSuffixService::Rule.factory("")
    assert_equal 2, @list.length
  end

  def test_add_should_recreate_index
    @list = PublicSuffixService::List.parse("com")
    assert_equal PublicSuffixService::Rule.factory("com"), @list.find("google.com")
    assert_equal nil, @list.find("google.net")

    @list << PublicSuffixService::Rule.factory("net")
    assert_equal PublicSuffixService::Rule.factory("com"), @list.find("google.com")
    assert_equal PublicSuffixService::Rule.factory("net"), @list.find("google.net")
  end

  def test_empty?
    assert  @list.empty?
    @list.add(PublicSuffixService::Rule.factory(""))
    assert !@list.empty?
  end

  def test_size
    assert_equal 0, @list.length
    assert_equal @list, @list.add(PublicSuffixService::Rule.factory(""))
    assert_equal 1, @list.length
  end

  def test_clear
    assert_equal 0, @list.length
    assert_equal @list, @list.add(PublicSuffixService::Rule.factory(""))
    assert_equal 1, @list.length
    assert_equal @list, @list.clear
    assert_equal 0, @list.length
  end


  def test_find
    @list = PublicSuffixService::List.parse(<<EOS)
// com : http://en.wikipedia.org/wiki/.com
com

// uk : http://en.wikipedia.org/wiki/.uk
*.uk
*.sch.uk
!bl.uk
!british-library.uk
EOS
    assert_equal PublicSuffixService::Rule.factory("com"),  @list.find("google.com")
    assert_equal PublicSuffixService::Rule.factory("com"),  @list.find("foo.google.com")
    assert_equal PublicSuffixService::Rule.factory("*.uk"), @list.find("google.uk")
    assert_equal PublicSuffixService::Rule.factory("*.uk"), @list.find("google.co.uk")
    assert_equal PublicSuffixService::Rule.factory("*.uk"), @list.find("foo.google.co.uk")
    assert_equal PublicSuffixService::Rule.factory("!british-library.uk"), @list.find("british-library.uk")
    assert_equal PublicSuffixService::Rule.factory("!british-library.uk"), @list.find("foo.british-library.uk")
  end

  def test_select
    @list = PublicSuffixService::List.parse(<<EOS)
// com : http://en.wikipedia.org/wiki/.com
com

// uk : http://en.wikipedia.org/wiki/.uk
*.uk
*.sch.uk
!bl.uk
!british-library.uk
EOS
    assert_equal 2, @list.select("british-library.uk").size
  end


  def test_self_default_getter
    assert_equal     nil, PublicSuffixService::List.send(:class_variable_get, :"@@default")
    PublicSuffixService::List.default
    assert_not_equal nil, PublicSuffixService::List.send(:class_variable_get, :"@@default")
  end

  def test_self_default_setter
    PublicSuffixService::List.default
    assert_not_equal nil, PublicSuffixService::List.send(:class_variable_get, :"@@default")
    PublicSuffixService::List.default = nil
    assert_equal     nil, PublicSuffixService::List.send(:class_variable_get, :"@@default")
  end

  def test_self_clear
    PublicSuffixService::List.default
    assert_not_equal nil, PublicSuffixService::List.send(:class_variable_get, :"@@default")
    PublicSuffixService::List.clear
    assert_equal     nil, PublicSuffixService::List.send(:class_variable_get, :"@@default")
  end

  def test_self_reload
    PublicSuffixService::List.default
    PublicSuffixService::List.expects(:default_definition).returns("")

    PublicSuffixService::List.reload
    assert_equal PublicSuffixService::List.new, PublicSuffixService::List.default
  end


  def test_self_parse
    list = PublicSuffixService::List.parse(<<EOS)
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

    assert_instance_of PublicSuffixService::List, list
    assert_equal 5, list.length
    assert_equal %w(ac com.ac ad *.ar !congresodelalengua3.ar).map { |name| PublicSuffixService::Rule.factory(name) }, list.to_a
  end

  def test_self_parse_should_create_cache
    list = PublicSuffixService::List.parse(<<EOS)
// com : http://en.wikipedia.org/wiki/.com
com

// uk : http://en.wikipedia.org/wiki/.uk
*.uk
*.sch.uk
!bl.uk
!british-library.uk
EOS

    assert_equal PublicSuffixService::Rule.factory("com"), list.find("google.com")
  end

end
