class RecipientsToEntities < ActiveRecord::Migration[5.2]
  def change
    remove_column :letter_recipents, :person_id, foreign_key: true
    add_reference :letter_recipents, :entity, index: true, type: :uuid, foreign_key: true
  end
end
