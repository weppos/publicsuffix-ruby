# == Schema Information
#
# Table name: domain_suffix
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  private    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DomainSuffix < ApplicationRecord
	
end