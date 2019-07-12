class CreateLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :links, id: :uuid do |t|
      t.text :link
      t.belongs_to :entity, index: true
      t.timestamps
    end
  end
end
