class AddTypeToEntity < ActiveRecord::Migration[5.2]
  def change
    add_column :entities, :type, :integer
  end
end
