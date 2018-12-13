class AddLegacyPk < ActiveRecord::Migration[5.2]
  def change
    add_column :entities, :legacy_pk, :integer
  end
end
