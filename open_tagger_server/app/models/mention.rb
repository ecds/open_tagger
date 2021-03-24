class Mention < ApplicationRecord
  belongs_to :letter
  belongs_to :entity

  acts_as_taggable
end
