# frozen_string_literal: true

class RepositoryBaseSerializer < ActiveModel::Serializer
  has_many :collections
  attributes :id, :label, :public, :american, :letter_count
end
