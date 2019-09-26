class UniqueIndexRecipients < ActiveRecord::Migration[5.2]
  def change
    add_index :letter_recipients, [:letter_id, :entity_id], unique: true
  end
end
