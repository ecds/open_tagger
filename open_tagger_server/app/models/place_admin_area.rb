# frozen_string_literal: true

#
# <Description>
#
class PlaceAdminArea < ApplicationRecord
  belongs_to :place
  belongs_to :sub_area, class_name: 'Place'

  validates_uniqueness_of :place_id, scope: :sub_area_id
end
