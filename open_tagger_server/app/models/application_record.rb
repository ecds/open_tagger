# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def dump_fixture
    fixture_file = "#{Rails.root}/test/fixtures/#{self.class.table_name}.yml"
    File.open(fixture_file, "a+") do |f|
      f.puts({ "#{self.class.table_name.singularize}_#{id}" => attributes }.
        to_yaml.sub!(/---\s?/, "\n"))
    end
  end
end
