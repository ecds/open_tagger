class AddTypeToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :prop_type, :text
  end
end
