class RenameType < ActiveRecord::Migration[5.2]
  def change
    rename_column :entities, :type, :e_type
  end
end
