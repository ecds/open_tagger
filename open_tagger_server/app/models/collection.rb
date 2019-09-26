class Collection < ApplicationRecord
  belongs_to :repository

  scope :_public, -> {
    includes(:repository)
    .where(
      repositories: {
        public: true
      }
    )
  }
end
