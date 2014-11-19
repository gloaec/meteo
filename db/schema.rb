# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141113175439) do

  create_table "cartes", force: true do |t|
    t.integer  "domaine_id"
    t.string   "echeance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domaines", force: true do |t|
    t.integer  "prevision_id"
    t.string   "zone"
    t.string   "nom"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ephemerides", force: true do |t|
    t.integer  "rapport_id"
    t.string   "echeance"
    t.string   "lever"
    t.string   "coucher"
    t.integer  "variation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ftps", force: true do |t|
    t.string   "host"
    t.integer  "port"
    t.string   "user",                             default: "", null: false
    t.binary   "password_digest", limit: 16777215
    t.boolean  "passive"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paths", force: true do |t|
    t.string   "path"
    t.integer  "ftp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paths", ["ftp_id"], name: "index_paths_on_ftp_id", using: :btree

  create_table "previsions", force: true do |t|
    t.integer  "rapport_id"
    t.string   "echeance"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rapports", force: true do |t|
    t.string   "xml_file_name"
    t.string   "xml_content_type"
    t.integer  "xml_file_size"
    t.datetime "xml_updated_at"
    t.date     "date"
    t.string   "date_str"
    t.string   "rapport_type"
    t.text     "unites"
    t.string   "mtime"
    t.integer  "path_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "role"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "villes", force: true do |t|
    t.integer  "carte_id"
    t.string   "nom"
    t.integer  "temperature"
    t.integer  "temperature_min"
    t.integer  "temperature_max"
    t.integer  "uv"
    t.string   "temps_sensible"
    t.integer  "vent_vitesse"
    t.string   "vent_direction"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zones", force: true do |t|
    t.integer  "domaine_id"
    t.integer  "_id"
    t.string   "nom"
    t.integer  "lamb_x"
    t.integer  "lamb_y"
    t.integer  "temperature"
    t.integer  "temperature_mer"
    t.integer  "uv"
    t.string   "temps_sensible"
    t.integer  "vent_vitesse"
    t.string   "vent_direction"
    t.string   "etat_mer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
