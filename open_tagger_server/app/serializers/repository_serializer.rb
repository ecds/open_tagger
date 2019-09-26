# frozen_string_literal: true

class RepositorySerializer < ActiveModel::Serializer
  has_many :collections
  attributes :id, :label, :public, :american, :letter_list, :letter_count
end
