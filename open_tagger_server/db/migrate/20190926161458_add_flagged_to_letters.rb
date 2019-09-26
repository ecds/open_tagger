class AddFlaggedToLetters < ActiveRecord::Migration[5.2]
  def change
    add_column :letters, :flagged, :boolean
  end
end
