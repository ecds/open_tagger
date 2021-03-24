class MentionsUuids < ActiveRecord::Migration[5.2]
  def change
    add_column :mentions, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
    remove_column :mentions, :id
    rename_column :mentions, :uuid, :id
    execute "ALTER TABLE mentions ADD PRIMARY KEY (id)"
  end
end
