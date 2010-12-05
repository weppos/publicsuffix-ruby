require 'test_helper'

class ErrorsTest < Test::Unit::TestCase

  # Inherits from StandardError
  def test_error_inheritance
    assert_kind_of  StandardError,
                    PublicSuffixService::Error.new
  end

  # Inherits from PublicSuffixService::Error
  def test_domain_invalid_inheritance
    assert_kind_of  PublicSuffixService::Error,
                    PublicSuffixService::DomainInvalid.new
  end

  # Inherits from PublicSuffixService::DomainInvalid
  def test_domain_not_allowed_inheritance
    assert_kind_of  PublicSuffixService::DomainInvalid,
                    PublicSuffixService::DomainNotAllowed.new
  end

end