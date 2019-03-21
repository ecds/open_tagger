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

ActiveRecord::Schema.define(version: 2018_12_13_155122) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "admin_areas", force: :cascade do |t|
    t.integer "admin_place"
    t.integer "sub_place"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "label"
    t.uuid "repository_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id"], name: "index_collections_on_repository_id"
  end

  create_table "entities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.jsonb "properties"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "entity_type_id"
    t.text "suggestion"
    t.integer "legacy_pk"
    t.index ["entity_type_id"], name: "index_entities_on_entity_type_id"
  end

  create_table "entity_properties", force: :cascade do |t|
    t.bigint "property_label_id"
    t.bigint "entity_type_id"
    t.index ["entity_type_id"], name: "index_entity_properties_on_entity_types_id"
    t.index ["property_label_id"], name: "index_entity_properties_on_property_label_id"
  end

  create_table "entity_types", force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_types", force: :cascade do |t|
    t.string "title"
  end

  create_table "genders", force: :cascade do |t|
    t.string "title"
  end

  create_table "languages", force: :cascade do |t|
    t.string "code"
    t.string "title"
    t.string "native_name"
  end

  create_table "letter_entities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "entity_id"
    t.uuid "letter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_letter_entities_on_entity_id"
    t.index ["letter_id"], name: "index_letter_entities_on_letter_id"
  end

  create_table "letter_recipients", force: :cascade do |t|
    t.uuid "letter_id"
    t.uuid "entity_id"
    t.index ["entity_id"], name: "index_letter_recipients_on_entity_id"
  end

  create_table "letter_repositories", force: :cascade do |t|
    t.uuid "repositories_id"
    t.uuid "letters_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["letters_id"], name: "index_letter_repositories_on_letters_id"
    t.index ["repositories_id"], name: "index_letter_repositories_on_repositories_id"
  end

  create_table "letter_types", force: :cascade do |t|
    t.string "title"
  end

  create_table "letters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "letter_code"
    t.boolean "verified", default: false
    t.boolean "public", default: false
    t.bigint "language_id"
    t.datetime "date_sent"
    t.string "postmark"
    t.string "envelope"
    t.integer "sides"
    t.text "content"
    t.bigint "letter_type_id"
    t.integer "leaves"
    t.integer "legacy_pk"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sender", limit: 36
    t.string "sent_to_actual", limit: 36
    t.string "sent_from_actual", limit: 36
    t.string "owner_rights", limit: 36
    t.uuid "sender_id"
    t.index ["language_id"], name: "index_letters_on_language_id"
    t.index ["letter_type_id"], name: "index_letters_on_letter_type_id"
    t.index ["owner_rights"], name: "index_letters_on_owner_rights"
    t.index ["sender"], name: "index_letters_on_sender"
    t.index ["sender_id"], name: "index_letters_on_sender_id"
    t.index ["sent_from_actual"], name: "index_letters_on_sent_from_actual"
    t.index ["sent_to_actual"], name: "index_letters_on_sent_to_actual"
  end

  create_table "literals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "text"
    t.uuid "person_id"
    t.uuid "place_id"
    t.uuid "entity_id"
    t.boolean "review", default: false
    t.index ["entity_id"], name: "index_literals_on_entity_id"
    t.index ["person_id"], name: "index_litterals_on_person_id"
    t.index ["place_id"], name: "index_litterals_on_place_id"
  end

  create_table "mentioned_people", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "letter_id"
    t.index ["letter_id"], name: "index_mentioned_people_on_letter_id"
    t.index ["person_id"], name: "index_mentioned_people_on_person_id"
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first"
    t.string "middle"
    t.string "last"
    t.string "suffix"
    t.string "title"
    t.string "nick"
    t.text "bio"
    t.text "notes"
    t.bigint "gender_id"
    t.string "viaf_id"
    t.string "bnf_id"
    t.string "gnd_id"
    t.string "isni_id"
    t.string "lccn_id"
    t.string "wikidata_id"
    t.string "olid_id"
    t.text "image"
    t.integer "yob"
    t.integer "yod"
    t.integer "legacy_pk"
    t.boolean "review", default: false
    t.uuid "entity_id"
    t.index ["entity_id"], name: "index_people_on_entity_id"
    t.index ["gender_id"], name: "index_people_on_gender_id"
  end

  create_table "person_aliases", force: :cascade do |t|
    t.bigint "person_id"
    t.string "name"
    t.text "notes"
    t.index ["person_id"], name: "index_person_aliases_on_person_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "place_admin_areas", force: :cascade do |t|
    t.string "place", limit: 36
    t.string "sub_area", limit: 36
    t.index ["place"], name: "index_place_admin_areas_on_place"
    t.index ["sub_area"], name: "index_place_admin_areas_on_sub_area"
  end

  create_table "place_literals", force: :cascade do |t|
    t.bigint "place_id"
    t.string "title"
    t.integer "legacy_pk"
    t.text "notes"
    t.index ["place_id"], name: "index_place_literals_on_place_id"
  end

  create_table "places", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title_en"
    t.string "iso_code"
    t.string "viaf_id"
    t.string "geonames_id"
    t.string "wikidata_id"
    t.string "native_label"
    t.integer "start_year"
    t.integer "end_year"
    t.text "notes"
    t.integer "legacy_pk"
    t.uuid "entity_id"
    t.index ["entity_id"], name: "index_places_on_entity_id"
  end

  create_table "property_labels", force: :cascade do |t|
    t.string "label"
    t.string "prop_type"
  end

  create_table "repositories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
  end

  create_table "repository_collections", force: :cascade do |t|
    t.text "label"
    t.uuid "repository_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id"], name: "index_repository_collections_on_repository_id"
  end

  create_table "work_types", force: :cascade do |t|
    t.string "title"
  end

  add_foreign_key "letter_recipients", "entities"
end
