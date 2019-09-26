class AddMissingToLetters < ActiveRecord::Migration[5.2]
  def change
    create_table :letter_collections do |t|
      t.belongs_to :letter
      t.belongs_to :collection
    end

    create_table :owner_rights do |t|
      t.string :label
    end

    create_table :letter_senders do |t|
      t.belongs_to :letter
      t.belongs_to :entity
    end

    create_table :languages do |t|
      t.string :label
    end

    add_reference :letters, :owner_rights, index: true, foreign_key: true

    add_reference :letters, :language, index: true, foreign_key: true

    drop_table :links
  end
end
