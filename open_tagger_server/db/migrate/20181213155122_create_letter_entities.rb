class CreateLetterEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :letter_entities, id: :uuid do |t|
      t.belongs_to :entity, type: :uuid, index: true
      t.belongs_to :letter, type: :uuid, index: true
      t.timestamps
    end
  end
end
