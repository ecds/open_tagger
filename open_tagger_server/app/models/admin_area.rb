# frozen_string_literal: true

#
# <Description>
#
class AdminArea < ApplicationRecord
  belongs_to :place
  belongs_to :sub_place, class_name: 'Place'
end
