class RedoTypeProperties < ActiveRecord::Migration[5.2]
  def change
    remove_index :type_properties, name: 'index_type_properties_on_entity_types_id'
    remove_index :type_properties, name: 'index_type_properties_on_properties_id'
    drop_table :type_properties

    create_table :type_properties do |t|
      t.belongs_to :entity_type, index: true, foreign_key: true
      t.belongs_to :property, index: true, foreign_key: true, type: :uuid
    end

  end
end
