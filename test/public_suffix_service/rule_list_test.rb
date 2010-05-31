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
    PublicSuffixService::RuleList.expects(:default_definition).returns("")
    PublicSuffixService::RuleList.reload
    assert_equal PublicSuffixService::RuleList.new, PublicSuffixService::RuleList.default
  end

  def test_self_parse
    input = <<EOS
// ***** BEGIN LICENSE BLOCK *****
// Version: MPL 1.1/GPL 2.0/LGPL 2.1
//
// The contents of this file are subject to the Mozilla Public License Version
// 1.1 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
// for the specific language governing rights and limitations under the
// License.
//
// The Original Code is the Public Suffix List.
//
// The Initial Developer of the Original Code is
// Jo Hermans <jo.hermans@gmail.com>.
// Portions created by the Initial Developer are Copyright (C) 2007
// the Initial Developer. All Rights Reserved.
//
// Contributor(s):
//   Ruben Arakelyan <ruben@wackomenace.co.uk>
//   Gervase Markham <gerv@gerv.net>
//   Pamela Greene <pamg.bugs@gmail.com>
//   David Triendl <david@triendl.name>
//   The kind representatives of many TLD registries
//
// Alternatively, the contents of this file may be used under the terms of
// either the GNU General Public License Version 2 or later (the "GPL"), or
// the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
// in which case the provisions of the GPL or the LGPL are applicable instead
// of those above. If you wish to allow use of your version of this file only
// under the terms of either the GPL or the LGPL, and not to allow others to
// use your version of this file under the terms of the MPL, indicate your
// decision by deleting the provisions above and replace them with the notice
// and other provisions required by the GPL or the LGPL. If you do not delete
// the provisions above, a recipient may use your version of this file under
// the terms of any one of the MPL, the GPL or the LGPL.
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
    expected = []
    list = PublicSuffixService::RuleList.parse(input)

    assert_instance_of PublicSuffixService::RuleList, list
    assert_equal 5, list.length
    assert_equal %w(ac com.ac ad *.ar !congresodelalengua3.ar).map { |name| PublicSuffixService::Rule.factory(name) }, list.to_a
  end

end