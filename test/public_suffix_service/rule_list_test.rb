require 'test_helper'

class PublicSuffixService::RuleListTest < Test::Unit::TestCase

  def setup
    @list = PublicSuffixService::RuleList.new
  end

  def teardown
    PublicSuffixService::RuleList.clear
  end


  def test_initialize
    assert_instance_of PublicSuffixService::RuleList, @list
    assert_equal 0, @list.length
  end

  def test_initialize_create_index_when_empty
    assert_equal({}, @list.indexes)
  end

  def test_indexes
    @list = PublicSuffixService::RuleList.parse(<<EOS)
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
    list = PublicSuffixService::RuleList.new
    assert_equal list, list
  end

  def test_equality_with_internals
    rule = PublicSuffixService::Rule.factory("com")
    assert_equal PublicSuffixService::RuleList.new.add(rule), PublicSuffixService::RuleList.new.add(rule)
  end


  def test_add
    assert_equal @list, @list.add(PublicSuffixService::Rule.factory(""))
    assert_equal @list, @list <<  PublicSuffixService::Rule.factory("")
    assert_equal 2, @list.length
  end

  def test_add_should_recreate_index
    @list = PublicSuffixService::RuleList.parse("com")
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
    @list = PublicSuffixService::RuleList.parse(<<EOS)
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
    @list = PublicSuffixService::RuleList.parse(<<EOS)
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
    assert_equal     nil, PublicSuffixService::RuleList.send(:class_variable_get, :"@@default")
    PublicSuffixService::RuleList.default
    assert_not_equal nil, PublicSuffixService::RuleList.send(:class_variable_get, :"@@default")
  end

  def test_self_default_setter
    PublicSuffixService::RuleList.default
    assert_not_equal nil, PublicSuffixService::RuleList.send(:class_variable_get, :"@@default")
    PublicSuffixService::RuleList.default = nil
    assert_equal     nil, PublicSuffixService::RuleList.send(:class_variable_get, :"@@default")
  end

  def test_self_clear
    PublicSuffixService::RuleList.default
    assert_not_equal nil, PublicSuffixService::RuleList.send(:class_variable_get, :"@@default")
    PublicSuffixService::RuleList.clear
    assert_equal     nil, PublicSuffixService::RuleList.send(:class_variable_get, :"@@default")
  end

  def test_self_reload
    PublicSuffixService::RuleList.default
    mock(PublicSuffixService::RuleList).default_definition { "" }

    PublicSuffixService::RuleList.reload
    assert_equal PublicSuffixService::RuleList.new, PublicSuffixService::RuleList.default
  end


  def test_self_parse
    list = PublicSuffixService::RuleList.parse(<<EOS)
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

    assert_instance_of PublicSuffixService::RuleList, list
    assert_equal 5, list.length
    assert_equal %w(ac com.ac ad *.ar !congresodelalengua3.ar).map { |name| PublicSuffixService::Rule.factory(name) }, list.to_a
  end

  def test_self_parse_should_create_cache
    list = PublicSuffixService::RuleList.parse(<<EOS)
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
