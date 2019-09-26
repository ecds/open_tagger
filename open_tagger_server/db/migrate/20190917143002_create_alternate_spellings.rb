class CreateAlternateSpellings < ActiveRecord::Migration[5.2]
  def change
    create_table :alternate_spellings, id: :uuid do |t|
      t.string :label
      t.belongs_to :entity, index: true, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
