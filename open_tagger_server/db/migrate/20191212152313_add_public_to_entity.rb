class AddPublicToEntity < ActiveRecord::Migration[5.2]
  def change
    add_column :entities, :is_public, :boolean
  end
end
