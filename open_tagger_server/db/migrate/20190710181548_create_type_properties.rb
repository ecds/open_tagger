class CreateTypeProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :properties, id: :uuid do |t|
      t.string :title
    end

    create_table :type_properties do |t|
      t.belongs_to :entity_types
      t.belongs_to :properties, index: true, type: :uuid
    end
  end
end
