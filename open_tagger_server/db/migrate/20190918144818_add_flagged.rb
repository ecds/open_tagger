class AddFlagged < ActiveRecord::Migration[5.2]
  def change
    add_column :entities, :flagged, :boolean
  end
end
