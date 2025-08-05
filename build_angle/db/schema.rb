# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_08_05_105246) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "generated_pages", force: :cascade do |t|
    t.string "title"
    t.string "page_type"
    t.text "content"
    t.bigint "generated_website_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["generated_website_id"], name: "index_generated_pages_on_generated_website_id"
  end

  create_table "generated_websites", force: :cascade do |t|
    t.string "subdomain"
    t.bigint "website_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_generated_websites_on_subdomain"
    t.index ["website_request_id"], name: "index_generated_websites_on_website_request_id"
  end

  create_table "website_requests", force: :cascade do |t|
    t.string "business_type"
    t.text "goals"
    t.string "design_preferences"
    t.text "content_needs"
    t.string "target_audience"
    t.string "email"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "generated_pages", "generated_websites"
  add_foreign_key "generated_websites", "website_requests"
end
