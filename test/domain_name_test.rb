require 'test_helper'

class DomainNameTest < Test::Unit::TestCase

  def test_labels
    assert_equal %w(uk co google), domain_name("google.co.uk").labels
    assert_equal %w(uk google), domain_name("google.uk").labels
  end

end