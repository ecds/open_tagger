class Mention < ApplicationRecord
  belongs_to :letter
  belongs_to :literal
end
