# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_26_161458) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"

  create_table "alternate_spellings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.uuid "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_alternate_spellings_on_entity_id"
  end

  create_table "collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.uuid "repository_id"
  end

  create_table "entities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.integer "legacy_pk"
    t.text "description"
    t.text "suggestion"
    t.jsonb "properties"
    t.bigint "entity_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "flagged"
    t.index ["entity_type_id"], name: "index_entities_on_entity_type_id"
  end

  create_table "entity_type_properties", force: :cascade do |t|
    t.bigint "entity_type_id"
    t.bigint "property_id"
    t.index ["entity_type_id"], name: "index_entity_type_properties_on_entity_type_id"
    t.index ["property_id"], name: "index_entity_type_properties_on_property_id"
  end

  create_table "entity_types", force: :cascade do |t|
    t.string "label"
  end

  create_table "file_folders", force: :cascade do |t|
    t.string "label"
  end

  create_table "languages", force: :cascade do |t|
    t.string "label"
  end

  create_table "letter_collections", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "collection_id"
  end

  create_table "letter_owners", force: :cascade do |t|
    t.string "label"
  end

  create_table "letter_place_sent", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "entity_id"
    t.index ["entity_id"], name: "index_letter_place_sent_on_entity_id"
    t.index ["letter_id", "entity_id"], name: "index_letter_places_sent_on_letter_id_and_entity_id", unique: true
    t.index ["letter_id"], name: "index_letter_place_sent_on_letter_id"
  end

  create_table "letter_place_sents", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "entity_id"
    t.index ["entity_id"], name: "index_letter_place_sents_on_entity_id"
    t.index ["letter_id", "entity_id"], name: "index_letter_places_sents_on_letter_id_and_entity_id", unique: true
    t.index ["letter_id"], name: "index_letter_place_sents_on_letter_id"
  end

  create_table "letter_place_writtens", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "entity_id"
    t.index ["entity_id"], name: "index_letter_place_writtens_on_entity_id"
    t.index ["letter_id", "entity_id"], name: "index_letter_places_written_on_letter_id_and_entity_id", unique: true
    t.index ["letter_id"], name: "index_letter_place_writtens_on_letter_id"
  end

  create_table "letter_publishers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
  end

  create_table "letter_recipients", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "entity_id"
    t.index ["entity_id"], name: "index_letter_recipients_on_entity_id"
    t.index ["letter_id", "entity_id"], name: "index_letter_recipients_on_letter_id_and_entity_id", unique: true
    t.index ["letter_id"], name: "index_letter_recipients_on_letter_id"
  end

  create_table "letter_repositories", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "repository_id"
    t.index ["letter_id"], name: "index_letter_repositories_on_letter_id"
    t.index ["repository_id"], name: "index_letter_repositories_on_repository_id"
  end

  create_table "letter_rerecipients", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "entity_id"
    t.index ["entity_id"], name: "index_letter_repcipeints_on_entity_id"
    t.index ["letter_id"], name: "index_letter_repcipients_on_letter_id"
  end

  create_table "letter_senders", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "entity_id"
  end

  create_table "letters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "legacy_pk"
    t.string "code"
    t.datetime "date"
    t.string "addressed_to"
    t.string "addressed_from"
    t.boolean "typed"
    t.boolean "signed"
    t.string "physical_desc"
    t.string "physical_detail"
    t.text "physical_notes"
    t.string "repository_info"
    t.string "postcard_image"
    t.integer "leaves"
    t.integer "sides"
    t.string "postmark"
    t.boolean "verified"
    t.string "envelope"
    t.text "notes"
    t.text "content"
    t.uuid "letter_owner_id"
    t.bigint "file_folder_id"
    t.bigint "letter_publisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_rights_id"
    t.bigint "language_id"
    t.boolean "flagged"
    t.index ["file_folder_id"], name: "index_letters_on_file_folder_id"
    t.index ["language_id"], name: "index_letters_on_languages_id"
    t.index ["letter_owner_id"], name: "index_letters_on_letter_owner_id"
    t.index ["letter_publisher_id"], name: "index_letters_on_letter_publisher_id"
    t.index ["owner_rights_id"], name: "index_letters_on_owner_rights_id"
  end

  create_table "literals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "text"
    t.uuid "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "review"
    t.index ["entity_id"], name: "index_literals_on_entity_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_mentions_on_entity_id"
    t.index ["letter_id"], name: "index_mentions_on_letter_id"
  end

  create_table "owner_rights", force: :cascade do |t|
    t.string "label"
  end

  create_table "places_written", force: :cascade do |t|
    t.bigint "letter_id"
    t.bigint "literal_id"
    t.index ["letter_id"], name: "index_places_written_on_letter_id"
    t.index ["literal_id"], name: "index_places_written_on_literal_id"
  end

  create_table "places_writtens", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "literal_id"
    t.index ["letter_id"], name: "index_places_writtens_on_letter_id"
    t.index ["literal_id"], name: "index_places_writtens_on_literal_id"
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
  end

  create_table "repositories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.boolean "public"
    t.boolean "american"
    t.string "format"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "type_properties", force: :cascade do |t|
    t.bigint "entity_types_id"
    t.uuid "properties_id"
    t.index ["entity_types_id"], name: "index_type_properties_on_entity_types_id"
    t.index ["properties_id"], name: "index_type_properties_on_properties_id"
  end

  add_foreign_key "alternate_spellings", "entities"
  add_foreign_key "letters", "languages"
  add_foreign_key "letters", "owner_rights", column: "owner_rights_id"
end
