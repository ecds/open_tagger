class Property < ApplicationRecord
  has_many :type_properties
  has_many :entity_types, through: :type_properties

  def key
    title.parameterize.underscore
  end
end
