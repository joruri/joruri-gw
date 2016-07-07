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

ActiveRecord::Schema.define(version: 20160707080333) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "digitallibrary_adms", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "digitallibrary_adms", ["title_id"], name: "index_digitallibrary_adms_on_title_id", using: :btree

  create_table "digitallibrary_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.string   "create_section",                          limit: 255
    t.integer  "addnew_forbidden",                        limit: 4
    t.integer  "draft_forbidden",                         limit: 4
    t.integer  "delete_forbidden",                        limit: 4
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.string   "left_index_bg_color",                     limit: 255
    t.string   "default_folder",                          limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.integer  "notification",                            limit: 4
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "separator_str1",                          limit: 255
    t.string   "separator_str2",                          limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.datetime "docslast_updated_at"
  end

  add_index "digitallibrary_controls", ["notification"], name: "index_digitallibrary_controls_on_notification", using: :btree

  create_table "digitallibrary_db_files", force: :cascade do |t|
    t.integer "title_id",  limit: 4
    t.integer "parent_id", limit: 4
    t.binary  "data",      limit: 4294967295
    t.integer "serial_no", limit: 4
    t.integer "migrated",  limit: 4
  end

  add_index "digitallibrary_db_files", ["parent_id"], name: "index_digitallibrary_db_files_on_parent_id", using: :btree
  add_index "digitallibrary_db_files", ["title_id"], name: "index_digitallibrary_db_files_on_title_id", using: :btree

  create_table "digitallibrary_docs", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.integer  "parent_id",          limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "display_order",      limit: 4
    t.integer  "doc_alias",          limit: 4
    t.integer  "title_id",           limit: 4
    t.integer  "chg_parent_id",      limit: 4
    t.integer  "sort_no",            limit: 4
    t.float    "seq_no",             limit: 24
    t.integer  "order_no",           limit: 4
    t.string   "seq_name",           limit: 255
    t.integer  "level_no",           limit: 4
    t.string   "section_code",       limit: 255
    t.text     "section_name",       limit: 65535
    t.text     "name",               limit: 65535
    t.text     "title",              limit: 65535
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keywords",           limit: 16777215
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.text     "readers",            limit: 65535
    t.text     "readers_json",       limit: 65535
    t.text     "notes_001",          limit: 65535
    t.integer  "attachmentfile",     limit: 4
    t.integer  "serial_no",          limit: 4
    t.integer  "migrated",           limit: 4
    t.integer  "wiki",               limit: 4
  end

  add_index "digitallibrary_docs", ["title_id"], name: "index_digitallibrary_docs_on_title_id", using: :btree

  create_table "digitallibrary_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "digitallibrary_files", ["parent_id"], name: "index_digitallibrary_files_on_parent_id", using: :btree
  add_index "digitallibrary_files", ["title_id"], name: "index_digitallibrary_files_on_title_id", using: :btree

  create_table "digitallibrary_images", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.text     "parent_name",       limit: 65535
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "digitallibrary_images", ["parent_id"], name: "index_digitallibrary_images_on_parent_id", using: :btree
  add_index "digitallibrary_images", ["title_id"], name: "index_digitallibrary_images_on_title_id", using: :btree

  create_table "digitallibrary_recognizers", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id",      limit: 4
    t.integer  "parent_id",     limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "code",          limit: 255
    t.text     "name",          limit: 65535
    t.datetime "recognized_at"
    t.integer  "serial_no",     limit: 4
    t.integer  "migrated",      limit: 4
  end

  add_index "digitallibrary_recognizers", ["parent_id"], name: "index_digitallibrary_recognizers_on_parent_id", using: :btree
  add_index "digitallibrary_recognizers", ["title_id"], name: "index_digitallibrary_recognizers_on_title_id", using: :btree

  create_table "digitallibrary_roles", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.string   "role_code",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "digitallibrary_roles", ["title_id"], name: "index_digitallibrary_roles_on_title_id", using: :btree

  create_table "doclibrary_adms", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "doclibrary_adms", ["title_id"], name: "index_doclibrary_adms_on_title_id", using: :btree

  create_table "doclibrary_categories", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.integer  "sort_no",            limit: 4
    t.integer  "level_no",           limit: 4
    t.text     "wareki",             limit: 65535
    t.integer  "nen",                limit: 4
    t.integer  "gatsu",              limit: 4
    t.integer  "sono",               limit: 4
    t.integer  "sono2",              limit: 4
    t.string   "filename",           limit: 255
    t.string   "note_id",            limit: 255
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.integer  "serial_no",          limit: 4
    t.integer  "migrated",           limit: 4
  end

  add_index "doclibrary_categories", ["title_id"], name: "index_doclibrary_categories_on_title_id", using: :btree

  create_table "doclibrary_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.string   "create_section",                          limit: 255
    t.integer  "addnew_forbidden",                        limit: 4
    t.integer  "draft_forbidden",                         limit: 4
    t.integer  "delete_forbidden",                        limit: 4
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.string   "left_index_bg_color",                     limit: 255
    t.string   "default_folder",                          limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.integer  "notification",                            limit: 4
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.text     "special_link",                            limit: 65535
    t.datetime "docslast_updated_at"
  end

  add_index "doclibrary_controls", ["notification"], name: "index_doclibrary_controls_on_notification", using: :btree

  create_table "doclibrary_db_files", force: :cascade do |t|
    t.integer "title_id",  limit: 4
    t.integer "parent_id", limit: 4
    t.binary  "data",      limit: 4294967295
    t.integer "serial_no", limit: 4
    t.integer "migrated",  limit: 4
  end

  add_index "doclibrary_db_files", ["parent_id"], name: "index_doclibrary_db_files_on_parent_id", using: :btree
  add_index "doclibrary_db_files", ["title_id"], name: "index_doclibrary_db_files_on_title_id", using: :btree

  create_table "doclibrary_docs", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.text     "content_state",      limit: 65535
    t.string   "section_code",       limit: 255
    t.text     "section_name",       limit: 65535
    t.integer  "importance",         limit: 4
    t.integer  "one_line_note",      limit: 4
    t.integer  "title_id",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "pname",              limit: 65535
    t.text     "title",              limit: 65535
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use",       limit: 4
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keywords",           limit: 65535
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.datetime "expiry_date"
    t.integer  "attachmentfile",     limit: 4
    t.string   "form_name",          limit: 255
    t.text     "inpfld_001",         limit: 65535
    t.integer  "inpfld_002",         limit: 4
    t.integer  "inpfld_003",         limit: 4
    t.integer  "inpfld_004",         limit: 4
    t.integer  "inpfld_005",         limit: 4
    t.integer  "inpfld_006",         limit: 4
    t.text     "inpfld_007",         limit: 65535
    t.text     "inpfld_008",         limit: 65535
    t.text     "inpfld_009",         limit: 65535
    t.text     "inpfld_010",         limit: 65535
    t.text     "inpfld_011",         limit: 65535
    t.text     "inpfld_012",         limit: 65535
    t.text     "notes_001",          limit: 65535
    t.text     "notes_002",          limit: 65535
    t.text     "notes_003",          limit: 65535
    t.integer  "serial_no",          limit: 4
    t.integer  "migrated",           limit: 4
    t.integer  "wiki",               limit: 4
  end

  create_table "doclibrary_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "doclibrary_files", ["parent_id"], name: "index_doclibrary_files_on_parent_id", using: :btree
  add_index "doclibrary_files", ["title_id"], name: "index_doclibrary_files_on_title_id", using: :btree

  create_table "doclibrary_folder_acls", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "folder_id",        limit: 4
    t.integer  "title_id",         limit: 4
    t.integer  "acl_flag",         limit: 4
    t.integer  "acl_section_id",   limit: 4
    t.string   "acl_section_code", limit: 255
    t.text     "acl_section_name", limit: 65535
    t.integer  "acl_user_id",      limit: 4
    t.string   "acl_user_code",    limit: 255
    t.text     "acl_user_name",    limit: 65535
    t.integer  "serial_no",        limit: 4
    t.integer  "migrated",         limit: 4
  end

  create_table "doclibrary_folders", force: :cascade do |t|
    t.integer  "unid",                 limit: 4
    t.integer  "parent_id",            limit: 4
    t.text     "state",                limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",             limit: 4
    t.integer  "sort_no",              limit: 4
    t.integer  "level_no",             limit: 4
    t.integer  "children_size",        limit: 4
    t.integer  "total_children_size",  limit: 4
    t.text     "name",                 limit: 65535
    t.text     "memo",                 limit: 65535
    t.text     "readers",              limit: 65535
    t.text     "readers_json",         limit: 65535
    t.text     "reader_groups",        limit: 65535
    t.text     "reader_groups_json",   limit: 65535
    t.datetime "docs_last_updated_at"
    t.integer  "serial_no",            limit: 4
    t.integer  "migrated",             limit: 4
  end

  create_table "doclibrary_group_folders", force: :cascade do |t|
    t.integer  "unid",                 limit: 4
    t.integer  "parent_id",            limit: 4
    t.text     "state",                limit: 65535
    t.text     "use_state",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",             limit: 4
    t.integer  "sort_no",              limit: 4
    t.integer  "level_no",             limit: 4
    t.integer  "children_size",        limit: 4
    t.integer  "total_children_size",  limit: 4
    t.string   "code",                 limit: 255
    t.text     "name",                 limit: 65535
    t.integer  "sysgroup_id",          limit: 4
    t.integer  "sysparent_id",         limit: 4
    t.text     "readers",              limit: 65535
    t.text     "readers_json",         limit: 65535
    t.text     "reader_groups",        limit: 65535
    t.text     "reader_groups_json",   limit: 65535
    t.datetime "docs_last_updated_at"
    t.integer  "serial_no",            limit: 4
    t.integer  "migrated",             limit: 4
  end

  create_table "doclibrary_images", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.text     "parent_name",       limit: 65535
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "doclibrary_images", ["parent_id"], name: "index_doclibrary_images_on_parent_id", using: :btree
  add_index "doclibrary_images", ["title_id"], name: "index_doclibrary_images_on_title_id", using: :btree

  create_table "doclibrary_recognizers", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id",      limit: 4
    t.integer  "parent_id",     limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "code",          limit: 255
    t.text     "name",          limit: 65535
    t.datetime "recognized_at"
    t.integer  "serial_no",     limit: 4
    t.integer  "migrated",      limit: 4
  end

  add_index "doclibrary_recognizers", ["parent_id"], name: "index_doclibrary_recognizers_on_parent_id", using: :btree
  add_index "doclibrary_recognizers", ["title_id"], name: "index_doclibrary_recognizers_on_title_id", using: :btree

  create_table "doclibrary_roles", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.string   "role_code",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "doclibrary_roles", ["title_id"], name: "index_doclibrary_roles_on_title_id", using: :btree

  create_table "enquete_answers", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "latest_updated_at"
    t.boolean  "enquete_division"
    t.integer  "title_id",           limit: 4
    t.string   "user_code",          limit: 255
    t.text     "user_name",          limit: 65535
    t.string   "l2_section_code",    limit: 255
    t.string   "section_code",       limit: 255
    t.text     "section_name",       limit: 65535
    t.integer  "section_sort",       limit: 4
    t.text     "field_001",          limit: 65535
    t.text     "field_002",          limit: 65535
    t.text     "field_003",          limit: 65535
    t.text     "field_004",          limit: 65535
    t.text     "field_005",          limit: 65535
    t.text     "field_006",          limit: 65535
    t.text     "field_007",          limit: 65535
    t.text     "field_008",          limit: 65535
    t.text     "field_009",          limit: 65535
    t.text     "field_010",          limit: 65535
    t.text     "field_011",          limit: 65535
    t.text     "field_012",          limit: 65535
    t.text     "field_013",          limit: 65535
    t.text     "field_014",          limit: 65535
    t.text     "field_015",          limit: 65535
    t.text     "field_016",          limit: 65535
    t.text     "field_017",          limit: 65535
    t.text     "field_018",          limit: 65535
    t.text     "field_019",          limit: 65535
    t.text     "field_020",          limit: 65535
    t.text     "field_021",          limit: 65535
    t.text     "field_022",          limit: 65535
    t.text     "field_023",          limit: 65535
    t.text     "field_024",          limit: 65535
    t.text     "field_025",          limit: 65535
    t.text     "field_026",          limit: 65535
    t.text     "field_027",          limit: 65535
    t.text     "field_028",          limit: 65535
    t.text     "field_029",          limit: 65535
    t.text     "field_030",          limit: 65535
    t.text     "field_031",          limit: 65535
    t.text     "field_032",          limit: 65535
    t.text     "field_033",          limit: 65535
    t.text     "field_034",          limit: 65535
    t.text     "field_035",          limit: 65535
    t.text     "field_036",          limit: 65535
    t.text     "field_037",          limit: 65535
    t.text     "field_038",          limit: 65535
    t.text     "field_039",          limit: 65535
    t.text     "field_040",          limit: 65535
    t.text     "field_041",          limit: 65535
    t.text     "field_042",          limit: 65535
    t.text     "field_043",          limit: 65535
    t.text     "field_044",          limit: 65535
    t.text     "field_045",          limit: 65535
    t.text     "field_046",          limit: 65535
    t.text     "field_047",          limit: 65535
    t.text     "field_048",          limit: 65535
    t.text     "field_049",          limit: 65535
    t.text     "field_050",          limit: 65535
    t.text     "field_051",          limit: 65535
    t.text     "field_052",          limit: 65535
    t.text     "field_053",          limit: 65535
    t.text     "field_054",          limit: 65535
    t.text     "field_055",          limit: 65535
    t.text     "field_056",          limit: 65535
    t.text     "field_057",          limit: 65535
    t.text     "field_058",          limit: 65535
    t.text     "field_059",          limit: 65535
    t.text     "field_060",          limit: 65535
    t.text     "field_061",          limit: 65535
    t.text     "field_062",          limit: 65535
    t.text     "field_063",          limit: 65535
    t.text     "field_064",          limit: 65535
    t.text     "createdate",         limit: 65535
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
  end

  add_index "enquete_answers", ["user_code"], name: "user_code", using: :btree

  create_table "enquete_base_users", force: :cascade do |t|
    t.integer  "unid",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "base_user_code", limit: 255
    t.text     "base_user_name", limit: 65535
  end

  add_index "enquete_base_users", ["base_user_code"], name: "base_user_code", using: :btree

  create_table "enquete_view_questions", id: false, force: :cascade do |t|
    t.integer "base_user_code",      limit: 4, default: 0, null: false
    t.integer "id",                  limit: 4, default: 0, null: false
    t.integer "unid",                limit: 4, default: 0, null: false
    t.integer "include_index",       limit: 4, default: 0, null: false
    t.integer "content_id",          limit: 4, default: 0, null: false
    t.integer "state",               limit: 4, default: 0, null: false
    t.integer "created_at",          limit: 4, default: 0, null: false
    t.integer "updated_at",          limit: 4, default: 0, null: false
    t.integer "section_code",        limit: 4, default: 0, null: false
    t.integer "section_name",        limit: 4, default: 0, null: false
    t.integer "section_sort",        limit: 4, default: 0, null: false
    t.integer "enquete_division",    limit: 4, default: 0, null: false
    t.integer "manage_title",        limit: 4, default: 0, null: false
    t.integer "title",               limit: 4, default: 0, null: false
    t.integer "form_body",           limit: 4, default: 0, null: false
    t.integer "able_date",           limit: 4, default: 0, null: false
    t.integer "expiry_date",         limit: 4, default: 0, null: false
    t.integer "spec_config",         limit: 4, default: 0, null: false
    t.integer "send_change",         limit: 4, default: 0, null: false
    t.integer "createdate",          limit: 4, default: 0, null: false
    t.integer "createrdivision_id",  limit: 4, default: 0, null: false
    t.integer "createrdivision",     limit: 4, default: 0, null: false
    t.integer "creater_id",          limit: 4, default: 0, null: false
    t.integer "creater",             limit: 4, default: 0, null: false
    t.integer "editdate",            limit: 4, default: 0, null: false
    t.integer "editordivision_id",   limit: 4, default: 0, null: false
    t.integer "editordivision",      limit: 4, default: 0, null: false
    t.integer "editor_id",           limit: 4, default: 0, null: false
    t.integer "editor",              limit: 4, default: 0, null: false
    t.integer "custom_groups",       limit: 4, default: 0, null: false
    t.integer "custom_groups_json",  limit: 4, default: 0, null: false
    t.integer "reader_groups",       limit: 4, default: 0, null: false
    t.integer "reader_groups_json",  limit: 4, default: 0, null: false
    t.integer "custom_readers",      limit: 4, default: 0, null: false
    t.integer "custom_readers_json", limit: 4, default: 0, null: false
    t.integer "readers",             limit: 4, default: 0, null: false
    t.integer "readers_json",        limit: 4, default: 0, null: false
    t.integer "default_limit",       limit: 4, default: 0, null: false
  end

  create_table "gw_access_controls", force: :cascade do |t|
    t.string   "state",      limit: 255
    t.integer  "user_id",    limit: 4
    t.text     "path",       limit: 65535
    t.integer  "priority",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_access_controls", ["state", "user_id"], name: "index_gw_access_controls_on_state_and_user_id", using: :btree

  create_table "gw_admin_check_extensions", force: :cascade do |t|
    t.string   "state",       limit: 255
    t.integer  "sort_no",     limit: 4
    t.string   "extension",   limit: 255
    t.text     "remark",      limit: 65535
    t.datetime "deleted_at"
    t.integer  "deleted_uid", limit: 4
    t.integer  "deleted_gid", limit: 4
    t.datetime "updated_at"
    t.integer  "updated_uid", limit: 4
    t.integer  "updated_gid", limit: 4
    t.datetime "created_at"
    t.integer  "created_uid", limit: 4
    t.integer  "created_gid", limit: 4
  end

  create_table "gw_admin_messages", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body",       limit: 65535
    t.integer  "sort_no",    limit: 4
    t.integer  "state",      limit: 4
    t.integer  "mode",       limit: 4
  end

  create_table "gw_blog_parts", force: :cascade do |t|
    t.text     "state",         limit: 65535
    t.integer  "sort_no",       limit: 4
    t.text     "title",         limit: 65535
    t.text     "body",          limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "deleted_at"
    t.text     "deleted_user",  limit: 65535
    t.text     "deleted_group", limit: 65535
  end

  create_table "gw_circulars", force: :cascade do |t|
    t.integer  "state",       limit: 4
    t.integer  "uid",         limit: 4
    t.string   "u_code",      limit: 255
    t.integer  "gid",         limit: 4
    t.string   "g_code",      limit: 255
    t.integer  "class_id",    limit: 4
    t.text     "title",       limit: 65535
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished", limit: 4
    t.integer  "is_system",   limit: 4
    t.text     "options",     limit: 65535
    t.text     "body",        limit: 65535
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "gw_circulars", ["ed_at"], name: "ed_at", using: :btree
  add_index "gw_circulars", ["state"], name: "state", using: :btree
  add_index "gw_circulars", ["uid"], name: "uid", using: :btree

  create_table "gw_dcn_approvals", force: :cascade do |t|
    t.integer  "state",       limit: 4
    t.integer  "uid",         limit: 4
    t.string   "u_code",      limit: 255
    t.integer  "gid",         limit: 4
    t.string   "g_code",      limit: 255
    t.integer  "class_id",    limit: 4
    t.text     "title",       limit: 65535
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished", limit: 4
    t.integer  "is_system",   limit: 4
    t.text     "author",      limit: 65535
    t.text     "options",     limit: 65535
    t.text     "body",        limit: 65535
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "gw_edit_link_piece_csses", force: :cascade do |t|
    t.string   "state",         limit: 255
    t.string   "css_name",      limit: 255
    t.integer  "css_sort_no",   limit: 4,   default: 0
    t.string   "css_class",     limit: 255
    t.integer  "css_type",      limit: 4,   default: 1
    t.datetime "deleted_at"
    t.string   "deleted_user",  limit: 255
    t.string   "deleted_group", limit: 255
    t.datetime "updated_at"
    t.string   "updated_user",  limit: 255
    t.string   "updated_group", limit: 255
    t.datetime "created_at"
    t.string   "created_user",  limit: 255
    t.string   "created_group", limit: 255
  end

  create_table "gw_edit_link_pieces", force: :cascade do |t|
    t.integer  "uid",               limit: 4
    t.integer  "class_created",     limit: 4,     default: 0
    t.string   "published",         limit: 255
    t.string   "state",             limit: 255
    t.integer  "mode",              limit: 4
    t.integer  "level_no",          limit: 4,     default: 0
    t.integer  "parent_id",         limit: 4,     default: 0
    t.string   "name",              limit: 255
    t.integer  "sort_no",           limit: 4,     default: 0
    t.integer  "tab_keys",          limit: 4,     default: 0
    t.integer  "display_auth_priv", limit: 4
    t.integer  "role_name_id",      limit: 4
    t.text     "display_auth",      limit: 65535
    t.integer  "block_icon_id",     limit: 4
    t.integer  "block_css_id",      limit: 4
    t.text     "link_url",          limit: 65535
    t.text     "remark",            limit: 65535
    t.text     "icon_path",         limit: 65535
    t.string   "link_div_class",    limit: 255
    t.integer  "class_external",    limit: 4,     default: 0
    t.integer  "ssoid",             limit: 4
    t.string   "class_sso",         limit: 255,   default: "0"
    t.string   "field_account",     limit: 255
    t.string   "field_pass",        limit: 255
    t.integer  "css_id",            limit: 4,     default: 0
    t.datetime "deleted_at"
    t.string   "deleted_user",      limit: 255
    t.string   "deleted_group",     limit: 255
    t.datetime "updated_at"
    t.string   "updated_user",      limit: 255
    t.string   "updated_group",     limit: 255
    t.datetime "created_at"
    t.string   "created_user",      limit: 255
    t.string   "created_group",     limit: 255
  end

  add_index "gw_edit_link_pieces", ["published", "state", "sort_no"], name: "idx_gw_edit_link_pieces", using: :btree

  create_table "gw_edit_tab_public_roles", force: :cascade do |t|
    t.integer  "edit_tab_id", limit: 4
    t.integer  "class_id",    limit: 4
    t.integer  "uid",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_edit_tabs", force: :cascade do |t|
    t.integer  "class_created",        limit: 4,     default: 0
    t.string   "published",            limit: 255
    t.string   "state",                limit: 255
    t.integer  "level_no",             limit: 4,     default: 0
    t.integer  "parent_id",            limit: 4,     default: 0
    t.string   "name",                 limit: 255
    t.integer  "sort_no",              limit: 4,     default: 0
    t.integer  "tab_keys",             limit: 4,     default: 0
    t.text     "display_auth",         limit: 65535
    t.string   "other_controller_use", limit: 255,   default: "2"
    t.string   "other_controller_url", limit: 255
    t.text     "link_url",             limit: 65535
    t.text     "icon_path",            limit: 65535
    t.string   "link_div_class",       limit: 255
    t.integer  "class_external",       limit: 4,     default: 0
    t.string   "class_sso",            limit: 255,   default: "0"
    t.string   "field_account",        limit: 255
    t.string   "field_pass",           limit: 255
    t.integer  "css_id",               limit: 4,     default: 0
    t.integer  "is_public",            limit: 4
    t.datetime "deleted_at"
    t.string   "deleted_user",         limit: 255
    t.string   "deleted_group",        limit: 255
    t.datetime "updated_at"
    t.string   "updated_user",         limit: 255
    t.string   "updated_group",        limit: 255
    t.datetime "created_at"
    t.string   "created_user",         limit: 255
    t.string   "created_group",        limit: 255
  end

  create_table "gw_holidays", force: :cascade do |t|
    t.integer  "creator_uid",        limit: 4
    t.string   "creator_ucode",      limit: 255
    t.text     "creator_uname",      limit: 65535
    t.integer  "creator_gid",        limit: 4
    t.string   "creator_gcode",      limit: 255
    t.text     "creator_gname",      limit: 65535
    t.integer  "title_category_id",  limit: 4
    t.string   "title",              limit: 255
    t.integer  "is_public",          limit: 4
    t.text     "memo",               limit: 65535
    t.integer  "schedule_repeat_id", limit: 4
    t.integer  "dirty_repeat_id",    limit: 4
    t.integer  "no_time_id",         limit: 4
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_holidays", ["st_at", "ed_at"], name: "st_at", using: :btree

  create_table "gw_icon_groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_icons", force: :cascade do |t|
    t.integer  "icon_gid",     limit: 4
    t.integer  "idx",          limit: 4
    t.string   "title",        limit: 255
    t.string   "path",         limit: 255
    t.string   "content_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_ind_portal_pieces", force: :cascade do |t|
    t.integer  "uid",        limit: 4
    t.integer  "sort_no",    limit: 4
    t.text     "name",       limit: 65535, null: false
    t.text     "title",      limit: 65535
    t.text     "piece",      limit: 65535
    t.text     "genre",      limit: 65535
    t.integer  "tid",        limit: 4
    t.integer  "limit",      limit: 4
    t.text     "position",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_infos", force: :cascade do |t|
    t.string   "cls",        limit: 255
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_meeting_access_logs", force: :cascade do |t|
    t.text     "ip_address", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_meeting_guide_backgrounds", force: :cascade do |t|
    t.string   "published",          limit: 255
    t.string   "state",              limit: 255
    t.integer  "area",               limit: 4
    t.integer  "sort_no",            limit: 4
    t.text     "file_path",          limit: 65535
    t.text     "file_directory",     limit: 65535
    t.text     "file_name",          limit: 65535
    t.text     "original_file_name", limit: 65535
    t.string   "content_type",       limit: 255
    t.integer  "width",              limit: 4
    t.integer  "height",             limit: 4
    t.string   "background_color",   limit: 255
    t.text     "caption",            limit: 65535
    t.datetime "deleted_at"
    t.integer  "deleted_uid",        limit: 4
    t.integer  "deleted_gid",        limit: 4
    t.datetime "updated_at"
    t.integer  "updated_uid",        limit: 4
    t.integer  "updated_gid",        limit: 4
    t.datetime "created_at"
    t.integer  "created_uid",        limit: 4
    t.integer  "created_gid",        limit: 4
  end

  create_table "gw_meeting_guide_notices", force: :cascade do |t|
    t.string   "published",   limit: 255
    t.string   "state",       limit: 255
    t.integer  "sort_no",     limit: 4
    t.text     "title",       limit: 65535
    t.datetime "deleted_at"
    t.integer  "deleted_uid", limit: 4
    t.integer  "deleted_gid", limit: 4
    t.datetime "updated_at"
    t.integer  "updated_uid", limit: 4
    t.integer  "updated_gid", limit: 4
    t.datetime "created_at"
    t.integer  "created_uid", limit: 4
    t.integer  "created_gid", limit: 4
  end

  create_table "gw_meeting_guide_places", force: :cascade do |t|
    t.text     "state",        limit: 65535
    t.integer  "sort_no",      limit: 4
    t.text     "place",        limit: 65535
    t.text     "place_master", limit: 65535
    t.integer  "place_type",   limit: 4
    t.integer  "prop_id",      limit: 4
    t.datetime "deleted_at"
    t.integer  "deleted_uid",  limit: 4
    t.integer  "deleted_gid",  limit: 4
    t.datetime "updated_at"
    t.integer  "updated_uid",  limit: 4
    t.integer  "updated_gid",  limit: 4
    t.datetime "created_at"
    t.integer  "created_uid",  limit: 4
    t.integer  "created_gid",  limit: 4
  end

  create_table "gw_meeting_monitor_managers", force: :cascade do |t|
    t.integer  "manager_group_id",  limit: 4
    t.integer  "manager_user_id",   limit: 4
    t.text     "manager_user_addr", limit: 65535
    t.text     "state",             limit: 65535
    t.text     "created_user",      limit: 65535
    t.text     "updated_user",      limit: 65535
    t.text     "deleted_user",      limit: 65535
    t.text     "created_group",     limit: 65535
    t.text     "updated_group",     limit: 65535
    t.text     "deleted_group",     limit: 65535
    t.datetime "deleted_at"
    t.integer  "deleted_uid",       limit: 4
    t.integer  "deleted_gid",       limit: 4
    t.datetime "updated_at"
    t.integer  "updated_uid",       limit: 4
    t.integer  "updated_gid",       limit: 4
    t.datetime "created_at"
    t.integer  "created_uid",       limit: 4
    t.integer  "created_gid",       limit: 4
  end

  create_table "gw_meeting_monitor_settings", force: :cascade do |t|
    t.text     "state",          limit: 65535
    t.text     "mail_from",      limit: 65535
    t.text     "mail_title",     limit: 65535
    t.text     "mail_body",      limit: 65535
    t.text     "notice_body",    limit: 65535
    t.text     "conditions",     limit: 65535
    t.text     "weekday_notice", limit: 65535
    t.text     "holiday_notice", limit: 65535
    t.integer  "monitor_type",   limit: 4
    t.text     "name",           limit: 65535
    t.text     "ip_address",     limit: 65535
    t.text     "created_user",   limit: 65535
    t.text     "updated_user",   limit: 65535
    t.text     "deleted_user",   limit: 65535
    t.text     "created_group",  limit: 65535
    t.text     "updated_group",  limit: 65535
    t.text     "deleted_group",  limit: 65535
    t.datetime "deleted_at"
    t.integer  "deleted_uid",    limit: 4
    t.integer  "deleted_gid",    limit: 4
    t.datetime "updated_at"
    t.integer  "updated_uid",    limit: 4
    t.integer  "updated_gid",    limit: 4
    t.datetime "created_at"
    t.integer  "created_uid",    limit: 4
    t.integer  "created_gid",    limit: 4
  end

  create_table "gw_memo_mobiles", force: :cascade do |t|
    t.string   "domain",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_memo_users", force: :cascade do |t|
    t.integer  "schedule_id", limit: 4
    t.integer  "class_id",    limit: 4
    t.integer  "uid",         limit: 4
    t.string   "ucode",       limit: 255
    t.string   "uname",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_memo_users", ["schedule_id"], name: "index_gw_memo_users_on_schedule_id", using: :btree

  create_table "gw_memos", force: :cascade do |t|
    t.integer  "class_id",           limit: 4
    t.integer  "uid",                limit: 4
    t.string   "ucode",              limit: 255
    t.string   "uname",              limit: 255
    t.string   "title",              limit: 255
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished",        limit: 4,     default: 0
    t.integer  "is_system",          limit: 4
    t.string   "fr_group",           limit: 255
    t.string   "fr_user",            limit: 255
    t.integer  "memo_category_id",   limit: 4
    t.string   "memo_category_text", limit: 255
    t.text     "body",               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_monitor_reminders", force: :cascade do |t|
    t.integer  "state",       limit: 4
    t.integer  "uid",         limit: 4
    t.string   "u_code",      limit: 255
    t.integer  "gid",         limit: 4
    t.string   "g_code",      limit: 255
    t.integer  "class_id",    limit: 4
    t.text     "title",       limit: 65535
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished", limit: 4
    t.integer  "is_system",   limit: 4
    t.text     "options",     limit: 65535
    t.text     "body",        limit: 65535
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "gw_monitor_reminders", ["ed_at"], name: "ed_at", using: :btree
  add_index "gw_monitor_reminders", ["state"], name: "state", using: :btree
  add_index "gw_monitor_reminders", ["uid"], name: "uid", using: :btree

  create_table "gw_notes", force: :cascade do |t|
    t.integer  "uid",        limit: 4
    t.integer  "position",   limit: 4
    t.string   "title",      limit: 255
    t.text     "body",       limit: 65535
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_plus_updates", force: :cascade do |t|
    t.string   "doc_id",             limit: 255
    t.string   "post_id",            limit: 255
    t.string   "state",              limit: 255
    t.text     "project_users",      limit: 65535
    t.text     "project_users_json", limit: 65535
    t.string   "project_id",         limit: 255
    t.string   "project_code",       limit: 255
    t.integer  "class_id",           limit: 4
    t.text     "title",              limit: 65535
    t.datetime "doc_updated_at"
    t.text     "author",             limit: 65535
    t.text     "project_url",        limit: 65535
    t.text     "body",               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_portal_ad_daily_accesses", force: :cascade do |t|
    t.text     "state",       limit: 65535
    t.integer  "ad_id",       limit: 4
    t.text     "content",     limit: 65535
    t.integer  "click_count", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "accessed_at"
  end

  create_table "gw_portal_add_access_logs", force: :cascade do |t|
    t.integer  "add_id",      limit: 4
    t.datetime "accessed_at"
    t.string   "ipaddr",      limit: 255
    t.text     "user_agent",  limit: 65535
    t.text     "referer",     limit: 65535
    t.text     "path",        limit: 65535
    t.text     "content",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_portal_add_access_logs", ["add_id", "accessed_at"], name: "index_gw_portal_add_access_logs_on_add_id_and_accessed_at", using: :btree

  create_table "gw_portal_add_patterns", force: :cascade do |t|
    t.integer  "pattern",       limit: 4
    t.integer  "place",         limit: 4
    t.text     "state",         limit: 65535
    t.integer  "add_id",        limit: 4
    t.integer  "sort_no",       limit: 4
    t.integer  "group_id",      limit: 4
    t.text     "title",         limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
  end

  create_table "gw_portal_adds", force: :cascade do |t|
    t.text     "state",              limit: 65535
    t.text     "published",          limit: 65535
    t.text     "file_path",          limit: 65535
    t.text     "file_directory",     limit: 65535
    t.text     "file_name",          limit: 65535
    t.text     "original_file_name", limit: 65535
    t.text     "content_type",       limit: 65535
    t.integer  "width",              limit: 4
    t.integer  "height",             limit: 4
    t.integer  "place",              limit: 4
    t.integer  "sort_no",            limit: 4
    t.text     "title",              limit: 65535
    t.text     "body",               limit: 65535
    t.text     "url",                limit: 65535
    t.datetime "publish_start_at"
    t.datetime "publish_end_at"
    t.integer  "class_external",     limit: 4
    t.string   "class_sso",          limit: 255
    t.string   "field_account",      limit: 255
    t.string   "field_pass",         limit: 255
    t.datetime "created_at"
    t.text     "created_user",       limit: 65535
    t.text     "created_group",      limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",       limit: 65535
    t.text     "updated_group",      limit: 65535
    t.datetime "deleted_at"
    t.text     "deleted_user",       limit: 65535
    t.text     "deleted_group",      limit: 65535
    t.integer  "click_count",        limit: 4,     default: 0, null: false
    t.integer  "is_large",           limit: 4
  end

  create_table "gw_portal_user_settings", force: :cascade do |t|
    t.integer  "uid",        limit: 4
    t.integer  "idx",        limit: 4
    t.string   "arrange",    limit: 255
    t.string   "title",      limit: 255
    t.string   "gadget",     limit: 255
    t.string   "options",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_pref_assembly_members", force: :cascade do |t|
    t.integer  "gid",           limit: 4
    t.string   "g_code",        limit: 255
    t.string   "g_name",        limit: 255
    t.integer  "g_order",       limit: 4
    t.integer  "uid",           limit: 4
    t.string   "u_code",        limit: 255
    t.text     "u_lname",       limit: 65535
    t.text     "u_name",        limit: 65535
    t.integer  "u_order",       limit: 4
    t.text     "title",         limit: 65535
    t.string   "state",         limit: 255
    t.datetime "deleted_at"
    t.string   "deleted_user",  limit: 255
    t.string   "deleted_group", limit: 255
    t.datetime "updated_at"
    t.string   "updated_user",  limit: 255
    t.string   "updated_group", limit: 255
    t.datetime "created_at"
    t.string   "created_user",  limit: 255
    t.string   "created_group", limit: 255
  end

  create_table "gw_pref_configs", force: :cascade do |t|
    t.text     "state",         limit: 65535
    t.text     "option_type",   limit: 65535
    t.text     "name",          limit: 65535
    t.text     "options",       limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
  end

  create_table "gw_pref_director_temps", force: :cascade do |t|
    t.integer  "parent_gid",         limit: 4
    t.string   "parent_g_code",      limit: 255
    t.string   "parent_g_name",      limit: 255
    t.integer  "parent_g_order",     limit: 4
    t.integer  "gid",                limit: 4
    t.string   "g_code",             limit: 255
    t.string   "g_name",             limit: 255
    t.integer  "g_order",            limit: 4
    t.integer  "uid",                limit: 4
    t.string   "u_code",             limit: 255
    t.text     "u_lname",            limit: 65535
    t.text     "u_name",             limit: 65535
    t.integer  "u_order",            limit: 4
    t.text     "title",              limit: 65535
    t.string   "state",              limit: 255
    t.datetime "deleted_at"
    t.string   "deleted_user",       limit: 255
    t.string   "deleted_group",      limit: 255
    t.datetime "updated_at"
    t.string   "updated_user",       limit: 255
    t.string   "updated_group",      limit: 255
    t.datetime "created_at"
    t.string   "created_user",       limit: 255
    t.string   "created_group",      limit: 255
    t.integer  "is_governor_view",   limit: 4
    t.integer  "display_parent_gid", limit: 4
    t.string   "version",            limit: 255
  end

  create_table "gw_pref_directors", force: :cascade do |t|
    t.integer  "parent_gid",         limit: 4
    t.string   "parent_g_code",      limit: 255
    t.string   "parent_g_name",      limit: 255
    t.integer  "parent_g_order",     limit: 4
    t.integer  "gid",                limit: 4
    t.string   "g_code",             limit: 255
    t.string   "g_name",             limit: 255
    t.integer  "g_order",            limit: 4
    t.integer  "uid",                limit: 4
    t.string   "u_code",             limit: 255
    t.text     "u_lname",            limit: 65535
    t.text     "u_name",             limit: 65535
    t.integer  "u_order",            limit: 4
    t.text     "title",              limit: 65535
    t.string   "state",              limit: 255
    t.datetime "deleted_at"
    t.string   "deleted_user",       limit: 255
    t.string   "deleted_group",      limit: 255
    t.datetime "updated_at"
    t.string   "updated_user",       limit: 255
    t.string   "updated_group",      limit: 255
    t.datetime "created_at"
    t.string   "created_user",       limit: 255
    t.string   "created_group",      limit: 255
    t.integer  "is_governor_view",   limit: 4
    t.integer  "display_parent_gid", limit: 4
    t.string   "version",            limit: 255
  end

  create_table "gw_pref_executives", force: :cascade do |t|
    t.integer  "parent_gid",       limit: 4
    t.string   "parent_g_code",    limit: 255
    t.string   "parent_g_name",    limit: 255
    t.integer  "parent_g_order",   limit: 4
    t.integer  "gid",              limit: 4
    t.string   "g_code",           limit: 255
    t.string   "g_name",           limit: 255
    t.integer  "g_order",          limit: 4
    t.integer  "uid",              limit: 4
    t.string   "u_code",           limit: 255
    t.text     "u_lname",          limit: 65535
    t.text     "u_name",           limit: 65535
    t.integer  "u_order",          limit: 4
    t.text     "title",            limit: 65535
    t.string   "state",            limit: 255
    t.datetime "deleted_at"
    t.string   "deleted_user",     limit: 255
    t.string   "deleted_group",    limit: 255
    t.datetime "updated_at"
    t.string   "updated_user",     limit: 255
    t.string   "updated_group",    limit: 255
    t.datetime "created_at"
    t.string   "created_user",     limit: 255
    t.string   "created_group",    limit: 255
    t.integer  "is_other_view",    limit: 4
    t.integer  "is_governor_view", limit: 4
  end

  create_table "gw_pref_soumu_messages", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body",       limit: 65535
    t.integer  "sort_no",    limit: 4
    t.integer  "state",      limit: 4
    t.integer  "tab_keys",   limit: 4
  end

  create_table "gw_prop_extra_pm_meetingroom_actuals", force: :cascade do |t|
    t.integer  "schedule_id",       limit: 4
    t.integer  "schedule_prop_id",  limit: 4
    t.integer  "car_id",            limit: 4
    t.integer  "driver_user_id",    limit: 4
    t.string   "driver_user_code",  limit: 255
    t.string   "driver_user_name",  limit: 255
    t.integer  "driver_group_id",   limit: 4
    t.string   "driver_group_code", limit: 255
    t.string   "driver_group_name", limit: 255
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "start_meter",       limit: 4
    t.integer  "end_meter",         limit: 4
    t.integer  "run_meter",         limit: 4
    t.text     "summaries_state",   limit: 65535
    t.text     "bill_state",        limit: 65535
    t.integer  "toll_fee",          limit: 4
    t.integer  "refuel_amount",     limit: 4
    t.text     "to_go",             limit: 65535
    t.text     "title",             limit: 65535
    t.text     "updated_user",      limit: 65535
    t.text     "updated_group",     limit: 65535
    t.text     "created_user",      limit: 65535
    t.text     "created_group",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_prop_extra_pm_meetingroom_actuals", ["car_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_car_id", using: :btree
  add_index "gw_prop_extra_pm_meetingroom_actuals", ["driver_group_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_driver_group_id", using: :btree
  add_index "gw_prop_extra_pm_meetingroom_actuals", ["driver_user_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_driver_user_id", using: :btree
  add_index "gw_prop_extra_pm_meetingroom_actuals", ["schedule_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_schedule_id", using: :btree
  add_index "gw_prop_extra_pm_meetingroom_actuals", ["schedule_prop_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_schedule_prop_id", using: :btree

  create_table "gw_prop_extra_pm_meetingroom_csvput_histories", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "created_at"
  end

  create_table "gw_prop_extra_pm_meetingroom_summaries", force: :cascade do |t|
    t.datetime "summaries_at"
    t.integer  "group_id",      limit: 4
    t.integer  "run_meter",     limit: 4
    t.integer  "bill_amount",   limit: 4
    t.text     "bill_state",    limit: 65535
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_meetingroom_summarize_histories", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_messages", force: :cascade do |t|
    t.text     "body",          limit: 65535
    t.integer  "sort_no",       limit: 4
    t.integer  "state",         limit: 4
    t.integer  "prop_class_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_remarks", force: :cascade do |t|
    t.integer  "prop_class_id", limit: 4
    t.string   "state",         limit: 255
    t.integer  "sort_no",       limit: 4
    t.string   "title",         limit: 255
    t.string   "url",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_renewal_groups", force: :cascade do |t|
    t.integer  "present_group_id",    limit: 4
    t.string   "present_group_code",  limit: 255
    t.integer  "incoming_group_id",   limit: 4
    t.text     "incoming_group_name", limit: 65535
    t.datetime "modified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "present_group_name",  limit: 65535
    t.string   "incoming_group_code", limit: 255
  end

  create_table "gw_prop_extra_pm_rentcar_actuals", force: :cascade do |t|
    t.integer  "schedule_id",       limit: 4
    t.integer  "schedule_prop_id",  limit: 4
    t.integer  "car_id",            limit: 4
    t.integer  "driver_user_id",    limit: 4
    t.string   "driver_user_code",  limit: 255
    t.string   "driver_user_name",  limit: 255
    t.integer  "driver_group_id",   limit: 4
    t.string   "driver_group_code", limit: 255
    t.string   "driver_group_name", limit: 255
    t.text     "user_uname",        limit: 65535
    t.text     "user_gname",        limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "start_meter",       limit: 4
    t.integer  "end_meter",         limit: 4
    t.integer  "run_meter",         limit: 4
    t.text     "summaries_state",   limit: 65535
    t.text     "bill_state",        limit: 65535
    t.integer  "toll_fee",          limit: 4
    t.integer  "refuel_amount",     limit: 4
    t.text     "to_go",             limit: 65535
    t.text     "title",             limit: 65535
    t.text     "updated_user",      limit: 65535
    t.text     "updated_group",     limit: 65535
    t.text     "created_user",      limit: 65535
    t.text     "created_group",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_prop_extra_pm_rentcar_actuals", ["car_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_car_id", using: :btree
  add_index "gw_prop_extra_pm_rentcar_actuals", ["driver_group_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_driver_group_id", using: :btree
  add_index "gw_prop_extra_pm_rentcar_actuals", ["driver_user_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_driver_user_id", using: :btree
  add_index "gw_prop_extra_pm_rentcar_actuals", ["schedule_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_schedule_id", using: :btree
  add_index "gw_prop_extra_pm_rentcar_actuals", ["schedule_prop_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_schedule_prop_id", using: :btree

  create_table "gw_prop_extra_pm_rentcar_csvput_histories", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_rentcar_summaries", force: :cascade do |t|
    t.datetime "summaries_at"
    t.integer  "group_id",      limit: 4
    t.integer  "run_meter",     limit: 4
    t.integer  "bill_amount",   limit: 4
    t.text     "bill_state",    limit: 65535
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_rentcar_summarize_histories", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_rentcar_unit_prices", force: :cascade do |t|
    t.integer  "unit_price",    limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_meetingroom_images", force: :cascade do |t|
    t.integer  "parent_id",     limit: 4
    t.integer  "idx",           limit: 4
    t.string   "note",          limit: 255
    t.string   "path",          limit: 255
    t.string   "orig_filename", limit: 255
    t.string   "content_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_meetingrooms", force: :cascade do |t|
    t.integer  "sort_no",        limit: 4
    t.integer  "type_id",        limit: 4
    t.integer  "delete_state",   limit: 4
    t.integer  "reserved_state", limit: 4
    t.string   "name",           limit: 255
    t.string   "position",       limit: 255
    t.string   "tel",            limit: 255
    t.integer  "max_person",     limit: 4
    t.integer  "max_tables",     limit: 4
    t.integer  "max_chairs",     limit: 4
    t.string   "note",           limit: 255
    t.string   "extra_flag",     limit: 255
    t.text     "extra_data",     limit: 65535
    t.string   "gid",            limit: 255
    t.string   "gname",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_images", force: :cascade do |t|
    t.integer  "parent_id",     limit: 4
    t.integer  "idx",           limit: 4
    t.string   "note",          limit: 255
    t.string   "path",          limit: 255
    t.string   "orig_filename", limit: 255
    t.string   "content_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_limits", force: :cascade do |t|
    t.integer  "sort_no",    limit: 4
    t.string   "state",      limit: 255
    t.integer  "gid",        limit: 4
    t.integer  "limit",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_roles", force: :cascade do |t|
    t.integer  "prop_id",    limit: 4
    t.integer  "gid",        limit: 4
    t.string   "auth",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_prop_other_roles", ["prop_id"], name: "prop_id", using: :btree

  create_table "gw_prop_others", force: :cascade do |t|
    t.integer  "sort_no",        limit: 4
    t.string   "name",           limit: 255
    t.integer  "type_id",        limit: 4
    t.text     "state",          limit: 65535
    t.integer  "edit_state",     limit: 4
    t.integer  "delete_state",   limit: 4,     default: 0
    t.integer  "reserved_state", limit: 4,     default: 1
    t.text     "comment",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "extra_flag",     limit: 255
    t.text     "extra_data",     limit: 65535
    t.integer  "gid",            limit: 4
    t.string   "gname",          limit: 255
    t.integer  "creator_uid",    limit: 4
    t.integer  "updater_uid",    limit: 4
  end

  create_table "gw_prop_rentcar_images", force: :cascade do |t|
    t.integer  "parent_id",     limit: 4
    t.integer  "idx",           limit: 4
    t.string   "note",          limit: 255
    t.string   "path",          limit: 255
    t.string   "orig_filename", limit: 255
    t.string   "content_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_rentcar_meters", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.integer  "travelled_km", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_rentcars", force: :cascade do |t|
    t.integer  "sort_no",        limit: 4
    t.string   "car_model",      limit: 255
    t.string   "name",           limit: 255
    t.integer  "type_id",        limit: 4
    t.integer  "delete_state",   limit: 4
    t.integer  "reserved_state", limit: 4
    t.string   "register_no",    limit: 255
    t.string   "exhaust",        limit: 255
    t.integer  "year_type",      limit: 4
    t.text     "comment",        limit: 65535
    t.string   "extra_flag",     limit: 255
    t.text     "extra_data",     limit: 65535
    t.string   "gid",            limit: 255
    t.string   "gname",          limit: 255
    t.integer  "travelled_km",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_types", force: :cascade do |t|
    t.string   "state",      limit: 255
    t.string   "name",       limit: 255
    t.integer  "sort_no",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "restricted", limit: 4
    t.text     "user_str",   limit: 65535
  end

  create_table "gw_prop_types_messages", force: :cascade do |t|
    t.integer  "state",      limit: 4
    t.integer  "sort_no",    limit: 4
    t.text     "body",       limit: 65535
    t.integer  "type_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_types_users", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.text     "user_name",  limit: 65535
    t.integer  "type_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_reminder_external_systems", force: :cascade do |t|
    t.string   "code",           limit: 255
    t.string   "name",           limit: 255
    t.string   "user_id",        limit: 255
    t.string   "password",       limit: 255
    t.string   "sso_user_field", limit: 255
    t.string   "sso_pass_field", limit: 255
    t.string   "css_name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_reminder_externals", force: :cascade do |t|
    t.text     "system",      limit: 65535
    t.text     "data_id",     limit: 65535
    t.text     "title",       limit: 65535
    t.datetime "updated"
    t.text     "link",        limit: 65535
    t.text     "author",      limit: 65535
    t.text     "contributor", limit: 65535
    t.text     "member",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "gw_reminders", force: :cascade do |t|
    t.string   "state",         limit: 255
    t.integer  "sort_no",       limit: 4
    t.text     "title",         limit: 65535
    t.text     "name",          limit: 65535
    t.string   "css_name",      limit: 255
    t.datetime "deleted_at"
    t.text     "deleted_user",  limit: 65535
    t.text     "deleted_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  add_index "gw_reminders", ["state"], name: "index_gw_reminders_on_state", using: :btree

  create_table "gw_rss_caches", force: :cascade do |t|
    t.text     "uri",        limit: 65535
    t.datetime "fetched"
    t.text     "title",      limit: 65535
    t.datetime "published"
    t.text     "link",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_rss_reader_caches", force: :cascade do |t|
    t.integer  "rrid",         limit: 4
    t.text     "uri",          limit: 65535
    t.text     "title",        limit: 65535
    t.text     "link",         limit: 65535
    t.datetime "fetched_at"
    t.datetime "published_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "gw_rss_readers", force: :cascade do |t|
    t.text     "state",         limit: 65535
    t.integer  "sort_no",       limit: 4
    t.text     "title",         limit: 65535
    t.text     "uri",           limit: 65535
    t.integer  "max",           limit: 4
    t.integer  "interval",      limit: 4
    t.datetime "checked_at"
    t.datetime "fetched_at"
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "deleted_at"
    t.text     "deleted_user",  limit: 65535
    t.text     "deleted_group", limit: 65535
  end

  create_table "gw_schedule_event_masters", force: :cascade do |t|
    t.integer  "edit_auth",             limit: 4
    t.integer  "management_parent_gid", limit: 4
    t.integer  "management_gid",        limit: 4
    t.integer  "management_uid",        limit: 4
    t.integer  "range_class_id",        limit: 4
    t.integer  "division_parent_gid",   limit: 4
    t.integer  "division_gid",          limit: 4
    t.integer  "creator_uid",           limit: 4
    t.integer  "creator_gid",           limit: 4
    t.integer  "updator_uid",           limit: 4
    t.integer  "updator_gid",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_schedule_events", force: :cascade do |t|
    t.integer  "schedule_id",          limit: 4
    t.integer  "gid",                  limit: 4
    t.string   "gcode",                limit: 255
    t.string   "gname",                limit: 255
    t.integer  "parent_gid",           limit: 4
    t.string   "parent_gcode",         limit: 255
    t.string   "parent_gname",         limit: 255
    t.integer  "uid",                  limit: 4
    t.string   "ucode",                limit: 255
    t.string   "uname",                limit: 255
    t.integer  "sort_id",              limit: 4
    t.string   "title",                limit: 255
    t.text     "event_word",           limit: 65535
    t.string   "place",                limit: 255
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "event_week",           limit: 4
    t.integer  "week_approval",        limit: 4
    t.datetime "week_approved_at"
    t.integer  "week_approval_uid",    limit: 4
    t.string   "week_approval_ucode",  limit: 255
    t.string   "week_approval_uname",  limit: 255
    t.integer  "week_approval_gid",    limit: 4
    t.string   "week_approval_gcode",  limit: 255
    t.string   "week_approval_gname",  limit: 255
    t.integer  "week_open",            limit: 4
    t.datetime "week_opened_at"
    t.integer  "week_open_uid",        limit: 4
    t.string   "week_open_ucode",      limit: 255
    t.string   "week_open_uname",      limit: 255
    t.integer  "week_open_gid",        limit: 4
    t.string   "week_open_gcode",      limit: 255
    t.string   "week_open_gname",      limit: 255
    t.integer  "event_month",          limit: 4
    t.integer  "month_approval",       limit: 4
    t.datetime "month_approved_at"
    t.integer  "month_approval_uid",   limit: 4
    t.string   "month_approval_ucode", limit: 255
    t.string   "month_approval_uname", limit: 255
    t.integer  "month_approval_gid",   limit: 4
    t.string   "month_approval_gcode", limit: 255
    t.string   "month_approval_gname", limit: 255
    t.integer  "month_open",           limit: 4
    t.datetime "month_opened_at"
    t.integer  "month_open_uid",       limit: 4
    t.string   "month_open_ucode",     limit: 255
    t.string   "month_open_uname",     limit: 255
    t.integer  "month_open_gid",       limit: 4
    t.string   "month_open_gcode",     limit: 255
    t.string   "month_open_gname",     limit: 255
    t.integer  "allday",               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_schedule_events", ["schedule_id"], name: "index_gw_schedule_events_on_schedule_id", using: :btree

  create_table "gw_schedule_options", force: :cascade do |t|
    t.integer  "schedule_id", limit: 4
    t.string   "kind",        limit: 50
    t.text     "body",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_schedule_prop_temporaries", force: :cascade do |t|
    t.string   "tmp_id",        limit: 255
    t.string   "prop_type",     limit: 255
    t.integer  "prop_id",       limit: 4
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "deleted_at"
    t.text     "deleted_user",  limit: 65535
    t.text     "deleted_group", limit: 65535
  end

  create_table "gw_schedule_props", force: :cascade do |t|
    t.integer  "schedule_id",   limit: 4
    t.string   "prop_type",     limit: 255
    t.integer  "prop_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "extra_data",    limit: 65535
    t.integer  "confirmed_uid", limit: 4
    t.integer  "confirmed_gid", limit: 4
    t.datetime "confirmed_at"
    t.integer  "rented_uid",    limit: 4
    t.integer  "rented_gid",    limit: 4
    t.datetime "rented_at"
    t.integer  "returned_uid",  limit: 4
    t.integer  "returned_gid",  limit: 4
    t.datetime "returned_at"
    t.integer  "cancelled_uid", limit: 4
    t.integer  "cancelled_gid", limit: 4
    t.datetime "cancelled_at"
    t.datetime "st_at"
    t.datetime "ed_at"
  end

  add_index "gw_schedule_props", ["prop_id", "prop_type"], name: "index_gw_schedule_props_on_prop_id_and_prop_type", using: :btree
  add_index "gw_schedule_props", ["prop_id"], name: "prop_id", using: :btree
  add_index "gw_schedule_props", ["prop_type"], name: "index_gw_schedule_props_on_prop_type", using: :btree
  add_index "gw_schedule_props", ["schedule_id", "prop_type", "prop_id"], name: "schedule_id", using: :btree
  add_index "gw_schedule_props", ["schedule_id"], name: "index_gw_schedule_props_on_schedule_id", using: :btree

  create_table "gw_schedule_public_roles", force: :cascade do |t|
    t.integer  "schedule_id", limit: 4
    t.integer  "class_id",    limit: 4
    t.integer  "uid",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_schedule_public_roles", ["schedule_id"], name: "index_gw_schedule_public_roles_on_schedule_id", using: :btree

  create_table "gw_schedule_repeats", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "st_date_at"
    t.datetime "ed_date_at"
    t.datetime "st_time_at"
    t.datetime "ed_time_at"
    t.integer  "class_id",    limit: 4
    t.string   "weekday_ids", limit: 255
  end

  create_table "gw_schedule_todos", force: :cascade do |t|
    t.integer  "schedule_id",           limit: 4
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "todo_ed_at_indefinite", limit: 4, default: 0, null: false
    t.integer  "is_finished",           limit: 4, default: 0
    t.integer  "todo_st_at_id",         limit: 4, default: 0
    t.integer  "todo_ed_at_id",         limit: 4, default: 0
    t.integer  "todo_repeat_time_id",   limit: 4, default: 0
    t.datetime "finished_at"
    t.integer  "finished_uid",          limit: 4
    t.integer  "finished_gid",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "todo_id",               limit: 4
  end

  add_index "gw_schedule_todos", ["schedule_id"], name: "index_gw_schedule_todos_on_schedule_id", using: :btree

  create_table "gw_schedule_users", force: :cascade do |t|
    t.integer  "schedule_id", limit: 4
    t.integer  "class_id",    limit: 4
    t.integer  "uid",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "st_at"
    t.datetime "ed_at"
  end

  add_index "gw_schedule_users", ["schedule_id", "class_id", "uid"], name: "schedule_id", using: :btree
  add_index "gw_schedule_users", ["schedule_id"], name: "schedule_id2", using: :btree
  add_index "gw_schedule_users", ["uid"], name: "uid", using: :btree

  create_table "gw_schedules", force: :cascade do |t|
    t.integer  "creator_uid",            limit: 4
    t.string   "creator_ucode",          limit: 255
    t.text     "creator_uname",          limit: 65535
    t.integer  "creator_gid",            limit: 4
    t.string   "creator_gcode",          limit: 255
    t.text     "creator_gname",          limit: 65535
    t.integer  "updater_uid",            limit: 4
    t.string   "updater_ucode",          limit: 255
    t.text     "updater_uname",          limit: 65535
    t.integer  "updater_gid",            limit: 4
    t.string   "updater_gcode",          limit: 255
    t.text     "updater_gname",          limit: 65535
    t.integer  "owner_uid",              limit: 4
    t.string   "owner_ucode",            limit: 255
    t.text     "owner_uname",            limit: 65535
    t.integer  "owner_gid",              limit: 4
    t.string   "owner_gcode",            limit: 255
    t.text     "owner_gname",            limit: 65535
    t.integer  "title_category_id",      limit: 4
    t.string   "title",                  limit: 255
    t.integer  "place_category_id",      limit: 4
    t.string   "place",                  limit: 255
    t.integer  "to_go",                  limit: 4
    t.integer  "is_public",              limit: 4
    t.integer  "is_pr",                  limit: 4
    t.text     "memo",                   limit: 65535
    t.text     "admin_memo",             limit: 65535
    t.integer  "repeat_id",              limit: 4
    t.integer  "schedule_repeat_id",     limit: 4
    t.integer  "dirty_repeat_id",        limit: 4
    t.integer  "no_time_id",             limit: 4
    t.integer  "schedule_parent_id",     limit: 4
    t.integer  "participant_nums_inner", limit: 4
    t.integer  "participant_nums_outer", limit: 4
    t.integer  "check_30_over",          limit: 4
    t.text     "inquire_to",             limit: 65535
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "todo",                   limit: 4,     default: 0
    t.integer  "allday",                 limit: 4
    t.integer  "guide_state",            limit: 4
    t.integer  "guide_place_id",         limit: 4
    t.text     "guide_place",            limit: 65535
    t.integer  "guide_ed_at",            limit: 4
    t.integer  "event_week",             limit: 4
    t.integer  "event_month",            limit: 4
    t.string   "tmp_id",                 limit: 255
  end

  add_index "gw_schedules", ["ed_at"], name: "ed_at", using: :btree
  add_index "gw_schedules", ["schedule_parent_id"], name: "index_gw_schedules_on_schedule_parent_id", using: :btree
  add_index "gw_schedules", ["schedule_repeat_id"], name: "schedule_repeat_id", using: :btree
  add_index "gw_schedules", ["st_at", "ed_at"], name: "st_at", using: :btree

  create_table "gw_section_admin_master_func_names", force: :cascade do |t|
    t.text     "func_name",   limit: 65535
    t.text     "name",        limit: 65535
    t.text     "state",       limit: 65535
    t.integer  "sort_no",     limit: 4
    t.integer  "creator_uid", limit: 4
    t.integer  "creator_gid", limit: 4
    t.datetime "created_at"
    t.integer  "updator_uid", limit: 4
    t.integer  "updator_gid", limit: 4
    t.datetime "updated_at"
    t.integer  "deleted_uid", limit: 4
    t.integer  "deleted_gid", limit: 4
    t.datetime "deleted_at"
  end

  create_table "gw_section_admin_masters", force: :cascade do |t|
    t.text     "func_name",             limit: 65535
    t.string   "state",                 limit: 255
    t.integer  "edit_auth",             limit: 4
    t.integer  "management_parent_gid", limit: 4
    t.integer  "management_gid",        limit: 4
    t.integer  "management_uid",        limit: 4
    t.integer  "range_class_id",        limit: 4
    t.integer  "division_parent_gid",   limit: 4
    t.integer  "division_gid",          limit: 4
    t.string   "management_ucode",      limit: 255
    t.integer  "fyear_id_sb04",         limit: 4
    t.string   "management_gcode",      limit: 255
    t.string   "division_gcode",        limit: 255
    t.integer  "management_uid_sb04",   limit: 4
    t.integer  "management_gid_sb04",   limit: 4
    t.integer  "division_gid_sb04",     limit: 4
    t.integer  "creator_uid",           limit: 4
    t.integer  "creator_gid",           limit: 4
    t.integer  "updator_uid",           limit: 4
    t.integer  "updator_gid",           limit: 4
    t.integer  "deleted_uid",           limit: 4
    t.integer  "deleted_gid",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "gw_todos", force: :cascade do |t|
    t.integer  "class_id",    limit: 4
    t.integer  "uid",         limit: 4
    t.string   "title",       limit: 255
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "prior_id",    limit: 4
    t.integer  "category_id", limit: 4
    t.text     "body",        limit: 65535
  end

  create_table "gw_user_properties", force: :cascade do |t|
    t.integer  "class_id",   limit: 4
    t.string   "uid",        limit: 255
    t.string   "name",       limit: 255
    t.string   "type_name",  limit: 255
    t.text     "options",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_user_properties", ["class_id", "uid", "name", "type_name"], name: "idx_gw_user_properties_searches", using: :btree

  create_table "gw_workflow_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "doc_body_size_capacity",                  limit: 4
    t.integer  "doc_body_size_currently",                 limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.integer  "commission_limit",                        limit: 4
    t.string   "create_section",                          limit: 255
    t.string   "create_section_flag",                     limit: 255
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern",                      limit: 4
    t.string   "left_index_bg_color",                     limit: 255
    t.string   "default_mode",                            limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id",                            limit: 4
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.text     "font_color",                              limit: 65535
    t.integer  "icon_id",                                 limit: 4
    t.text     "icon",                                    limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.boolean  "group_view"
    t.integer  "one_line_use",                            limit: 4
    t.integer  "notification",                            limit: 4
    t.boolean  "restrict_access"
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.text     "notes_field01",                           limit: 65535
    t.text     "notes_field02",                           limit: 65535
    t.text     "notes_field03",                           limit: 65535
    t.text     "notes_field04",                           limit: 65535
    t.text     "notes_field05",                           limit: 65535
    t.text     "notes_field06",                           limit: 65535
    t.text     "notes_field07",                           limit: 65535
    t.text     "notes_field08",                           limit: 65535
    t.text     "notes_field09",                           limit: 65535
    t.text     "notes_field10",                           limit: 65535
    t.datetime "docslast_updated_at"
  end

  create_table "gw_workflow_custom_route_steps", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "custom_route_id", limit: 4
    t.integer  "number",          limit: 4
  end

  create_table "gw_workflow_custom_route_users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "step_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "user_name",  limit: 65535
    t.text     "user_gname", limit: 65535
  end

  create_table "gw_workflow_custom_routes", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_uid",  limit: 4
    t.integer  "sort_no",    limit: 4
    t.text     "state",      limit: 65535
    t.text     "name",       limit: 65535
  end

  create_table "gw_workflow_docs", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "state",          limit: 65535
    t.text     "title",          limit: 65535
    t.text     "body",           limit: 16777215
    t.datetime "expired_at"
    t.datetime "applied_at"
    t.string   "creater_id",     limit: 20
    t.string   "creater_name",   limit: 20
    t.string   "creater_gname",  limit: 20
    t.integer  "attachmentfile", limit: 4
  end

  create_table "gw_workflow_itemdeletes", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code",       limit: 255
    t.integer  "title_id",         limit: 4
    t.text     "board_title",      limit: 65535
    t.string   "board_state",      limit: 255
    t.string   "board_view_hide",  limit: 255
    t.integer  "board_sort_no",    limit: 4
    t.integer  "public_doc_count", limit: 4
    t.integer  "void_doc_count",   limit: 4
    t.string   "dbname",           limit: 255
    t.string   "limit_date",       limit: 255
    t.string   "board_limit_date", limit: 255
  end

  create_table "gw_workflow_mail_settings", force: :cascade do |t|
    t.integer "unid",      limit: 4
    t.boolean "notifying"
  end

  create_table "gw_workflow_route_steps", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "doc_id",     limit: 4
    t.integer  "number",     limit: 4
  end

  create_table "gw_workflow_route_users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "step_id",    limit: 4
    t.datetime "decided_at"
    t.string   "state",      limit: 255
    t.text     "comment",    limit: 65535
    t.integer  "user_id",    limit: 4
    t.text     "user_name",  limit: 65535
    t.text     "user_gname", limit: 65535
  end

  create_table "gw_year_fiscal_jps", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "fyear",         limit: 65535
    t.text     "fyear_f",       limit: 65535
    t.text     "markjp",        limit: 65535
    t.text     "markjp_f",      limit: 65535
    t.text     "namejp",        limit: 65535
    t.text     "namejp_f",      limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gw_year_mark_jps", force: :cascade do |t|
    t.text     "name",          limit: 65535
    t.text     "mark",          limit: 65535
    t.datetime "start_at"
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gwbbs_adms", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "gwbbs_adms", ["title_id"], name: "index_gwbbs_adms_on_title_id", using: :btree

  create_table "gwbbs_categories", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "parent_id",  limit: 4
    t.text     "state",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",   limit: 4
    t.integer  "sort_no",    limit: 4
    t.integer  "level_no",   limit: 4
    t.text     "name",       limit: 65535
    t.integer  "serial_no",  limit: 4
    t.integer  "migrated",   limit: 4
  end

  add_index "gwbbs_categories", ["title_id"], name: "index_gwbbs_categories_on_title_id", using: :btree

  create_table "gwbbs_comments", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.text     "content_state",      limit: 65535
    t.integer  "title_id",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "pname",              limit: 65535
    t.text     "title",              limit: 65535
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keyword1",           limit: 65535
    t.text     "keyword2",           limit: 65535
    t.text     "keyword3",           limit: 65535
    t.text     "keywords",           limit: 65535
    t.text     "createdate",         limit: 65535
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.datetime "expiry_date"
    t.text     "inpfld_001",         limit: 65535
    t.text     "inpfld_002",         limit: 65535
    t.integer  "serial_no",          limit: 4
    t.integer  "migrated",           limit: 4
  end

  add_index "gwbbs_comments", ["parent_id"], name: "index_gwbbs_comments_on_parent_id", using: :btree
  add_index "gwbbs_comments", ["title_id"], name: "index_gwbbs_comments_on_title_id", using: :btree

  create_table "gwbbs_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "doc_body_size_capacity",                  limit: 4
    t.integer  "doc_body_size_currently",                 limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.string   "create_section",                          limit: 255
    t.string   "create_section_flag",                     limit: 255
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern",                      limit: 4
    t.string   "left_index_bg_color",                     limit: 255
    t.string   "default_mode",                            limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id",                            limit: 4
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.text     "font_color",                              limit: 65535
    t.integer  "icon_id",                                 limit: 4
    t.text     "icon",                                    limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.boolean  "group_view"
    t.integer  "one_line_use",                            limit: 4
    t.integer  "notification",                            limit: 4
    t.boolean  "restrict_access"
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.text     "notes_field01",                           limit: 65535
    t.text     "notes_field02",                           limit: 65535
    t.text     "notes_field03",                           limit: 65535
    t.text     "notes_field04",                           limit: 65535
    t.text     "notes_field05",                           limit: 65535
    t.text     "notes_field06",                           limit: 65535
    t.text     "notes_field07",                           limit: 65535
    t.text     "notes_field08",                           limit: 65535
    t.text     "notes_field09",                           limit: 65535
    t.text     "notes_field10",                           limit: 65535
    t.datetime "docslast_updated_at"
    t.text     "icon_filename",                           limit: 65535
    t.string   "icon_position",                           limit: 255
  end

  add_index "gwbbs_controls", ["notification"], name: "index_gwbbs_controls_on_notification", using: :btree

  create_table "gwbbs_db_files", force: :cascade do |t|
    t.integer "title_id",  limit: 4
    t.integer "parent_id", limit: 4
    t.binary  "data",      limit: 4294967295
    t.integer "serial_no", limit: 4
    t.integer "migrated",  limit: 4
  end

  add_index "gwbbs_db_files", ["parent_id"], name: "index_gwbbs_db_files_on_parent_id", using: :btree
  add_index "gwbbs_db_files", ["title_id"], name: "index_gwbbs_db_files_on_title_id", using: :btree

  create_table "gwbbs_docs", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.text     "content_state",      limit: 65535
    t.string   "section_code",       limit: 255
    t.text     "section_name",       limit: 65535
    t.integer  "importance",         limit: 4
    t.integer  "one_line_note",      limit: 4
    t.integer  "title_id",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "pname",              limit: 65535
    t.text     "title",              limit: 65535
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use",       limit: 4
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keywords",           limit: 65535
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "attachmentfile",     limit: 4
    t.string   "form_name",          limit: 255
    t.text     "inpfld_001",         limit: 65535
    t.text     "inpfld_002",         limit: 65535
    t.text     "inpfld_003",         limit: 65535
    t.text     "inpfld_004",         limit: 65535
    t.text     "inpfld_005",         limit: 65535
    t.text     "inpfld_006",         limit: 65535
    t.string   "inpfld_006w",        limit: 255
    t.datetime "inpfld_006d"
    t.text     "inpfld_007",         limit: 65535
    t.text     "inpfld_008",         limit: 65535
    t.text     "inpfld_009",         limit: 65535
    t.text     "inpfld_010",         limit: 65535
    t.text     "inpfld_011",         limit: 65535
    t.text     "inpfld_012",         limit: 65535
    t.text     "inpfld_013",         limit: 65535
    t.text     "inpfld_014",         limit: 65535
    t.text     "inpfld_015",         limit: 65535
    t.text     "inpfld_016",         limit: 65535
    t.text     "inpfld_017",         limit: 65535
    t.text     "inpfld_018",         limit: 65535
    t.text     "inpfld_019",         limit: 65535
    t.text     "inpfld_020",         limit: 65535
    t.text     "inpfld_021",         limit: 65535
    t.text     "inpfld_022",         limit: 65535
    t.text     "inpfld_023",         limit: 65535
    t.text     "inpfld_024",         limit: 65535
    t.text     "inpfld_025",         limit: 65535
    t.integer  "serial_no",          limit: 4
    t.integer  "migrated",           limit: 4
    t.integer  "wiki",               limit: 4
  end

  add_index "gwbbs_docs", ["title_id"], name: "index_gwbbs_docs_on_title_id", using: :btree

  create_table "gwbbs_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "gwbbs_files", ["parent_id"], name: "index_gwbbs_files_on_parent_id", using: :btree
  add_index "gwbbs_files", ["title_id"], name: "index_gwbbs_files_on_title_id", using: :btree

  create_table "gwbbs_images", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.text     "parent_name",       limit: 65535
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "gwbbs_images", ["parent_id"], name: "index_gwbbs_images_on_parent_id", using: :btree
  add_index "gwbbs_images", ["title_id"], name: "index_gwbbs_images_on_title_id", using: :btree

  create_table "gwbbs_itemdeletes", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code",       limit: 255
    t.integer  "title_id",         limit: 4
    t.text     "board_title",      limit: 65535
    t.string   "board_state",      limit: 255
    t.string   "board_view_hide",  limit: 255
    t.integer  "board_sort_no",    limit: 4
    t.integer  "public_doc_count", limit: 4
    t.integer  "void_doc_count",   limit: 4
    t.string   "dbname",           limit: 255
    t.string   "limit_date",       limit: 255
    t.string   "board_limit_date", limit: 255
  end

  create_table "gwbbs_itemimages", force: :cascade do |t|
    t.string   "type_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",   limit: 4
    t.text     "filename",   limit: 65535
    t.integer  "width",      limit: 4
    t.integer  "height",     limit: 4
  end

  create_table "gwbbs_recognizers", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id",      limit: 4
    t.integer  "parent_id",     limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "code",          limit: 255
    t.text     "name",          limit: 65535
    t.datetime "recognized_at"
    t.integer  "serial_no",     limit: 4
    t.integer  "migrated",      limit: 4
  end

  add_index "gwbbs_recognizers", ["parent_id"], name: "index_gwbbs_recognizers_on_parent_id", using: :btree
  add_index "gwbbs_recognizers", ["title_id"], name: "index_gwbbs_recognizers_on_title_id", using: :btree

  create_table "gwbbs_roles", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.string   "role_code",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "gwbbs_roles", ["title_id"], name: "index_gwbbs_roles_on_title_id", using: :btree

  create_table "gwbbs_themes", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "board_id",           limit: 4
    t.integer  "theme_id",           limit: 4
    t.text     "section_code",       limit: 65535
    t.text     "section_name",       limit: 65535
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
  end

  create_table "gwboard_bgcolors", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",            limit: 255
    t.string   "title",            limit: 255
    t.string   "color_code_hex",   limit: 255
    t.string   "color_code_class", limit: 255
    t.string   "pair_font_color",  limit: 255
    t.text     "memo",             limit: 65535
  end

  create_table "gwboard_images", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "share",              limit: 4
    t.integer  "range_of_use",       limit: 4
    t.text     "filename",           limit: 65535
    t.string   "content_type",       limit: 255
    t.text     "memo",               limit: 65535
    t.integer  "size",               limit: 4
    t.integer  "width",              limit: 4
    t.integer  "height",             limit: 4
    t.text     "section_code",       limit: 65535
    t.text     "section_name",       limit: 65535
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
  end

  create_table "gwboard_maps", force: :cascade do |t|
    t.integer  "unid",        limit: 4
    t.integer  "content_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",       limit: 255
    t.string   "system_name", limit: 255
    t.integer  "title_id",    limit: 4
    t.integer  "parent_id",   limit: 4
    t.string   "field_name",  limit: 255
    t.integer  "use_param",   limit: 4
    t.text     "address",     limit: 65535
    t.string   "latlong",     limit: 255
    t.string   "latitude",    limit: 255
    t.string   "longitude",   limit: 255
    t.text     "memo",        limit: 65535
    t.string   "url",         limit: 255
  end

  create_table "gwboard_renewal_groups", force: :cascade do |t|
    t.integer  "present_group_id",    limit: 4
    t.string   "present_group_code",  limit: 255
    t.text     "present_group_name",  limit: 65535
    t.integer  "incoming_group_id",   limit: 4
    t.string   "incoming_group_code", limit: 255
    t.text     "incoming_group_name", limit: 65535
    t.datetime "start_date"
  end

  create_table "gwboard_syntheses", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "latest_updated_at"
    t.string   "system_name",       limit: 255
    t.text     "state",             limit: 65535
    t.integer  "title_id",          limit: 4
    t.integer  "parent_id",         limit: 4
    t.string   "board_name",        limit: 255
    t.text     "title",             limit: 65535
    t.text     "url",               limit: 65535
    t.text     "editordivision",    limit: 65535
    t.text     "editor",            limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "acl_flag",          limit: 4
    t.string   "acl_section_code",  limit: 255
    t.string   "acl_user_code",     limit: 255
  end

  create_table "gwboard_synthesetups", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "gwbbs_check"
    t.boolean  "gwfaq_check"
    t.boolean  "gwqa_check"
    t.boolean  "doclib_check"
    t.boolean  "digitallib_check"
    t.string   "limit_date",       limit: 255
  end

  create_table "gwboard_themes", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.string   "record_use",         limit: 255
    t.integer  "sort_no",            limit: 4
    t.text     "if_name",            limit: 65535
    t.integer  "if_icon_id",         limit: 4
    t.text     "if_icon",            limit: 65535
    t.integer  "if_bg_setup",        limit: 4
    t.text     "if_font_color",      limit: 65535
    t.integer  "if_wallpaper_id",    limit: 4
    t.text     "if_wallpaper",       limit: 65535
    t.text     "if_css",             limit: 65535
    t.text     "name",               limit: 65535
    t.boolean  "preview_mode"
    t.integer  "bg_setup",           limit: 4
    t.integer  "icon_id",            limit: 4
    t.text     "icon",               limit: 65535
    t.text     "css",                limit: 65535
    t.text     "font_color",         limit: 65535
    t.integer  "wallpaper_id",       limit: 4
    t.text     "wallpaper",          limit: 65535
    t.text     "section_code",       limit: 65535
    t.text     "section_name",       limit: 65535
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
  end

  create_table "gwcircular_adms", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "gwcircular_adms", ["title_id"], name: "index_gwcircular_adms_on_title_id", using: :btree

  create_table "gwcircular_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "doc_body_size_capacity",                  limit: 4
    t.integer  "doc_body_size_currently",                 limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.integer  "commission_limit",                        limit: 4
    t.string   "create_section",                          limit: 255
    t.string   "create_section_flag",                     limit: 255
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern",                      limit: 4
    t.string   "left_index_bg_color",                     limit: 255
    t.string   "default_mode",                            limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id",                            limit: 4
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.text     "font_color",                              limit: 65535
    t.integer  "icon_id",                                 limit: 4
    t.text     "icon",                                    limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.boolean  "group_view"
    t.integer  "one_line_use",                            limit: 4
    t.integer  "notification",                            limit: 4
    t.boolean  "restrict_access"
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.text     "notes_field01",                           limit: 65535
    t.text     "notes_field02",                           limit: 65535
    t.text     "notes_field03",                           limit: 65535
    t.text     "notes_field04",                           limit: 65535
    t.text     "notes_field05",                           limit: 65535
    t.text     "notes_field06",                           limit: 65535
    t.text     "notes_field07",                           limit: 65535
    t.text     "notes_field08",                           limit: 65535
    t.text     "notes_field09",                           limit: 65535
    t.text     "notes_field10",                           limit: 65535
    t.datetime "docslast_updated_at"
  end

  create_table "gwcircular_custom_groups", force: :cascade do |t|
    t.integer  "parent_id",          limit: 4
    t.integer  "class_id",           limit: 4
    t.integer  "owner_uid",          limit: 4
    t.integer  "owner_gid",          limit: 4
    t.integer  "updater_uid",        limit: 4
    t.integer  "updater_gid",        limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "name_en",            limit: 65535
    t.integer  "sort_no",            limit: 4
    t.text     "sort_prefix",        limit: 65535
    t.integer  "is_default",         limit: 4
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
  end

  add_index "gwcircular_custom_groups", ["owner_uid"], name: "index_gwcircular_custom_groups_on_owner_uid", using: :btree

  create_table "gwcircular_docs", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.integer  "target_user_id",     limit: 4
    t.string   "target_user_code",   limit: 20
    t.text     "target_user_name",   limit: 65535
    t.integer  "confirmation",       limit: 4
    t.string   "section_code",       limit: 255
    t.text     "section_name",       limit: 65535
    t.integer  "importance",         limit: 4
    t.integer  "title_id",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "title",              limit: 65535
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use",       limit: 4
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keywords",           limit: 65535
    t.integer  "commission_count",   limit: 4
    t.integer  "unread_count",       limit: 4
    t.integer  "already_count",      limit: 4
    t.integer  "draft_count",        limit: 4
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "attachmentfile",     limit: 4
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
    t.integer  "wiki",               limit: 4
  end

  add_index "gwcircular_docs", ["parent_id"], name: "parent_id", using: :btree
  add_index "gwcircular_docs", ["title_id"], name: "index_gwcircular_docs_on_title_id", using: :btree

  create_table "gwcircular_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
  end

  add_index "gwcircular_files", ["parent_id"], name: "index_gwcircular_files_on_parent_id", using: :btree
  add_index "gwcircular_files", ["title_id"], name: "index_gwcircular_files_on_title_id", using: :btree

  create_table "gwcircular_itemdeletes", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code",       limit: 255
    t.integer  "title_id",         limit: 4
    t.text     "board_title",      limit: 65535
    t.string   "board_state",      limit: 255
    t.string   "board_view_hide",  limit: 255
    t.integer  "board_sort_no",    limit: 4
    t.integer  "public_doc_count", limit: 4
    t.integer  "void_doc_count",   limit: 4
    t.string   "dbname",           limit: 255
    t.string   "limit_date",       limit: 255
    t.string   "board_limit_date", limit: 255
  end

  create_table "gwcircular_roles", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.string   "role_code",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "gwcircular_roles", ["title_id"], name: "index_gwcircular_roles_on_title_id", using: :btree

  create_table "gwfaq_adms", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "gwfaq_adms", ["title_id"], name: "index_gwfaq_adms_on_title_id", using: :btree

  create_table "gwfaq_categories", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "parent_id",  limit: 4
    t.text     "state",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",   limit: 4
    t.integer  "sort_no",    limit: 4
    t.integer  "level_no",   limit: 4
    t.text     "name",       limit: 65535
    t.integer  "serial_no",  limit: 4
    t.integer  "migrated",   limit: 4
  end

  add_index "gwfaq_categories", ["title_id"], name: "index_gwfaq_categories_on_title_id", using: :btree

  create_table "gwfaq_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.string   "create_section",                          limit: 255
    t.integer  "addnew_forbidden",                        limit: 4
    t.integer  "draft_forbidden",                         limit: 4
    t.integer  "delete_forbidden",                        limit: 4
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern",                      limit: 4
    t.string   "left_index_bg_color",                     limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.boolean  "group_view"
    t.integer  "notification",                            limit: 4
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.datetime "docslast_updated_at"
  end

  add_index "gwfaq_controls", ["notification"], name: "index_gwfaq_controls_on_notification", using: :btree

  create_table "gwfaq_db_files", force: :cascade do |t|
    t.integer "title_id",  limit: 4
    t.integer "parent_id", limit: 4
    t.binary  "data",      limit: 4294967295
    t.integer "serial_no", limit: 4
    t.integer "migrated",  limit: 4
  end

  add_index "gwfaq_db_files", ["parent_id"], name: "index_gwfaq_db_files_on_parent_id", using: :btree
  add_index "gwfaq_db_files", ["title_id"], name: "index_gwfaq_db_files_on_title_id", using: :btree

  create_table "gwfaq_docs", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.text     "content_state",      limit: 65535
    t.string   "section_code",       limit: 255
    t.text     "section_name",       limit: 65535
    t.integer  "importance",         limit: 4
    t.integer  "one_line_note",      limit: 4
    t.integer  "title_id",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "pname",              limit: 65535
    t.text     "title",              limit: 65535
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use",       limit: 4
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keywords",           limit: 65535
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.integer  "attachmentfile",     limit: 4
    t.integer  "serial_no",          limit: 4
    t.integer  "migrated",           limit: 4
    t.integer  "wiki",               limit: 4
  end

  create_table "gwfaq_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "gwfaq_files", ["parent_id"], name: "index_gwfaq_files_on_parent_id", using: :btree
  add_index "gwfaq_files", ["title_id"], name: "index_gwfaq_files_on_title_id", using: :btree

  create_table "gwfaq_images", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.text     "parent_name",       limit: 65535
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "gwfaq_images", ["parent_id"], name: "index_gwfaq_images_on_parent_id", using: :btree
  add_index "gwfaq_images", ["title_id"], name: "index_gwfaq_images_on_title_id", using: :btree

  create_table "gwfaq_recognizers", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id",      limit: 4
    t.integer  "parent_id",     limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "code",          limit: 255
    t.text     "name",          limit: 65535
    t.datetime "recognized_at"
    t.integer  "serial_no",     limit: 4
    t.integer  "migrated",      limit: 4
  end

  add_index "gwfaq_recognizers", ["parent_id"], name: "index_gwfaq_recognizers_on_parent_id", using: :btree
  add_index "gwfaq_recognizers", ["title_id"], name: "index_gwfaq_recognizers_on_title_id", using: :btree

  create_table "gwfaq_roles", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.string   "role_code",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "gwfaq_roles", ["title_id"], name: "index_gwfaq_roles_on_title_id", using: :btree

  create_table "gwmonitor_base_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
  end

  add_index "gwmonitor_base_files", ["title_id"], name: "index_gwmonitor_base_files_on_title_id", using: :btree

  create_table "gwmonitor_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "latest_updated_at"
    t.string   "section_code",                            limit: 255
    t.string   "section_name",                            limit: 255
    t.integer  "section_sort",                            limit: 4
    t.string   "name",                                    limit: 255
    t.integer  "form_id",                                 limit: 4
    t.string   "form_name",                               limit: 255
    t.string   "form_caption",                            limit: 255
    t.integer  "upload_system",                           limit: 4
    t.integer  "admin_setting",                           limit: 4
    t.integer  "spec_config",                             limit: 4
    t.string   "title",                                   limit: 255
    t.text     "caption",                                 limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "reminder_start_section",                  limit: 4
    t.integer  "reminder_start_personal",                 limit: 4
    t.integer  "public_count",                            limit: 4
    t.integer  "draft_count",                             limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.text     "dsp_admin_name",                          limit: 65535
    t.string   "send_change",                             limit: 255
    t.text     "custom_groups",                           limit: 65535
    t.text     "custom_groups_json",                      limit: 65535
    t.text     "reader_groups",                           limit: 65535
    t.text     "reader_groups_json",                      limit: 65535
    t.text     "custom_readers",                          limit: 65535
    t.text     "custom_readers_json",                     limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.integer  "wiki",                                    limit: 4
    t.text     "form_configs",                            limit: 65535
  end

  create_table "gwmonitor_custom_groups", force: :cascade do |t|
    t.integer  "parent_id",          limit: 4
    t.integer  "class_id",           limit: 4
    t.integer  "owner_uid",          limit: 4
    t.integer  "owner_gid",          limit: 4
    t.integer  "updater_uid",        limit: 4
    t.integer  "updater_gid",        limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "name_en",            limit: 65535
    t.integer  "sort_no",            limit: 4
    t.text     "sort_prefix",        limit: 65535
    t.integer  "is_default",         limit: 4
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
  end

  add_index "gwmonitor_custom_groups", ["owner_uid"], name: "index_gwmonitor_custom_groups_on_owner_uid", using: :btree

  create_table "gwmonitor_custom_user_groups", force: :cascade do |t|
    t.integer  "parent_id",          limit: 4
    t.integer  "class_id",           limit: 4
    t.integer  "owner_uid",          limit: 4
    t.integer  "owner_gid",          limit: 4
    t.integer  "updater_uid",        limit: 4
    t.integer  "updater_gid",        limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "name_en",            limit: 65535
    t.integer  "sort_no",            limit: 4
    t.text     "sort_prefix",        limit: 65535
    t.integer  "is_default",         limit: 4
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
  end

  add_index "gwmonitor_custom_user_groups", ["owner_uid"], name: "index_gwmonitor_custom_user_groups_on_owner_uid", using: :btree

  create_table "gwmonitor_docs", force: :cascade do |t|
    t.integer  "unid",                       limit: 4
    t.integer  "content_id",                 limit: 4
    t.text     "state",                      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "latest_updated_at"
    t.integer  "send_division",              limit: 4
    t.string   "user_code",                  limit: 20
    t.string   "user_name",                  limit: 255
    t.string   "l2_section_code",            limit: 255
    t.string   "section_code",               limit: 255
    t.text     "section_name",               limit: 65535
    t.integer  "section_sort",               limit: 4
    t.string   "email",                      limit: 255
    t.boolean  "email_send"
    t.integer  "title_id",                   limit: 4
    t.text     "name",                       limit: 65535
    t.text     "title",                      limit: 65535
    t.text     "head",                       limit: 16777215
    t.text     "body",                       limit: 16777215
    t.text     "note",                       limit: 16777215
    t.text     "keywords",                   limit: 65535
    t.text     "createdate",                 limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id",         limit: 20
    t.text     "createrdivision",            limit: 65535
    t.string   "creater_id",                 limit: 20
    t.text     "creater",                    limit: 65535
    t.text     "editdate",                   limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",          limit: 20
    t.text     "editordivision",             limit: 65535
    t.string   "editor_id",                  limit: 20
    t.text     "editor",                     limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.datetime "remind_start_date"
    t.datetime "remind_start_date_personal"
    t.string   "receipt_user_code",          limit: 255
    t.integer  "attachmentfile",             limit: 4
  end

  add_index "gwmonitor_docs", ["title_id"], name: "index_gwmonitor_docs_on_title_id", using: :btree

  create_table "gwmonitor_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
  end

  add_index "gwmonitor_files", ["parent_id"], name: "index_gwmonitor_files_on_parent_id", using: :btree
  add_index "gwmonitor_files", ["title_id"], name: "index_gwmonitor_files_on_title_id", using: :btree

  create_table "gwmonitor_forms", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.text     "state",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no",      limit: 4
    t.integer  "level_no",     limit: 4
    t.string   "form_name",    limit: 255
    t.text     "form_caption", limit: 65535
  end

  create_table "gwmonitor_itemdeletes", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code",       limit: 255
    t.integer  "title_id",         limit: 4
    t.text     "board_title",      limit: 65535
    t.string   "board_state",      limit: 255
    t.string   "board_view_hide",  limit: 255
    t.integer  "board_sort_no",    limit: 4
    t.integer  "public_doc_count", limit: 4
    t.integer  "void_doc_count",   limit: 4
    t.string   "dbname",           limit: 255
    t.string   "limit_date",       limit: 255
    t.string   "board_limit_date", limit: 255
  end

  create_table "gwqa_adms", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "gwqa_adms", ["title_id"], name: "index_gwqa_adms_on_title_id", using: :btree

  create_table "gwqa_categories", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "parent_id",  limit: 4
    t.text     "state",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",   limit: 4
    t.integer  "sort_no",    limit: 4
    t.integer  "level_no",   limit: 4
    t.text     "name",       limit: 65535
    t.integer  "serial_no",  limit: 4
    t.integer  "migrated",   limit: 4
  end

  add_index "gwqa_categories", ["title_id"], name: "index_gwqa_categories_on_title_id", using: :btree

  create_table "gwqa_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.string   "create_section",                          limit: 255
    t.integer  "addnew_forbidden",                        limit: 4
    t.integer  "draft_forbidden",                         limit: 4
    t.integer  "delete_forbidden",                        limit: 4
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern",                      limit: 4
    t.string   "left_index_bg_color",                     limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.boolean  "group_view"
    t.integer  "notification",                            limit: 4
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.datetime "docslast_updated_at"
  end

  add_index "gwqa_controls", ["notification"], name: "index_gwqa_controls_on_notification", using: :btree

  create_table "gwqa_db_files", force: :cascade do |t|
    t.integer "title_id",  limit: 4
    t.integer "parent_id", limit: 4
    t.binary  "data",      limit: 4294967295
    t.integer "serial_no", limit: 4
    t.integer "migrated",  limit: 4
  end

  add_index "gwqa_db_files", ["parent_id"], name: "index_gwqa_db_files_on_parent_id", using: :btree
  add_index "gwqa_db_files", ["title_id"], name: "index_gwqa_db_files_on_title_id", using: :btree

  create_table "gwqa_docs", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.text     "content_state",      limit: 65535
    t.string   "section_code",       limit: 255
    t.text     "section_name",       limit: 65535
    t.integer  "importance",         limit: 4
    t.integer  "one_line_note",      limit: 4
    t.integer  "title_id",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "pname",              limit: 65535
    t.text     "title",              limit: 65535
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use",       limit: 4
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keywords",           limit: 65535
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.datetime "expiry_date"
    t.integer  "attachmentfile",     limit: 4
    t.integer  "answer_count",       limit: 4
    t.text     "inpfld_001",         limit: 65535
    t.text     "inpfld_002",         limit: 65535
    t.datetime "latest_answer"
    t.integer  "serial_no",          limit: 4
    t.integer  "migrated",           limit: 4
    t.integer  "wiki",               limit: 4
  end

  add_index "gwqa_docs", ["title_id"], name: "index_gwqa_docs_on_title_id", using: :btree

  create_table "gwqa_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "gwqa_files", ["parent_id"], name: "index_gwqa_files_on_parent_id", using: :btree
  add_index "gwqa_files", ["title_id"], name: "index_gwqa_files_on_title_id", using: :btree

  create_table "gwqa_images", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.text     "parent_name",       limit: 65535
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "serial_no",         limit: 4
    t.integer  "migrated",          limit: 4
  end

  add_index "gwqa_images", ["parent_id"], name: "index_gwqa_images_on_parent_id", using: :btree
  add_index "gwqa_images", ["title_id"], name: "index_gwqa_images_on_title_id", using: :btree

  create_table "gwqa_recognizers", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id",      limit: 4
    t.integer  "parent_id",     limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "code",          limit: 255
    t.text     "name",          limit: 65535
    t.datetime "recognized_at"
    t.integer  "serial_no",     limit: 4
    t.integer  "migrated",      limit: 4
  end

  add_index "gwqa_recognizers", ["parent_id"], name: "index_gwqa_recognizers_on_parent_id", using: :btree
  add_index "gwqa_recognizers", ["title_id"], name: "index_gwqa_recognizers_on_title_id", using: :btree

  create_table "gwqa_roles", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.string   "role_code",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  add_index "gwqa_roles", ["title_id"], name: "index_gwqa_roles_on_title_id", using: :btree

  create_table "gwsub_capacityunitsets", force: :cascade do |t|
    t.integer  "code_int",      limit: 4
    t.text     "code",          limit: 65535
    t.text     "name",          limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  add_index "gwsub_capacityunitsets", ["code_int"], name: "index_gwsub_capacityunitsets_on_code_int", using: :btree

  create_table "gwsub_externalmediakinds", force: :cascade do |t|
    t.integer  "sort_order_int", limit: 4
    t.text     "sort_order",     limit: 65535
    t.text     "kind",           limit: 65535
    t.text     "name",           limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",   limit: 65535
    t.text     "updated_group",  limit: 65535
    t.datetime "created_at"
    t.text     "created_user",   limit: 65535
    t.text     "created_group",  limit: 65535
  end

  add_index "gwsub_externalmediakinds", ["sort_order_int"], name: "index_gwsub_externalmediakinds_on_sort_order_int", using: :btree

  create_table "gwsub_externalmedias", force: :cascade do |t|
    t.integer  "new_registedno",         limit: 4
    t.integer  "section_id",             limit: 4
    t.string   "section_code",           limit: 255
    t.text     "section_name",           limit: 65535
    t.text     "registedno",             limit: 65535
    t.integer  "externalmediakind_id",   limit: 4
    t.string   "externalmediakind_name", limit: 255
    t.text     "registed_seq",           limit: 65535
    t.datetime "registed_at"
    t.text     "equipmentname",          limit: 65535
    t.integer  "user_section_id",        limit: 4
    t.integer  "user_id",                limit: 4
    t.string   "user",                   limit: 255
    t.integer  "categories",             limit: 4
    t.datetime "ending_at"
    t.text     "remarks",                limit: 65535
    t.datetime "last_updated_at"
    t.datetime "updated_at"
    t.text     "updated_user",           limit: 65535
    t.text     "updated_group",          limit: 65535
    t.datetime "created_at"
    t.text     "created_user",           limit: 65535
    t.text     "created_group",          limit: 65535
  end

  add_index "gwsub_externalmedias", ["externalmediakind_id"], name: "index_gwsub_externalmedias_on_externalmediakind_id", using: :btree
  add_index "gwsub_externalmedias", ["section_id"], name: "index_gwsub_externalmedias_on_section_id", using: :btree
  add_index "gwsub_externalmedias", ["user_id"], name: "index_gwsub_externalmedias_on_user_id", using: :btree
  add_index "gwsub_externalmedias", ["user_section_id"], name: "index_gwsub_externalmedias_on_user_section_id", using: :btree

  create_table "gwsub_externalusbs", force: :cascade do |t|
    t.integer  "new_registedno",       limit: 4
    t.integer  "section_id",           limit: 4
    t.string   "section_code",         limit: 255
    t.text     "section_name",         limit: 65535
    t.text     "registedno",           limit: 65535
    t.integer  "externalmediakind_id", limit: 4
    t.datetime "registed_at"
    t.text     "equipmentname",        limit: 65535
    t.text     "capacity",             limit: 65535
    t.integer  "capacityunit_id",      limit: 4
    t.text     "sendstate",            limit: 65535
    t.integer  "user_section_id",      limit: 4
    t.integer  "user_id",              limit: 4
    t.string   "user",                 limit: 255
    t.integer  "categories",           limit: 4
    t.datetime "ending_at"
    t.text     "remarks",              limit: 65535
    t.datetime "last_updated_at"
    t.datetime "updated_at"
    t.text     "updated_user",         limit: 65535
    t.text     "updated_group",        limit: 65535
    t.datetime "created_at"
    t.text     "created_user",         limit: 65535
    t.text     "created_group",        limit: 65535
  end

  add_index "gwsub_externalusbs", ["capacityunit_id"], name: "index_gwsub_externalusbs_on_capacityunit_id", using: :btree
  add_index "gwsub_externalusbs", ["externalmediakind_id"], name: "index_gwsub_externalusbs_on_externalmediakind_id", using: :btree
  add_index "gwsub_externalusbs", ["section_id"], name: "index_gwsub_externalusbs_on_section_id", using: :btree
  add_index "gwsub_externalusbs", ["user_id"], name: "index_gwsub_externalusbs_on_user_id", using: :btree
  add_index "gwsub_externalusbs", ["user_section_id"], name: "index_gwsub_externalusbs_on_user_section_id", using: :btree

  create_table "gwsub_sb00_conference_managers", force: :cascade do |t|
    t.text     "controler",           limit: 65535
    t.text     "controler_title",     limit: 65535
    t.text     "memo_str",            limit: 65535
    t.integer  "fyear_id",            limit: 4
    t.text     "fyear_markjp",        limit: 65535
    t.integer  "group_id",            limit: 4
    t.text     "group_code",          limit: 65535
    t.text     "group_name",          limit: 65535
    t.integer  "user_id",             limit: 4
    t.text     "user_code",           limit: 65535
    t.text     "user_name",           limit: 65535
    t.integer  "official_title_id",   limit: 4
    t.text     "official_title_name", limit: 65535
    t.text     "send_state",          limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",        limit: 65535
    t.text     "updated_group",       limit: 65535
    t.datetime "created_at"
    t.text     "created_user",        limit: 65535
    t.text     "created_group",       limit: 65535
  end

  create_table "gwsub_sb00_conference_references", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.text     "kind_code",     limit: 65535
    t.text     "title",         limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.text     "kind_name",     limit: 65535
    t.integer  "group_id",      limit: 4
  end

  create_table "gwsub_sb00_conference_section_manager_names", force: :cascade do |t|
    t.integer  "fyear_id",     limit: 4
    t.text     "markjp",       limit: 65535
    t.string   "state",        limit: 255
    t.integer  "parent_gid",   limit: 4
    t.integer  "gid",          limit: 4
    t.integer  "g_sort_no",    limit: 4
    t.string   "g_code",       limit: 255
    t.text     "g_name",       limit: 65535
    t.text     "manager_name", limit: 65535
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "gwsub_sb01_training_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
  end

  add_index "gwsub_sb01_training_files", ["parent_id"], name: "index_gwsub_sb01_training_files_on_parent_id", using: :btree

  create_table "gwsub_sb01_training_guides", force: :cascade do |t|
    t.text     "categories",    limit: 65535
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.text     "title",         limit: 65535
    t.text     "bbs_url",       limit: 65535
    t.text     "remarks",       limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "state",         limit: 65535
    t.integer  "member_id",     limit: 4
    t.integer  "group_id",      limit: 4
  end

  create_table "gwsub_sb01_training_schedule_conditions", force: :cascade do |t|
    t.integer  "training_id",     limit: 4
    t.integer  "members_max",     limit: 4
    t.text     "title",           limit: 65535
    t.text     "from_start",      limit: 65535
    t.text     "from_start_min",  limit: 65535
    t.text     "from_end",        limit: 65535
    t.text     "from_end_min",    limit: 65535
    t.integer  "member_id",       limit: 4
    t.integer  "prop_id",         limit: 4
    t.text     "repeat_flg",      limit: 65535
    t.text     "repeat_monthly",  limit: 65535
    t.text     "repeat_weekday",  limit: 65535
    t.datetime "from_at"
    t.datetime "to_at"
    t.datetime "created_at"
    t.text     "created_user",    limit: 65535
    t.text     "created_group",   limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",    limit: 65535
    t.text     "updated_group",   limit: 65535
    t.text     "state",           limit: 65535
    t.integer  "group_id",        limit: 4
    t.text     "extension",       limit: 65535
    t.integer  "prop_kind",       limit: 4
    t.text     "prop_name",       limit: 65535
    t.integer  "repeat_class_id", limit: 4
  end

  add_index "gwsub_sb01_training_schedule_conditions", ["training_id"], name: "index_gwsub_sb01_training_schedule_conditions_on_training_id", using: :btree

  create_table "gwsub_sb01_training_schedule_members", force: :cascade do |t|
    t.integer  "training_id",          limit: 4
    t.integer  "schedule_id",          limit: 4
    t.integer  "condition_id",         limit: 4
    t.integer  "training_schedule_id", limit: 4
    t.integer  "training_user_id",     limit: 4
    t.integer  "training_group_id",    limit: 4
    t.integer  "entry_user_id",        limit: 4
    t.integer  "entry_group_id",       limit: 4
    t.datetime "created_at"
    t.text     "created_user",         limit: 65535
    t.text     "created_group",        limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",         limit: 65535
    t.text     "updated_group",        limit: 65535
    t.text     "training_user_tel",    limit: 65535
    t.text     "entry_user_tel",       limit: 65535
  end

  add_index "gwsub_sb01_training_schedule_members", ["training_id"], name: "index_gwsub_sb01_training_schedule_members_on_training_id", using: :btree

  create_table "gwsub_sb01_training_schedule_props", force: :cascade do |t|
    t.integer  "training_id",     limit: 4
    t.integer  "schedule_id",     limit: 4
    t.integer  "prop_id",         limit: 4
    t.integer  "members_max",     limit: 4
    t.integer  "members_current", limit: 4
    t.integer  "member_id",       limit: 4
    t.datetime "created_at"
    t.text     "created_user",    limit: 65535
    t.text     "created_group",   limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",    limit: 65535
    t.text     "updated_group",   limit: 65535
    t.integer  "condition_id",    limit: 4
    t.text     "from_start",      limit: 65535
    t.text     "from_end",        limit: 65535
    t.text     "state",           limit: 65535
    t.integer  "group_id",        limit: 4
  end

  create_table "gwsub_sb01_training_schedules", force: :cascade do |t|
    t.integer  "schedule_id",     limit: 4
    t.integer  "training_id",     limit: 4
    t.integer  "condition_id",    limit: 4
    t.datetime "created_at"
    t.text     "created_user",    limit: 65535
    t.text     "created_group",   limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",    limit: 65535
    t.text     "updated_group",   limit: 65535
    t.integer  "members_max",     limit: 4
    t.integer  "members_current", limit: 4
    t.text     "state",           limit: 65535
    t.datetime "from_start"
    t.datetime "from_end"
    t.text     "prop_name",       limit: 65535
  end

  add_index "gwsub_sb01_training_schedules", ["training_id"], name: "index_gwsub_sb01_training_schedules_on_training_id", using: :btree

  create_table "gwsub_sb01_trainings", force: :cascade do |t|
    t.text     "categories",    limit: 65535
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.text     "title",         limit: 65535
    t.text     "bbs_url",       limit: 65535
    t.text     "body",          limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "state",         limit: 65535
    t.integer  "member_id",     limit: 4
    t.integer  "group_id",      limit: 4
    t.integer  "member_max",    limit: 4
    t.text     "group_code",    limit: 65535
    t.text     "group_name",    limit: 65535
    t.text     "member_code",   limit: 65535
    t.text     "member_name",   limit: 65535
    t.text     "member_tel",    limit: 65535
    t.integer  "bbs_doc_id",    limit: 4
  end

  create_table "gwsub_sb04_check_assignedjobs", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.integer  "section_id",    limit: 4
    t.text     "section_code",  limit: 65535
    t.text     "section_name",  limit: 65535
    t.integer  "code_int",      limit: 4
    t.text     "code",          limit: 65535
    t.text     "name",          limit: 65535
    t.text     "tel",           limit: 65535
    t.text     "address",       limit: 65535
    t.text     "remarks",       limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gwsub_sb04_check_officialtitles", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.integer  "code_int",      limit: 4
    t.text     "code",          limit: 65535
    t.text     "name",          limit: 65535
    t.text     "remarks",       limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gwsub_sb04_check_sections", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.text     "code",          limit: 65535
    t.text     "name",          limit: 65535
    t.text     "remarks",       limit: 65535
    t.text     "bbs_url",       limit: 65535
    t.text     "ldap_code",     limit: 65535
    t.text     "ldap_name",     limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gwsub_sb04_check_stafflists", force: :cascade do |t|
    t.integer  "fyear_id",                limit: 4
    t.text     "fyear_markjp",            limit: 65535
    t.text     "staff_no",                limit: 65535
    t.text     "multi_section_flg",       limit: 65535
    t.text     "name",                    limit: 65535
    t.text     "name_print",              limit: 65535
    t.text     "kana",                    limit: 65535
    t.integer  "section_id",              limit: 4
    t.text     "section_code",            limit: 65535
    t.text     "section_name",            limit: 65535
    t.integer  "assignedjobs_id",         limit: 4
    t.integer  "assignedjobs_code_int",   limit: 4
    t.text     "assignedjobs_code",       limit: 65535
    t.text     "assignedjobs_name",       limit: 65535
    t.text     "assignedjobs_tel",        limit: 65535
    t.text     "assignedjobs_address",    limit: 65535
    t.integer  "official_title_id",       limit: 4
    t.text     "official_title_code",     limit: 65535
    t.integer  "official_title_code_int", limit: 4
    t.text     "official_title_name",     limit: 65535
    t.integer  "categories_id",           limit: 4
    t.text     "categories_code",         limit: 65535
    t.text     "categories_name",         limit: 65535
    t.text     "extension",               limit: 65535
    t.text     "divide_duties",           limit: 65535
    t.text     "divide_duties_order",     limit: 65535
    t.integer  "divide_duties_order_int", limit: 4
    t.text     "remarks",                 limit: 65535
    t.text     "personal_state",          limit: 65535
    t.text     "display_state",           limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",            limit: 65535
    t.text     "updated_group",           limit: 65535
    t.datetime "created_at"
    t.text     "created_user",            limit: 65535
    t.text     "created_group",           limit: 65535
  end

  create_table "gwsub_sb04_editable_dates", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.datetime "published_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "headline_at"
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
  end

  create_table "gwsub_sb04_limit_settings", force: :cascade do |t|
    t.string   "type_name",     limit: 255
    t.integer  "limit",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
  end

  create_table "gwsub_sb04_seating_lists", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.text     "title",         limit: 65535
    t.text     "bbs_url",       limit: 65535
    t.text     "remarks",       limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
  end

  create_table "gwsub_sb04_settings", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "type_name",     limit: 255
    t.text     "data",          limit: 65535
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gwsub_sb04_year_copy_logs", force: :cascade do |t|
    t.string   "type",                     limit: 255
    t.integer  "origin_fyear_id",          limit: 4
    t.integer  "origin_section_id",        limit: 4
    t.string   "origin_section_code",      limit: 255
    t.text     "origin_section_name",      limit: 65535
    t.integer  "destination_fyear_id",     limit: 4
    t.integer  "destination_section_id",   limit: 4
    t.string   "destination_section_code", limit: 255
    t.text     "destination_section_name", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",             limit: 65535
    t.text     "created_group",            limit: 65535
  end

  create_table "gwsub_sb04assignedjobs", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.integer  "section_id",    limit: 4
    t.text     "section_code",  limit: 65535
    t.text     "section_name",  limit: 65535
    t.integer  "code_int",      limit: 4
    t.text     "code",          limit: 65535
    t.text     "name",          limit: 65535
    t.text     "tel",           limit: 65535
    t.text     "address",       limit: 65535
    t.text     "remarks",       limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gwsub_sb04helps", force: :cascade do |t|
    t.integer  "categories",    limit: 4
    t.text     "title",         limit: 65535
    t.text     "bbs_url",       limit: 65535
    t.text     "remarks",       limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gwsub_sb04officialtitles", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.integer  "code_int",      limit: 4
    t.text     "code",          limit: 65535
    t.text     "name",          limit: 65535
    t.text     "remarks",       limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gwsub_sb04sections", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.text     "code",          limit: 65535
    t.text     "name",          limit: 65535
    t.text     "remarks",       limit: 65535
    t.text     "bbs_url",       limit: 65535
    t.text     "ldap_code",     limit: 65535
    t.text     "ldap_name",     limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  add_index "gwsub_sb04sections", ["code"], name: "code", length: {"code"=>10}, using: :btree
  add_index "gwsub_sb04sections", ["fyear_id"], name: "fyear_id", using: :btree

  create_table "gwsub_sb04stafflists", force: :cascade do |t|
    t.integer  "fyear_id",                limit: 4
    t.text     "fyear_markjp",            limit: 65535
    t.text     "staff_no",                limit: 65535
    t.text     "multi_section_flg",       limit: 65535
    t.text     "name",                    limit: 65535
    t.text     "name_print",              limit: 65535
    t.text     "kana",                    limit: 65535
    t.integer  "section_id",              limit: 4
    t.text     "section_code",            limit: 65535
    t.text     "section_name",            limit: 65535
    t.integer  "assignedjobs_id",         limit: 4
    t.integer  "assignedjobs_code_int",   limit: 4
    t.text     "assignedjobs_code",       limit: 65535
    t.text     "assignedjobs_name",       limit: 65535
    t.text     "assignedjobs_tel",        limit: 65535
    t.text     "assignedjobs_address",    limit: 65535
    t.integer  "official_title_id",       limit: 4
    t.text     "official_title_code",     limit: 65535
    t.integer  "official_title_code_int", limit: 4
    t.text     "official_title_name",     limit: 65535
    t.integer  "categories_id",           limit: 4
    t.text     "categories_code",         limit: 65535
    t.text     "categories_name",         limit: 65535
    t.text     "extension",               limit: 65535
    t.text     "divide_duties",           limit: 65535
    t.text     "divide_duties_order",     limit: 65535
    t.integer  "divide_duties_order_int", limit: 4
    t.text     "remarks",                 limit: 65535
    t.text     "personal_state",          limit: 65535
    t.text     "display_state",           limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",            limit: 65535
    t.text     "updated_group",           limit: 65535
    t.datetime "created_at"
    t.text     "created_user",            limit: 65535
    t.text     "created_group",           limit: 65535
  end

  add_index "gwsub_sb04stafflists", ["fyear_id"], name: "fyear_id", using: :btree
  add_index "gwsub_sb04stafflists", ["fyear_markjp"], name: "fyear_markjp", length: {"fyear_markjp"=>10}, using: :btree

  create_table "gwsub_sb05_db_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.text     "file_state",        limit: 65535
  end

  create_table "gwsub_sb05_desired_date_conditions", force: :cascade do |t|
    t.integer  "media_id",   limit: 4
    t.boolean  "w1",                   default: false
    t.boolean  "w2",                   default: false
    t.boolean  "w3",                   default: false
    t.boolean  "w4",                   default: false
    t.boolean  "w5",                   default: false
    t.boolean  "d0",                   default: false
    t.boolean  "d1",                   default: false
    t.boolean  "d2",                   default: false
    t.boolean  "d3",                   default: false
    t.boolean  "d4",                   default: false
    t.boolean  "d5",                   default: false
    t.boolean  "d6",                   default: false
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gwsub_sb05_desired_dates", force: :cascade do |t|
    t.integer  "media_id",      limit: 4
    t.datetime "desired_at"
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.text     "media_code",    limit: 65535
    t.text     "weekday",       limit: 65535
    t.text     "monthly",       limit: 65535
    t.datetime "edit_limit_at"
  end

  create_table "gwsub_sb05_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.text     "file_state",        limit: 65535
  end

  create_table "gwsub_sb05_media_types", force: :cascade do |t|
    t.integer  "media_code",      limit: 4
    t.text     "media_name",      limit: 65535
    t.integer  "categories_code", limit: 4
    t.text     "categories_name", limit: 65535
    t.integer  "max_size",        limit: 4
    t.integer  "state",           limit: 4
    t.datetime "updated_at"
    t.text     "updated_user",    limit: 65535
    t.text     "updated_group",   limit: 65535
    t.datetime "created_at"
    t.text     "created_user",    limit: 65535
    t.text     "created_group",   limit: 65535
  end

  create_table "gwsub_sb05_notices", force: :cascade do |t|
    t.integer  "media_id",        limit: 4
    t.integer  "media_code",      limit: 4
    t.text     "media_name",      limit: 65535
    t.integer  "categories_code", limit: 4
    t.text     "categories_name", limit: 65535
    t.text     "sample",          limit: 65535
    t.text     "remarks",         limit: 65535
    t.text     "form_templates",  limit: 65535
    t.text     "admin_remarks",   limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",    limit: 65535
    t.text     "updated_group",   limit: 65535
    t.datetime "created_at"
    t.text     "created_user",    limit: 65535
    t.text     "created_group",   limit: 65535
  end

  create_table "gwsub_sb05_recognizers", force: :cascade do |t|
    t.integer  "parent_id",     limit: 4
    t.integer  "user_id",       limit: 4
    t.text     "recognized_at", limit: 65535
    t.integer  "mode",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gwsub_sb05_requests", force: :cascade do |t|
    t.integer  "sb05_users_id",       limit: 4
    t.text     "user_code",           limit: 65535
    t.text     "user_name",           limit: 65535
    t.text     "user_display",        limit: 65535
    t.text     "org_code",            limit: 65535
    t.text     "org_name",            limit: 65535
    t.text     "org_display",         limit: 65535
    t.text     "telephone",           limit: 65535
    t.integer  "media_id",            limit: 4
    t.integer  "media_code",          limit: 4
    t.text     "media_name",          limit: 65535
    t.integer  "categories_code",     limit: 4
    t.text     "categories_name",     limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "title",               limit: 65535
    t.text     "body1",               limit: 65535
    t.text     "magazine_url",        limit: 65535
    t.text     "magazine_url_mobile", limit: 65535
    t.integer  "mm_attachiment",      limit: 4
    t.text     "img",                 limit: 65535
    t.datetime "contract_at"
    t.datetime "base_at"
    t.text     "magazine_state",      limit: 65535
    t.text     "r_state",             limit: 65535
    t.text     "m_state",             limit: 65535
    t.text     "admin_remarks",       limit: 65535
    t.text     "notes_imported",      limit: 65535
    t.datetime "notes_updated_at"
    t.datetime "updated_at"
    t.text     "updated_user",        limit: 65535
    t.text     "updated_group",       limit: 65535
    t.datetime "created_at"
    t.text     "created_user",        limit: 65535
    t.text     "created_group",       limit: 65535
    t.text     "mm_image_state",      limit: 65535
    t.text     "attaches_file",       limit: 65535
  end

  create_table "gwsub_sb05_users", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "org_id",           limit: 4
    t.text     "user_code",        limit: 65535
    t.text     "user_name",        limit: 65535
    t.text     "user_display",     limit: 65535
    t.text     "org_code",         limit: 65535
    t.text     "org_name",         limit: 65535
    t.text     "org_display",      limit: 65535
    t.text     "telephone",        limit: 65535
    t.text     "notes_imported",   limit: 65535
    t.datetime "notes_updated_at"
    t.datetime "updated_at"
    t.text     "updated_user",     limit: 65535
    t.text     "updated_group",    limit: 65535
    t.datetime "created_at"
    t.text     "created_user",     limit: 65535
    t.text     "created_group",    limit: 65535
  end

  create_table "gwsub_sb06_assigned_conf_categories", force: :cascade do |t|
    t.integer  "cat_sort_no",   limit: 4
    t.text     "cat_code",      limit: 65535
    t.text     "cat_name",      limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.text     "select_list",   limit: 65535
  end

  create_table "gwsub_sb06_assigned_conf_groups", force: :cascade do |t|
    t.integer  "fyear_id",      limit: 4
    t.text     "fyear_markjp",  limit: 65535
    t.integer  "group_id",      limit: 4
    t.text     "group_code",    limit: 65535
    t.text     "group_name",    limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.integer  "categories_id", limit: 4
    t.integer  "cat_sort_no",   limit: 4
    t.text     "cat_code",      limit: 65535
    t.text     "cat_name",      limit: 65535
  end

  create_table "gwsub_sb06_assigned_conf_items", force: :cascade do |t|
    t.integer  "fyear_id",       limit: 4
    t.text     "fyear_markjp",   limit: 65535
    t.integer  "conf_kind_id",   limit: 4
    t.integer  "item_sort_no",   limit: 4
    t.text     "item_title",     limit: 65535
    t.integer  "item_max_count", limit: 4
    t.datetime "created_at"
    t.text     "created_user",   limit: 65535
    t.text     "created_group",  limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",   limit: 65535
    t.text     "updated_group",  limit: 65535
    t.integer  "select_list",    limit: 4
  end

  create_table "gwsub_sb06_assigned_conf_kinds", force: :cascade do |t|
    t.integer  "fyear_id",          limit: 4
    t.text     "fyear_markjp",      limit: 65535
    t.integer  "conf_cat_id",       limit: 4
    t.text     "conf_kind_code",    limit: 65535
    t.text     "conf_kind_name",    limit: 65535
    t.integer  "conf_kind_sort_no", limit: 4
    t.text     "conf_menu_name",    limit: 65535
    t.text     "conf_to_name",      limit: 65535
    t.text     "conf_title",        limit: 65535
    t.text     "conf_form_no",      limit: 65535
    t.integer  "conf_max_count",    limit: 4
    t.datetime "updated_at"
    t.text     "updated_user",      limit: 65535
    t.text     "updated_group",     limit: 65535
    t.datetime "created_at"
    t.text     "created_user",      limit: 65535
    t.text     "created_group",     limit: 65535
    t.integer  "select_list",       limit: 4
    t.text     "conf_body",         limit: 65535
  end

  create_table "gwsub_sb06_assigned_conference_members", force: :cascade do |t|
    t.datetime "created_at"
    t.text     "created_user",         limit: 65535
    t.integer  "created_user_id",      limit: 4
    t.text     "created_group",        limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",         limit: 65535
    t.integer  "updated_user_id",      limit: 4
    t.text     "updated_group",        limit: 65535
    t.integer  "conference_id",        limit: 4
    t.text     "state",                limit: 65535
    t.integer  "categories_id",        limit: 4
    t.integer  "cat_sort_no",          limit: 4
    t.text     "cat_code",             limit: 65535
    t.text     "cat_name",             limit: 65535
    t.integer  "conf_kind_id",         limit: 4
    t.integer  "conf_kind_sort_no",    limit: 4
    t.text     "conf_kind_name",       limit: 65535
    t.integer  "fyear_id",             limit: 4
    t.text     "fyear_markjp",         limit: 65535
    t.text     "fyear_namejp",         limit: 65535
    t.text     "conf_mark",            limit: 65535
    t.text     "conf_no",              limit: 65535
    t.integer  "conf_group_id",        limit: 4
    t.text     "conf_group_code",      limit: 65535
    t.text     "conf_group_name",      limit: 65535
    t.datetime "conf_at"
    t.integer  "section_manager_id",   limit: 4
    t.integer  "group_id",             limit: 4
    t.text     "group_code",           limit: 65535
    t.text     "group_name",           limit: 65535
    t.text     "group_name_display",   limit: 65535
    t.text     "conf_kind_place",      limit: 65535
    t.integer  "conf_item_id",         limit: 4
    t.integer  "conf_item_sort_no",    limit: 4
    t.text     "conf_item_title",      limit: 65535
    t.text     "work_name",            limit: 65535
    t.text     "work_kind",            limit: 65535
    t.integer  "official_title_id",    limit: 4
    t.text     "official_title_name",  limit: 65535
    t.integer  "sort_no",              limit: 4
    t.integer  "user_id",              limit: 4
    t.text     "user_name",            limit: 65535
    t.text     "extension",            limit: 65535
    t.text     "user_mail",            limit: 65535
    t.text     "user_job_name",        limit: 65535
    t.datetime "start_at"
    t.text     "remarks",              limit: 65535
    t.integer  "user_section_id",      limit: 4
    t.text     "user_section_name",    limit: 65535
    t.integer  "user_section_sort_no", limit: 4
    t.integer  "main_group_id",        limit: 4
    t.text     "main_group_name",      limit: 65535
    t.integer  "main_group_sort_no",   limit: 4
  end

  create_table "gwsub_sb06_assigned_conferences", force: :cascade do |t|
    t.datetime "created_at"
    t.text     "created_user",         limit: 65535
    t.integer  "created_user_id",      limit: 4
    t.text     "created_group",        limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",         limit: 65535
    t.integer  "updated_user_id",      limit: 4
    t.text     "updated_group",        limit: 65535
    t.text     "state",                limit: 65535
    t.integer  "categories_id",        limit: 4
    t.integer  "cat_sort_no",          limit: 4
    t.text     "cat_code",             limit: 65535
    t.text     "cat_name",             limit: 65535
    t.integer  "conf_kind_id",         limit: 4
    t.integer  "conf_kind_sort_no",    limit: 4
    t.text     "conf_kind_name",       limit: 65535
    t.integer  "fyear_id",             limit: 4
    t.text     "fyear_markjp",         limit: 65535
    t.text     "fyear_namejp",         limit: 65535
    t.text     "conf_mark",            limit: 65535
    t.text     "conf_no",              limit: 65535
    t.integer  "conf_group_id",        limit: 4
    t.text     "conf_group_code",      limit: 65535
    t.text     "conf_group_name",      limit: 65535
    t.datetime "conf_at"
    t.integer  "section_manager_id",   limit: 4
    t.integer  "group_id",             limit: 4
    t.text     "group_code",           limit: 65535
    t.text     "group_name",           limit: 65535
    t.text     "group_name_display",   limit: 65535
    t.text     "conf_kind_place",      limit: 65535
    t.integer  "conf_item_id",         limit: 4
    t.integer  "conf_item_sort_no",    limit: 4
    t.text     "conf_item_title",      limit: 65535
    t.text     "work_name",            limit: 65535
    t.text     "work_kind",            limit: 65535
    t.integer  "official_title_id",    limit: 4
    t.text     "official_title_name",  limit: 65535
    t.integer  "sort_no",              limit: 4
    t.integer  "user_id",              limit: 4
    t.text     "user_name",            limit: 65535
    t.text     "extension",            limit: 65535
    t.text     "user_mail",            limit: 65535
    t.text     "user_job_name",        limit: 65535
    t.datetime "start_at"
    t.text     "remarks",              limit: 65535
    t.integer  "user_section_id",      limit: 4
    t.text     "user_section_name",    limit: 65535
    t.integer  "user_section_sort_no", limit: 4
    t.integer  "main_group_id",        limit: 4
    t.text     "main_group_name",      limit: 65535
    t.integer  "main_group_sort_no",   limit: 4
    t.integer  "admin_group_id",       limit: 4
    t.text     "admin_group_code",     limit: 65535
    t.text     "admin_group_name",     limit: 65535
  end

  create_table "gwsub_sb06_assigned_helps", force: :cascade do |t|
    t.integer  "help_kind",         limit: 4
    t.integer  "conf_cat_id",       limit: 4
    t.integer  "conf_kind_sort_no", limit: 4
    t.integer  "conf_kind_id",      limit: 4
    t.integer  "fyear_id",          limit: 4
    t.text     "fyear_markjp",      limit: 65535
    t.integer  "conf_group_id",     limit: 4
    t.text     "title",             limit: 65535
    t.text     "bbs_url",           limit: 65535
    t.text     "remarks",           limit: 65535
    t.datetime "created_at"
    t.text     "created_user",      limit: 65535
    t.text     "created_group",     limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",      limit: 65535
    t.text     "updated_group",     limit: 65535
    t.string   "state",             limit: 255
    t.integer  "sort_no",           limit: 4
  end

  create_table "gwsub_sb06_assigned_official_titles", force: :cascade do |t|
    t.text     "official_title_code",    limit: 65535
    t.text     "official_title_name",    limit: 65535
    t.integer  "official_title_sort_no", limit: 4
    t.datetime "created_at"
    t.text     "created_user",           limit: 65535
    t.text     "created_group",          limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",           limit: 65535
    t.text     "updated_group",          limit: 65535
  end

  create_table "gwsub_sb06_budget_assign_admins", force: :cascade do |t|
    t.integer  "group_parent_id",         limit: 4
    t.text     "group_parent_ou",         limit: 65535
    t.text     "group_parent_code",       limit: 65535
    t.text     "group_parent_name",       limit: 65535
    t.integer  "group_id",                limit: 4
    t.text     "group_ou",                limit: 65535
    t.text     "group_code",              limit: 65535
    t.text     "group_name",              limit: 65535
    t.integer  "multi_group_parent_id",   limit: 4
    t.text     "multi_group_parent_ou",   limit: 65535
    t.text     "multi_group_parent_code", limit: 65535
    t.text     "multi_group_parent_name", limit: 65535
    t.integer  "multi_group_id",          limit: 4
    t.text     "multi_group_ou",          limit: 65535
    t.text     "multi_group_code",        limit: 65535
    t.text     "multi_group_name",        limit: 65535
    t.text     "multi_sequence",          limit: 65535
    t.text     "multi_user_code",         limit: 65535
    t.integer  "user_id",                 limit: 4
    t.text     "user_code",               limit: 65535
    t.text     "user_name",               limit: 65535
    t.integer  "budget_role_id",          limit: 4
    t.text     "budget_role_code",        limit: 65535
    t.text     "budget_role_name",        limit: 65535
    t.text     "admin_state",             limit: 65535
    t.text     "main_state",              limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",            limit: 65535
    t.text     "updated_group",           limit: 65535
    t.datetime "created_at"
    t.text     "created_user",            limit: 65535
    t.text     "created_group",           limit: 65535
  end

  create_table "gwsub_sb06_budget_assign_mains", force: :cascade do |t|
    t.integer  "group_parent_id",         limit: 4
    t.text     "group_parent_ou",         limit: 65535
    t.text     "group_parent_code",       limit: 65535
    t.text     "group_parent_name",       limit: 65535
    t.integer  "group_id",                limit: 4
    t.text     "group_ou",                limit: 65535
    t.text     "group_code",              limit: 65535
    t.text     "group_name",              limit: 65535
    t.integer  "multi_group_parent_id",   limit: 4
    t.text     "multi_group_parent_ou",   limit: 65535
    t.text     "multi_group_parent_code", limit: 65535
    t.text     "multi_group_parent_name", limit: 65535
    t.integer  "multi_group_id",          limit: 4
    t.text     "multi_group_ou",          limit: 65535
    t.text     "multi_group_code",        limit: 65535
    t.text     "multi_group_name",        limit: 65535
    t.text     "multi_sequence",          limit: 65535
    t.text     "multi_user_code",         limit: 65535
    t.integer  "user_id",                 limit: 4
    t.text     "user_code",               limit: 65535
    t.text     "user_name",               limit: 65535
    t.integer  "budget_role_id",          limit: 4
    t.text     "budget_role_code",        limit: 65535
    t.text     "budget_role_name",        limit: 65535
    t.text     "admin_state",             limit: 65535
    t.text     "main_state",              limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",            limit: 65535
    t.text     "updated_group",           limit: 65535
    t.datetime "created_at"
    t.text     "created_user",            limit: 65535
    t.text     "created_group",           limit: 65535
  end

  create_table "gwsub_sb06_budget_assigns", force: :cascade do |t|
    t.integer  "group_parent_id",         limit: 4
    t.text     "group_parent_ou",         limit: 65535
    t.text     "group_parent_code",       limit: 65535
    t.text     "group_parent_name",       limit: 65535
    t.integer  "group_id",                limit: 4
    t.text     "group_ou",                limit: 65535
    t.text     "group_code",              limit: 65535
    t.text     "group_name",              limit: 65535
    t.integer  "multi_group_parent_id",   limit: 4
    t.text     "multi_group_parent_ou",   limit: 65535
    t.text     "multi_group_parent_code", limit: 65535
    t.text     "multi_group_parent_name", limit: 65535
    t.integer  "multi_group_id",          limit: 4
    t.text     "multi_group_ou",          limit: 65535
    t.text     "multi_group_code",        limit: 65535
    t.text     "multi_group_name",        limit: 65535
    t.text     "multi_sequence",          limit: 65535
    t.text     "multi_user_code",         limit: 65535
    t.integer  "user_id",                 limit: 4
    t.text     "user_code",               limit: 65535
    t.text     "user_name",               limit: 65535
    t.integer  "budget_role_id",          limit: 4
    t.text     "budget_role_code",        limit: 65535
    t.text     "budget_role_name",        limit: 65535
    t.text     "admin_state",             limit: 65535
    t.text     "main_state",              limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",            limit: 65535
    t.text     "updated_group",           limit: 65535
    t.datetime "created_at"
    t.text     "created_user",            limit: 65535
    t.text     "created_group",           limit: 65535
  end

  create_table "gwsub_sb06_budget_editable_dates", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "recognize_at"
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
  end

  create_table "gwsub_sb06_budget_notices", force: :cascade do |t|
    t.text     "kind",          limit: 65535
    t.text     "title",         limit: 65535
    t.text     "bbs_url",       limit: 65535
    t.text     "remarks",       limit: 65535
    t.text     "state",         limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
  end

  create_table "gwsub_sb06_budget_roles", force: :cascade do |t|
    t.text     "code",          limit: 65535
    t.text     "name",          limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
  end

  create_table "gwsub_sb06_recognizers", force: :cascade do |t|
    t.integer  "parent_id",     limit: 4
    t.integer  "user_id",       limit: 4
    t.text     "recognized_at", limit: 65535
    t.integer  "mode",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gwsub_sb12_groups", force: :cascade do |t|
    t.text     "state",             limit: 65535
    t.string   "code",              limit: 255
    t.text     "name",              limit: 65535
    t.integer  "sort_no",           limit: 4
    t.integer  "ldap",              limit: 4
    t.datetime "latest_updated_at"
  end

  create_table "gwsub_sb13_groups", force: :cascade do |t|
    t.text     "state",             limit: 65535
    t.string   "code",              limit: 255
    t.text     "name",              limit: 65535
    t.integer  "sort_no",           limit: 4
    t.integer  "ldap",              limit: 4
    t.datetime "latest_updated_at"
  end

  create_table "gwworkflow_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
  end

  create_table "intra_maintenances", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.text     "state",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title",        limit: 65535
    t.text     "body",         limit: 65535
  end

  create_table "intra_messages", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.text     "state",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title",        limit: 65535
    t.text     "body",         limit: 65535
  end

  create_table "questionnaire_bases", force: :cascade do |t|
    t.integer  "unid",                limit: 4
    t.integer  "content_id",          limit: 4
    t.text     "state",               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section_code",        limit: 255
    t.string   "section_name",        limit: 255
    t.integer  "section_sort",        limit: 4
    t.boolean  "enquete_division"
    t.integer  "admin_setting",       limit: 4
    t.string   "manage_title",        limit: 255
    t.string   "title",               limit: 255
    t.text     "form_body",           limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "spec_config",         limit: 4
    t.string   "send_change",         limit: 255
    t.text     "remarks",             limit: 65535
    t.text     "remarks_setting",     limit: 65535
    t.integer  "send_to",             limit: 4
    t.integer  "send_to_kind",        limit: 4
    t.text     "createdate",          limit: 65535
    t.string   "createrdivision_id",  limit: 20
    t.text     "createrdivision",     limit: 65535
    t.string   "creater_id",          limit: 20
    t.text     "creater",             limit: 65535
    t.text     "editdate",            limit: 65535
    t.string   "editordivision_id",   limit: 20
    t.text     "editordivision",      limit: 65535
    t.string   "editor_id",           limit: 20
    t.text     "editor",              limit: 65535
    t.text     "custom_groups",       limit: 65535
    t.text     "custom_groups_json",  limit: 65535
    t.text     "reader_groups",       limit: 65535
    t.text     "reader_groups_json",  limit: 65535
    t.text     "custom_readers",      limit: 65535
    t.text     "custom_readers_json", limit: 65535
    t.text     "readers",             limit: 65535
    t.text     "readers_json",        limit: 65535
    t.integer  "default_limit",       limit: 4
    t.integer  "answer_count",        limit: 4
    t.boolean  "include_index"
    t.boolean  "result_open_state"
    t.string   "keycode",             limit: 255
  end

  create_table "questionnaire_field_options", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.integer  "content_id",   limit: 4
    t.text     "state",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.integer  "field_id",     limit: 4
    t.integer  "sort_no",      limit: 4
    t.string   "value",        limit: 255
    t.text     "title",        limit: 65535
  end

  create_table "questionnaire_form_fields", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "sort_no",           limit: 4
    t.string   "question_type",     limit: 255
    t.string   "title",             limit: 255
    t.string   "field_cols",        limit: 255
    t.string   "field_rows",        limit: 255
    t.integer  "post_permit_base",  limit: 4
    t.integer  "post_permit",       limit: 4
    t.string   "post_permit_value", limit: 255
    t.text     "option_body",       limit: 65535
    t.string   "field_name",        limit: 255
    t.integer  "view_type",         limit: 4
    t.integer  "required_entry",    limit: 4
    t.boolean  "auto_number_state"
    t.integer  "auto_number",       limit: 4
    t.integer  "group_code",        limit: 4
    t.string   "group_field",       limit: 255
    t.text     "group_body",        limit: 65535
    t.integer  "group_repeat",      limit: 4
    t.text     "group_name",        limit: 65535
  end

  create_table "questionnaire_itemdeletes", force: :cascade do |t|
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code", limit: 255
    t.string   "limit_date", limit: 255
  end

  create_table "questionnaire_previews", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",          limit: 4
    t.text     "field_001",          limit: 65535
    t.text     "field_002",          limit: 65535
    t.text     "field_003",          limit: 65535
    t.text     "field_004",          limit: 65535
    t.text     "field_005",          limit: 65535
    t.text     "field_006",          limit: 65535
    t.text     "field_007",          limit: 65535
    t.text     "field_008",          limit: 65535
    t.text     "field_009",          limit: 65535
    t.text     "field_010",          limit: 65535
    t.text     "field_011",          limit: 65535
    t.text     "field_012",          limit: 65535
    t.text     "field_013",          limit: 65535
    t.text     "field_014",          limit: 65535
    t.text     "field_015",          limit: 65535
    t.text     "field_016",          limit: 65535
    t.text     "field_017",          limit: 65535
    t.text     "field_018",          limit: 65535
    t.text     "field_019",          limit: 65535
    t.text     "field_020",          limit: 65535
    t.text     "field_021",          limit: 65535
    t.text     "field_022",          limit: 65535
    t.text     "field_023",          limit: 65535
    t.text     "field_024",          limit: 65535
    t.text     "field_025",          limit: 65535
    t.text     "field_026",          limit: 65535
    t.text     "field_027",          limit: 65535
    t.text     "field_028",          limit: 65535
    t.text     "field_029",          limit: 65535
    t.text     "field_030",          limit: 65535
    t.text     "field_031",          limit: 65535
    t.text     "field_032",          limit: 65535
    t.text     "field_033",          limit: 65535
    t.text     "field_034",          limit: 65535
    t.text     "field_035",          limit: 65535
    t.text     "field_036",          limit: 65535
    t.text     "field_037",          limit: 65535
    t.text     "field_038",          limit: 65535
    t.text     "field_039",          limit: 65535
    t.text     "field_040",          limit: 65535
    t.text     "field_041",          limit: 65535
    t.text     "field_042",          limit: 65535
    t.text     "field_043",          limit: 65535
    t.text     "field_044",          limit: 65535
    t.text     "field_045",          limit: 65535
    t.text     "field_046",          limit: 65535
    t.text     "field_047",          limit: 65535
    t.text     "field_048",          limit: 65535
    t.text     "field_049",          limit: 65535
    t.text     "field_050",          limit: 65535
    t.text     "field_051",          limit: 65535
    t.text     "field_052",          limit: 65535
    t.text     "field_053",          limit: 65535
    t.text     "field_054",          limit: 65535
    t.text     "field_055",          limit: 65535
    t.text     "field_056",          limit: 65535
    t.text     "field_057",          limit: 65535
    t.text     "field_058",          limit: 65535
    t.text     "field_059",          limit: 65535
    t.text     "field_060",          limit: 65535
    t.text     "field_061",          limit: 65535
    t.text     "field_062",          limit: 65535
    t.text     "field_063",          limit: 65535
    t.text     "field_064",          limit: 65535
    t.text     "createdate",         limit: 65535
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
  end

  create_table "questionnaire_results", force: :cascade do |t|
    t.integer  "unid",           limit: 4
    t.integer  "content_id",     limit: 4
    t.text     "state",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",       limit: 4
    t.integer  "field_id",       limit: 4
    t.string   "question_type",  limit: 255
    t.text     "question_label", limit: 65535
    t.integer  "option_id",      limit: 4
    t.text     "option_label",   limit: 65535
    t.integer  "sort_no",        limit: 4
    t.integer  "answer_count",   limit: 4
    t.decimal  "answer_ratio",                 precision: 10, scale: 5
  end

  create_table "questionnaire_template_bases", force: :cascade do |t|
    t.integer  "unid",                limit: 4
    t.integer  "content_id",          limit: 4
    t.text     "state",               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section_code",        limit: 255
    t.string   "section_name",        limit: 255
    t.integer  "section_sort",        limit: 4
    t.boolean  "enquete_division"
    t.integer  "admin_setting",       limit: 4
    t.string   "manage_title",        limit: 255
    t.string   "title",               limit: 255
    t.text     "form_body",           limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "spec_config",         limit: 4
    t.string   "send_change",         limit: 255
    t.text     "createdate",          limit: 65535
    t.string   "createrdivision_id",  limit: 20
    t.text     "createrdivision",     limit: 65535
    t.string   "creater_id",          limit: 20
    t.text     "creater",             limit: 65535
    t.text     "editdate",            limit: 65535
    t.string   "editordivision_id",   limit: 20
    t.text     "editordivision",      limit: 65535
    t.string   "editor_id",           limit: 20
    t.text     "editor",              limit: 65535
    t.text     "custom_groups",       limit: 65535
    t.text     "custom_groups_json",  limit: 65535
    t.text     "reader_groups",       limit: 65535
    t.text     "reader_groups_json",  limit: 65535
    t.text     "custom_readers",      limit: 65535
    t.text     "custom_readers_json", limit: 65535
    t.text     "readers",             limit: 65535
    t.text     "readers_json",        limit: 65535
    t.integer  "default_limit",       limit: 4
  end

  create_table "questionnaire_template_field_options", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.integer  "content_id",   limit: 4
    t.text     "state",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.integer  "field_id",     limit: 4
    t.integer  "sort_no",      limit: 4
    t.string   "value",        limit: 255
    t.text     "title",        limit: 65535
  end

  create_table "questionnaire_template_form_fields", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "sort_no",           limit: 4
    t.string   "question_type",     limit: 255
    t.string   "title",             limit: 255
    t.string   "field_cols",        limit: 255
    t.string   "field_rows",        limit: 255
    t.integer  "post_permit_base",  limit: 4
    t.integer  "post_permit",       limit: 4
    t.string   "post_permit_value", limit: 255
    t.text     "option_body",       limit: 65535
    t.string   "field_name",        limit: 255
    t.integer  "view_type",         limit: 4
    t.integer  "required_entry",    limit: 4
    t.boolean  "auto_number_state"
    t.integer  "auto_number",       limit: 4
    t.integer  "group_code",        limit: 4
    t.string   "group_field",       limit: 255
    t.text     "group_body",        limit: 65535
    t.integer  "group_repeat",      limit: 4
    t.text     "group_name",        limit: 65535
  end

  create_table "questionnaire_template_previews", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",          limit: 4
    t.text     "field_001",          limit: 65535
    t.text     "field_002",          limit: 65535
    t.text     "field_003",          limit: 65535
    t.text     "field_004",          limit: 65535
    t.text     "field_005",          limit: 65535
    t.text     "field_006",          limit: 65535
    t.text     "field_007",          limit: 65535
    t.text     "field_008",          limit: 65535
    t.text     "field_009",          limit: 65535
    t.text     "field_010",          limit: 65535
    t.text     "field_011",          limit: 65535
    t.text     "field_012",          limit: 65535
    t.text     "field_013",          limit: 65535
    t.text     "field_014",          limit: 65535
    t.text     "field_015",          limit: 65535
    t.text     "field_016",          limit: 65535
    t.text     "field_017",          limit: 65535
    t.text     "field_018",          limit: 65535
    t.text     "field_019",          limit: 65535
    t.text     "field_020",          limit: 65535
    t.text     "field_021",          limit: 65535
    t.text     "field_022",          limit: 65535
    t.text     "field_023",          limit: 65535
    t.text     "field_024",          limit: 65535
    t.text     "field_025",          limit: 65535
    t.text     "field_026",          limit: 65535
    t.text     "field_027",          limit: 65535
    t.text     "field_028",          limit: 65535
    t.text     "field_029",          limit: 65535
    t.text     "field_030",          limit: 65535
    t.text     "field_031",          limit: 65535
    t.text     "field_032",          limit: 65535
    t.text     "field_033",          limit: 65535
    t.text     "field_034",          limit: 65535
    t.text     "field_035",          limit: 65535
    t.text     "field_036",          limit: 65535
    t.text     "field_037",          limit: 65535
    t.text     "field_038",          limit: 65535
    t.text     "field_039",          limit: 65535
    t.text     "field_040",          limit: 65535
    t.text     "field_041",          limit: 65535
    t.text     "field_042",          limit: 65535
    t.text     "field_043",          limit: 65535
    t.text     "field_044",          limit: 65535
    t.text     "field_045",          limit: 65535
    t.text     "field_046",          limit: 65535
    t.text     "field_047",          limit: 65535
    t.text     "field_048",          limit: 65535
    t.text     "field_049",          limit: 65535
    t.text     "field_050",          limit: 65535
    t.text     "field_051",          limit: 65535
    t.text     "field_052",          limit: 65535
    t.text     "field_053",          limit: 65535
    t.text     "field_054",          limit: 65535
    t.text     "field_055",          limit: 65535
    t.text     "field_056",          limit: 65535
    t.text     "field_057",          limit: 65535
    t.text     "field_058",          limit: 65535
    t.text     "field_059",          limit: 65535
    t.text     "field_060",          limit: 65535
    t.text     "field_061",          limit: 65535
    t.text     "field_062",          limit: 65535
    t.text     "field_063",          limit: 65535
    t.text     "field_064",          limit: 65535
    t.text     "createdate",         limit: 65535
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
  end

  create_table "questionnaire_temporaries", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.integer  "content_id",    limit: 4
    t.text     "state",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",      limit: 4
    t.integer  "field_id",      limit: 4
    t.string   "question_type", limit: 255
    t.text     "answer_text",   limit: 65535
    t.integer  "answer_option", limit: 4
  end

  add_index "questionnaire_temporaries", ["title_id"], name: "title_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "system_custom_group_roles", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",        limit: 4
    t.integer  "custom_group_id", limit: 4
    t.text     "priv_name",       limit: 65535
    t.integer  "user_id",         limit: 4
    t.integer  "class_id",        limit: 4
  end

  add_index "system_custom_group_roles", ["custom_group_id"], name: "custom_group_id", using: :btree
  add_index "system_custom_group_roles", ["group_id"], name: "group_id", using: :btree
  add_index "system_custom_group_roles", ["user_id"], name: "user_id", using: :btree

  create_table "system_custom_groups", force: :cascade do |t|
    t.integer  "parent_id",   limit: 4
    t.integer  "class_id",    limit: 4
    t.integer  "owner_uid",   limit: 4
    t.integer  "owner_gid",   limit: 4
    t.integer  "updater_uid", limit: 4,     null: false
    t.integer  "updater_gid", limit: 4,     null: false
    t.text     "state",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",    limit: 4
    t.text     "name",        limit: 65535
    t.text     "name_en",     limit: 65535
    t.integer  "sort_no",     limit: 4
    t.text     "sort_prefix", limit: 65535
    t.integer  "is_default",  limit: 4
  end

  create_table "system_group_change_dates", force: :cascade do |t|
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "deleted_at"
    t.text     "deleted_user",  limit: 65535
    t.text     "deleted_group", limit: 65535
    t.datetime "start_at"
  end

  create_table "system_group_histories", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "state",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",     limit: 4
    t.integer  "version_id",   limit: 4
    t.string   "code",         limit: 255
    t.text     "name",         limit: 65535
    t.text     "name_en",      limit: 65535
    t.text     "group_s_name", limit: 65535
    t.text     "email",        limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no",      limit: 4
    t.string   "ldap_version", limit: 255
    t.integer  "ldap",         limit: 4
  end

  create_table "system_group_history_temporaries", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "state",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",     limit: 4
    t.integer  "version_id",   limit: 4
    t.string   "code",         limit: 255
    t.text     "name",         limit: 65535
    t.text     "name_en",      limit: 65535
    t.text     "group_s_name", limit: 65535
    t.text     "email",        limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no",      limit: 4
    t.string   "ldap_version", limit: 255
    t.integer  "ldap",         limit: 4
  end

  create_table "system_group_nexts", force: :cascade do |t|
    t.integer  "group_update_id", limit: 4
    t.text     "operation",       limit: 65535
    t.integer  "old_group_id",    limit: 4
    t.text     "old_code",        limit: 65535
    t.text     "old_name",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "old_parent_id",   limit: 4
  end

  create_table "system_group_temporaries", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "state",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",     limit: 4
    t.integer  "version_id",   limit: 4
    t.string   "code",         limit: 255
    t.text     "name",         limit: 65535
    t.text     "name_en",      limit: 65535
    t.text     "group_s_name", limit: 65535
    t.text     "email",        limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no",      limit: 4
    t.string   "ldap_version", limit: 255
    t.integer  "ldap",         limit: 4
  end

  create_table "system_group_updates", force: :cascade do |t|
    t.text     "parent_code", limit: 65535
    t.text     "parent_name", limit: 65535
    t.integer  "level_no",    limit: 4
    t.text     "code",        limit: 65535
    t.text     "name",        limit: 65535
    t.text     "state",       limit: 65535
    t.datetime "start_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",    limit: 4
    t.integer  "parent_id",   limit: 4
  end

  create_table "system_groups", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "state",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",     limit: 4
    t.integer  "version_id",   limit: 4
    t.string   "code",         limit: 255
    t.text     "name",         limit: 65535
    t.text     "name_en",      limit: 65535
    t.text     "group_s_name", limit: 65535
    t.text     "email",        limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no",      limit: 4
    t.string   "ldap_version", limit: 255
    t.integer  "ldap",         limit: 4
  end

  add_index "system_groups", ["code"], name: "index_system_groups_on_code", using: :btree
  add_index "system_groups", ["ldap"], name: "index_system_groups_on_ldap", using: :btree
  add_index "system_groups", ["state"], name: "index_system_groups_on_state", using: :btree

  create_table "system_ldap_temporaries", force: :cascade do |t|
    t.integer  "parent_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version",           limit: 255
    t.string   "data_type",         limit: 255
    t.string   "code",              limit: 255
    t.string   "sort_no",           limit: 255
    t.text     "name",              limit: 65535
    t.text     "name_en",           limit: 65535
    t.text     "group_s_name",      limit: 65535
    t.text     "kana",              limit: 65535
    t.text     "email",             limit: 65535
    t.text     "match",             limit: 65535
    t.string   "official_position", limit: 255
    t.string   "assigned_job",      limit: 255
  end

  add_index "system_ldap_temporaries", ["version", "parent_id", "data_type", "sort_no"], name: "version", length: {"version"=>20, "parent_id"=>nil, "data_type"=>20, "sort_no"=>nil}, using: :btree
  add_index "system_ldap_temporaries", ["version"], name: "index_system_ldap_temporaries_on_version", using: :btree

  create_table "system_login_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_login_logs", ["user_id"], name: "user_id", using: :btree

  create_table "system_priv_names", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.text     "state",        limit: 65535
    t.integer  "content_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name", limit: 65535
    t.text     "priv_name",    limit: 65535
    t.integer  "sort_no",      limit: 4
  end

  create_table "system_product_synchro_plans", force: :cascade do |t|
    t.string   "state",       limit: 255
    t.datetime "start_at"
    t.text     "product_ids", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_product_synchro_plans", ["state", "start_at"], name: "index_system_product_synchro_plans_on_state_and_start_at", using: :btree

  create_table "system_product_synchros", force: :cascade do |t|
    t.integer  "product_id",  limit: 4
    t.integer  "plan_id",     limit: 4
    t.string   "state",       limit: 255
    t.string   "version",     limit: 255
    t.text     "remark_temp", limit: 65535
    t.text     "remark_back", limit: 65535
    t.text     "remark_sync", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_product_synchros", ["plan_id"], name: "index_system_product_synchros_on_plan_id", using: :btree
  add_index "system_product_synchros", ["product_id"], name: "index_system_product_synchros_on_product_id", using: :btree
  add_index "system_product_synchros", ["state"], name: "index_system_product_synchros_on_state", using: :btree

  create_table "system_products", force: :cascade do |t|
    t.string   "product_type",    limit: 255
    t.string   "name",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no",         limit: 4,     default: 0
    t.integer  "product_synchro", limit: 1,     default: 0
    t.integer  "sso",             limit: 1,     default: 0
    t.text     "sso_url",         limit: 65535
    t.text     "sso_url_mobile",  limit: 65535
  end

  add_index "system_products", ["product_type"], name: "index_system_products_on_product_type", using: :btree

  create_table "system_recognitions", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "after_process", limit: 65535
  end

  create_table "system_recognizers", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.datetime "updated_at"
    t.datetime "created_at"
    t.text     "name",          limit: 65535, null: false
    t.integer  "user_id",       limit: 4
    t.datetime "recognized_at"
  end

  create_table "system_role_developers", force: :cascade do |t|
    t.integer  "idx",          limit: 4
    t.integer  "class_id",     limit: 4
    t.string   "uid",          limit: 255
    t.integer  "priv",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_name_id", limit: 4
    t.text     "table_name",   limit: 65535
    t.text     "priv_name",    limit: 65535
    t.integer  "priv_user_id", limit: 4
  end

  create_table "system_role_name_privs", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.integer  "priv_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_role_name_privs", ["priv_id"], name: "index_system_role_name_privs_on_priv_id", using: :btree
  add_index "system_role_name_privs", ["role_id"], name: "index_system_role_name_privs_on_role_id", using: :btree

  create_table "system_role_names", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.text     "state",        limit: 65535
    t.integer  "content_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name", limit: 65535
    t.text     "table_name",   limit: 65535
    t.integer  "sort_no",      limit: 4
  end

  create_table "system_roles", force: :cascade do |t|
    t.string   "table_name",   limit: 255
    t.string   "priv_name",    limit: 255
    t.integer  "idx",          limit: 4
    t.integer  "class_id",     limit: 4
    t.string   "uid",          limit: 255
    t.integer  "priv",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_name_id", limit: 4
    t.integer  "priv_user_id", limit: 4
    t.integer  "group_id",     limit: 4
  end

  add_index "system_roles", ["table_name", "priv_name", "class_id", "uid", "idx"], name: "index_system_roles_on_table_name_and_priv_name_and_class_id_and", using: :btree

  create_table "system_sequences", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "name",       limit: 65535
    t.integer  "version",    limit: 4
    t.integer  "value",      limit: 4
  end

  create_table "system_user_temporaries", force: :cascade do |t|
    t.string   "air_login_id",              limit: 255
    t.text     "state",                     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                      limit: 255,   null: false
    t.integer  "ldap",                      limit: 4,     null: false
    t.integer  "ldap_version",              limit: 4
    t.text     "auth_no",                   limit: 65535
    t.string   "sort_no",                   limit: 255
    t.text     "name",                      limit: 65535
    t.text     "name_en",                   limit: 65535
    t.text     "kana",                      limit: 65535
    t.text     "password",                  limit: 65535
    t.integer  "mobile_access",             limit: 4
    t.string   "mobile_password",           limit: 255
    t.text     "email",                     limit: 65535
    t.string   "official_position",         limit: 255
    t.string   "assigned_job",              limit: 255
    t.text     "remember_token",            limit: 65535
    t.datetime "remember_token_expires_at"
    t.text     "air_token",                 limit: 65535
  end

  add_index "system_user_temporaries", ["code"], name: "unique_user_code", unique: true, using: :btree

  create_table "system_users", force: :cascade do |t|
    t.string   "air_login_id",              limit: 255
    t.string   "state",                     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                      limit: 255,   null: false
    t.integer  "ldap",                      limit: 4,     null: false
    t.integer  "ldap_version",              limit: 4
    t.text     "auth_no",                   limit: 65535
    t.string   "sort_no",                   limit: 255
    t.text     "name",                      limit: 65535
    t.text     "name_en",                   limit: 65535
    t.text     "group_s_name",              limit: 65535
    t.text     "kana",                      limit: 65535
    t.text     "password",                  limit: 65535
    t.integer  "mobile_access",             limit: 4
    t.string   "mobile_password",           limit: 255
    t.text     "email",                     limit: 65535
    t.string   "official_position",         limit: 255
    t.string   "assigned_job",              limit: 255
    t.text     "remember_token",            limit: 65535
    t.datetime "remember_token_expires_at"
    t.text     "air_token",                 limit: 65535
  end

  add_index "system_users", ["code"], name: "unique_user_code", unique: true, using: :btree
  add_index "system_users", ["ldap"], name: "index_system_users_on_ldap", using: :btree
  add_index "system_users", ["state"], name: "index_system_users_on_state", using: :btree

  create_table "system_users_custom_groups", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "custom_group_id", limit: 4
    t.integer  "user_id",         limit: 4
    t.text     "title",           limit: 65535
    t.text     "title_en",        limit: 65535
    t.integer  "sort_no",         limit: 4
    t.text     "icon",            limit: 65535
  end

  add_index "system_users_custom_groups", ["custom_group_id"], name: "custom_group_id", using: :btree

  create_table "system_users_group_histories", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
    t.integer  "job_order",  limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code",  limit: 255
    t.string   "group_code", limit: 255
  end

  create_table "system_users_group_history_temporaries", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
    t.integer  "job_order",  limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code",  limit: 255
    t.string   "group_code", limit: 255
  end

  create_table "system_users_group_temporaries", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
    t.integer  "job_order",  limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code",  limit: 255
    t.string   "group_code", limit: 255
  end

  create_table "system_users_groups", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
    t.integer  "job_order",  limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code",  limit: 255
    t.string   "group_code", limit: 255
  end

  add_index "system_users_groups", ["group_id"], name: "index_system_users_groups_on_group_id", using: :btree
  add_index "system_users_groups", ["user_id"], name: "index_system_users_groups_on_user_id", using: :btree

  create_table "system_users_groups_csvdata", force: :cascade do |t|
    t.string   "state",             limit: 255,   null: false
    t.string   "data_type",         limit: 255,   null: false
    t.integer  "level_no",          limit: 4
    t.integer  "parent_id",         limit: 4,     null: false
    t.string   "parent_code",       limit: 255,   null: false
    t.string   "code",              limit: 255,   null: false
    t.integer  "sort_no",           limit: 4
    t.integer  "ldap",              limit: 4,     null: false
    t.integer  "job_order",         limit: 4
    t.text     "name",              limit: 65535, null: false
    t.text     "name_en",           limit: 65535
    t.text     "kana",              limit: 65535
    t.string   "password",          limit: 255
    t.integer  "mobile_access",     limit: 4
    t.string   "mobile_password",   limit: 255
    t.string   "email",             limit: 255
    t.string   "official_position", limit: 255
    t.string   "assigned_job",      limit: 255
    t.datetime "start_at",                        null: false
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
