# frozen_string_literal: true

class RepositorySerializer < ActiveModel::Serializer
  has_many :collections
  attributes :id, :label
end
