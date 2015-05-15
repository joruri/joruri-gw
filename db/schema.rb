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

ActiveRecord::Schema.define(version: 20150515074132) do

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "digitallibrary_adms", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "digitallibrary_adms", ["title_id"], name: "index_digitallibrary_adms_on_title_id", using: :btree

  create_table "digitallibrary_controls", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                 precision: 17, scale: 0
    t.decimal  "upload_document_file_size_currently",                precision: 17, scale: 0
    t.string   "create_section"
    t.integer  "addnew_forbidden"
    t.integer  "draft_forbidden"
    t.integer  "delete_forbidden"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          limit: 1
    t.string   "left_index_bg_color"
    t.string   "default_folder"
    t.text     "other_system_link"
    t.text     "wallpaper"
    t.text     "css"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.integer  "notification"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "separator_str1"
    t.string   "separator_str2"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",                              limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision"
    t.string   "editor_id",                               limit: 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.datetime "docslast_updated_at"
  end

  add_index "digitallibrary_controls", ["notification"], name: "index_digitallibrary_controls_on_notification", using: :btree

  create_table "digitallibrary_db_files", force: true do |t|
    t.integer "title_id"
    t.integer "parent_id"
    t.binary  "data",      limit: 2147483647
    t.integer "serial_no"
    t.integer "migrated"
  end

  add_index "digitallibrary_db_files", ["parent_id"], name: "index_digitallibrary_db_files_on_parent_id", using: :btree
  add_index "digitallibrary_db_files", ["title_id"], name: "index_digitallibrary_db_files_on_title_id", using: :btree

  create_table "digitallibrary_docs", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "display_order"
    t.integer  "doc_alias"
    t.integer  "title_id"
    t.integer  "chg_parent_id"
    t.integer  "sort_no"
    t.float    "seq_no",             limit: 24
    t.integer  "order_no"
    t.string   "seq_name"
    t.integer  "level_no"
    t.string   "section_code"
    t.text     "section_name"
    t.text     "name"
    t.text     "title"
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keywords",           limit: 16777215
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "notes_001"
    t.integer  "attachmentfile"
    t.integer  "wiki"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "digitallibrary_docs", ["display_order", "sort_no"], name: "display_order", using: :btree
  add_index "digitallibrary_docs", ["level_no", "display_order", "sort_no", "id"], name: "level_no", using: :btree
  add_index "digitallibrary_docs", ["parent_id"], name: "parent_id", using: :btree
  add_index "digitallibrary_docs", ["state"], name: "state", length: {"state"=>30}, using: :btree
  add_index "digitallibrary_docs", ["title_id"], name: "index_digitallibrary_docs_on_title_id", using: :btree

  create_table "digitallibrary_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "digitallibrary_files", ["parent_id"], name: "index_digitallibrary_files_on_parent_id", using: :btree
  add_index "digitallibrary_files", ["title_id"], name: "index_digitallibrary_files_on_title_id", using: :btree

  create_table "digitallibrary_images", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.text     "parent_name"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  add_index "digitallibrary_images", ["parent_id"], name: "index_digitallibrary_images_on_parent_id", using: :btree
  add_index "digitallibrary_images", ["title_id"], name: "index_digitallibrary_images_on_title_id", using: :btree

  create_table "digitallibrary_recognizers", force: true do |t|
    t.integer  "unid"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "code"
    t.text     "name"
    t.datetime "recognized_at"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "digitallibrary_recognizers", ["parent_id"], name: "index_digitallibrary_recognizers_on_parent_id", using: :btree
  add_index "digitallibrary_recognizers", ["title_id"], name: "index_digitallibrary_recognizers_on_title_id", using: :btree

  create_table "digitallibrary_roles", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.string   "role_code"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "digitallibrary_roles", ["title_id"], name: "index_digitallibrary_roles_on_title_id", using: :btree

  create_table "doclibrary_adms", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "doclibrary_adms", ["title_id"], name: "index_doclibrary_adms_on_title_id", using: :btree

  create_table "doclibrary_categories", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "parent_id"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.text     "wareki"
    t.integer  "nen"
    t.integer  "gatsu"
    t.integer  "sono"
    t.integer  "sono2"
    t.string   "filename"
    t.string   "note_id"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "doclibrary_categories", ["title_id"], name: "index_doclibrary_categories_on_title_id", using: :btree

  create_table "doclibrary_controls", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                 precision: 17, scale: 0
    t.decimal  "upload_document_file_size_currently",                precision: 17, scale: 0
    t.string   "create_section"
    t.integer  "addnew_forbidden"
    t.integer  "draft_forbidden"
    t.integer  "delete_forbidden"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          limit: 1
    t.string   "left_index_bg_color"
    t.string   "default_folder"
    t.text     "other_system_link"
    t.text     "wallpaper"
    t.text     "css"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.integer  "notification"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",                              limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision"
    t.string   "editor_id",                               limit: 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.text     "special_link"
    t.datetime "docslast_updated_at"
  end

  add_index "doclibrary_controls", ["notification"], name: "index_doclibrary_controls_on_notification", using: :btree

  create_table "doclibrary_db_files", force: true do |t|
    t.integer "title_id"
    t.integer "parent_id"
    t.binary  "data",      limit: 2147483647
    t.integer "serial_no"
    t.integer "migrated"
  end

  add_index "doclibrary_db_files", ["parent_id"], name: "index_doclibrary_db_files_on_parent_id", using: :btree
  add_index "doclibrary_db_files", ["title_id"], name: "index_doclibrary_db_files_on_title_id", using: :btree

  create_table "doclibrary_docs", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.text     "content_state"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "importance"
    t.integer  "one_line_note"
    t.integer  "title_id"
    t.text     "name"
    t.text     "pname"
    t.text     "title"
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use"
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keywords"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
    t.datetime "expiry_date"
    t.integer  "attachmentfile"
    t.string   "form_name"
    t.text     "inpfld_001"
    t.integer  "inpfld_002"
    t.integer  "inpfld_003"
    t.integer  "inpfld_004"
    t.integer  "inpfld_005"
    t.integer  "inpfld_006"
    t.text     "inpfld_007"
    t.text     "inpfld_008"
    t.text     "inpfld_009"
    t.text     "inpfld_010"
    t.text     "inpfld_011"
    t.text     "inpfld_012"
    t.text     "notes_001"
    t.text     "notes_002"
    t.text     "notes_003"
    t.integer  "wiki"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "doclibrary_docs", ["category1_id"], name: "category1_id", using: :btree
  add_index "doclibrary_docs", ["state", "title_id", "category1_id"], name: "title_id", length: {"state"=>50, "title_id"=>nil, "category1_id"=>nil}, using: :btree
  add_index "doclibrary_docs", ["title_id"], name: "title_id2", using: :btree

  create_table "doclibrary_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "doclibrary_files", ["parent_id"], name: "index_doclibrary_files_on_parent_id", using: :btree
  add_index "doclibrary_files", ["title_id"], name: "index_doclibrary_files_on_title_id", using: :btree

  create_table "doclibrary_folder_acls", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "folder_id"
    t.integer  "title_id"
    t.integer  "acl_flag"
    t.integer  "acl_section_id"
    t.string   "acl_section_code"
    t.text     "acl_section_name"
    t.integer  "acl_user_id"
    t.string   "acl_user_code"
    t.text     "acl_user_name"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "doclibrary_folder_acls", ["acl_section_code"], name: "acl_section_code", using: :btree
  add_index "doclibrary_folder_acls", ["acl_user_code"], name: "acl_user_code", using: :btree
  add_index "doclibrary_folder_acls", ["folder_id"], name: "folder_id", using: :btree
  add_index "doclibrary_folder_acls", ["title_id"], name: "title_id", using: :btree

  create_table "doclibrary_folders", force: true do |t|
    t.integer  "unid"
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.integer  "children_size"
    t.integer  "total_children_size"
    t.text     "name"
    t.text     "memo"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "reader_groups"
    t.text     "reader_groups_json"
    t.datetime "docs_last_updated_at"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "doclibrary_folders", ["parent_id"], name: "parent_id", using: :btree
  add_index "doclibrary_folders", ["sort_no"], name: "sort_no", using: :btree
  add_index "doclibrary_folders", ["title_id"], name: "title_id", using: :btree

  create_table "doclibrary_group_folders", force: true do |t|
    t.integer  "unid"
    t.integer  "parent_id"
    t.text     "state"
    t.text     "use_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.integer  "children_size"
    t.integer  "total_children_size"
    t.string   "code"
    t.text     "name"
    t.integer  "sysgroup_id"
    t.integer  "sysparent_id"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "reader_groups"
    t.text     "reader_groups_json"
    t.datetime "docs_last_updated_at"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "doclibrary_group_folders", ["code"], name: "code", using: :btree

  create_table "doclibrary_images", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.text     "parent_name"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  add_index "doclibrary_images", ["parent_id"], name: "index_doclibrary_images_on_parent_id", using: :btree
  add_index "doclibrary_images", ["title_id"], name: "index_doclibrary_images_on_title_id", using: :btree

  create_table "doclibrary_recognizers", force: true do |t|
    t.integer  "unid"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "code"
    t.text     "name"
    t.datetime "recognized_at"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "doclibrary_recognizers", ["parent_id"], name: "index_doclibrary_recognizers_on_parent_id", using: :btree
  add_index "doclibrary_recognizers", ["title_id"], name: "index_doclibrary_recognizers_on_title_id", using: :btree

  create_table "doclibrary_roles", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.string   "role_code"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "doclibrary_roles", ["title_id"], name: "index_doclibrary_roles_on_title_id", using: :btree

  create_table "doclibrary_view_acl_doc_counts", id: false, force: true do |t|
    t.text    "state"
    t.integer "title_id"
    t.integer "acl_flag"
    t.string  "acl_section_code"
    t.string  "acl_user_code"
    t.string  "section_code"
    t.integer "cnt",              limit: 8, default: 0, null: false
  end

  create_table "doclibrary_view_acl_docs", id: false, force: true do |t|
    t.integer "id",               default: 0, null: false
    t.integer "sort_no"
    t.integer "acl_flag"
    t.integer "acl_section_id"
    t.string  "acl_section_code"
    t.text    "acl_section_name"
    t.integer "acl_user_id"
    t.string  "acl_user_code"
    t.text    "acl_user_name"
    t.text    "folder_name"
  end

  create_table "doclibrary_view_acl_files", id: false, force: true do |t|
    t.text     "docs_state"
    t.integer  "id",                default: 0, null: false
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.integer  "category1_id"
    t.string   "section_code"
    t.integer  "acl_flag"
    t.integer  "acl_section_id"
    t.string   "acl_section_code"
    t.text     "acl_section_name"
    t.integer  "acl_user_id"
    t.string   "acl_user_code"
    t.text     "acl_user_name"
  end

  create_table "doclibrary_view_acl_folders", id: false, force: true do |t|
    t.integer  "id",                   default: 0, null: false
    t.integer  "unid"
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.integer  "children_size"
    t.integer  "total_children_size"
    t.text     "name"
    t.text     "memo"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "reader_groups"
    t.text     "reader_groups_json"
    t.datetime "docs_last_updated_at"
    t.integer  "acl_flag"
    t.integer  "acl_section_id"
    t.string   "acl_section_code"
    t.text     "acl_section_name"
    t.integer  "acl_user_id"
    t.string   "acl_user_code"
    t.text     "acl_user_name"
  end

  create_table "enquete_answers", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "latest_updated_at"
    t.boolean  "enquete_division"
    t.integer  "title_id"
    t.string   "user_code"
    t.text     "user_name"
    t.string   "l2_section_code"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "section_sort"
    t.text     "field_001"
    t.text     "field_002"
    t.text     "field_003"
    t.text     "field_004"
    t.text     "field_005"
    t.text     "field_006"
    t.text     "field_007"
    t.text     "field_008"
    t.text     "field_009"
    t.text     "field_010"
    t.text     "field_011"
    t.text     "field_012"
    t.text     "field_013"
    t.text     "field_014"
    t.text     "field_015"
    t.text     "field_016"
    t.text     "field_017"
    t.text     "field_018"
    t.text     "field_019"
    t.text     "field_020"
    t.text     "field_021"
    t.text     "field_022"
    t.text     "field_023"
    t.text     "field_024"
    t.text     "field_025"
    t.text     "field_026"
    t.text     "field_027"
    t.text     "field_028"
    t.text     "field_029"
    t.text     "field_030"
    t.text     "field_031"
    t.text     "field_032"
    t.text     "field_033"
    t.text     "field_034"
    t.text     "field_035"
    t.text     "field_036"
    t.text     "field_037"
    t.text     "field_038"
    t.text     "field_039"
    t.text     "field_040"
    t.text     "field_041"
    t.text     "field_042"
    t.text     "field_043"
    t.text     "field_044"
    t.text     "field_045"
    t.text     "field_046"
    t.text     "field_047"
    t.text     "field_048"
    t.text     "field_049"
    t.text     "field_050"
    t.text     "field_051"
    t.text     "field_052"
    t.text     "field_053"
    t.text     "field_054"
    t.text     "field_055"
    t.text     "field_056"
    t.text     "field_057"
    t.text     "field_058"
    t.text     "field_059"
    t.text     "field_060"
    t.text     "field_061"
    t.text     "field_062"
    t.text     "field_063"
    t.text     "field_064"
    t.text     "createdate"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
    t.datetime "able_date"
    t.datetime "expiry_date"
  end

  add_index "enquete_answers", ["user_code"], name: "user_code", using: :btree

  create_table "enquete_base_users", force: true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "base_user_code"
    t.text     "base_user_name"
  end

  add_index "enquete_base_users", ["base_user_code"], name: "base_user_code", using: :btree

  create_table "enquete_view_questions", id: false, force: true do |t|
    t.string   "base_user_code"
    t.integer  "id",                             default: 0, null: false
    t.integer  "unid"
    t.boolean  "include_index"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section_code"
    t.string   "section_name"
    t.integer  "section_sort"
    t.boolean  "enquete_division"
    t.string   "manage_title"
    t.string   "title"
    t.text     "form_body"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "spec_config"
    t.string   "send_change"
    t.text     "createdate"
    t.string   "createrdivision_id",  limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",          limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",   limit: 20
    t.text     "editordivision"
    t.string   "editor_id",           limit: 20
    t.text     "editor"
    t.text     "custom_groups"
    t.text     "custom_groups_json"
    t.text     "reader_groups"
    t.text     "reader_groups_json"
    t.text     "custom_readers"
    t.text     "custom_readers_json"
    t.text     "readers"
    t.text     "readers_json"
    t.integer  "default_limit"
  end

  create_table "gw_access_controls", force: true do |t|
    t.string   "state"
    t.integer  "user_id"
    t.text     "path"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_access_controls", ["state", "user_id"], name: "index_gw_access_controls_on_state_and_user_id", using: :btree

  create_table "gw_admin_check_extensions", force: true do |t|
    t.string   "state"
    t.integer  "sort_no"
    t.string   "extension"
    t.text     "remark"
    t.datetime "deleted_at"
    t.integer  "deleted_uid"
    t.integer  "deleted_gid"
    t.datetime "updated_at"
    t.integer  "updated_uid"
    t.integer  "updated_gid"
    t.datetime "created_at"
    t.integer  "created_uid"
    t.integer  "created_gid"
  end

  create_table "gw_admin_messages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body"
    t.integer  "sort_no"
    t.integer  "state"
    t.integer  "mode"
  end

  create_table "gw_blog_parts", force: true do |t|
    t.text     "state"
    t.integer  "sort_no"
    t.text     "title"
    t.text     "body"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gw_circulars", force: true do |t|
    t.integer  "state"
    t.integer  "uid"
    t.string   "u_code"
    t.integer  "gid"
    t.string   "g_code"
    t.integer  "class_id"
    t.text     "title"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished"
    t.integer  "is_system"
    t.text     "options"
    t.text     "body"
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "gw_circulars", ["ed_at"], name: "ed_at", using: :btree
  add_index "gw_circulars", ["state"], name: "state", using: :btree
  add_index "gw_circulars", ["uid"], name: "uid", using: :btree

  create_table "gw_dcn_approvals", force: true do |t|
    t.integer  "state"
    t.integer  "uid"
    t.string   "u_code"
    t.integer  "gid"
    t.string   "g_code"
    t.integer  "class_id"
    t.text     "title"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished"
    t.integer  "is_system"
    t.text     "author"
    t.text     "options"
    t.text     "body"
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "gw_edit_link_piece_csses", force: true do |t|
    t.string   "state"
    t.string   "css_name"
    t.integer  "css_sort_no",   default: 0
    t.string   "css_class"
    t.integer  "css_type",      default: 1
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
  end

  create_table "gw_edit_link_pieces", force: true do |t|
    t.integer  "uid"
    t.integer  "class_created",     default: 0
    t.string   "published"
    t.string   "state"
    t.integer  "mode"
    t.integer  "level_no",          default: 0
    t.integer  "parent_id",         default: 0
    t.string   "name"
    t.integer  "sort_no",           default: 0
    t.integer  "tab_keys",          default: 0
    t.integer  "display_auth_priv"
    t.integer  "role_name_id"
    t.text     "display_auth"
    t.integer  "block_icon_id"
    t.integer  "block_css_id"
    t.text     "link_url"
    t.text     "remark"
    t.text     "icon_path"
    t.string   "link_div_class"
    t.integer  "class_external",    default: 0
    t.integer  "ssoid"
    t.string   "class_sso",         default: "0"
    t.string   "field_account"
    t.string   "field_pass"
    t.integer  "css_id",            default: 0
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
  end

  add_index "gw_edit_link_pieces", ["published", "state", "sort_no"], name: "idx_gw_edit_link_pieces", using: :btree

  create_table "gw_edit_tab_public_roles", force: true do |t|
    t.integer  "edit_tab_id"
    t.integer  "class_id"
    t.integer  "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_edit_tabs", force: true do |t|
    t.integer  "class_created",        default: 0
    t.string   "published"
    t.string   "state"
    t.integer  "level_no",             default: 0
    t.integer  "parent_id",            default: 0
    t.string   "name"
    t.integer  "sort_no",              default: 0
    t.integer  "tab_keys",             default: 0
    t.text     "display_auth"
    t.string   "other_controller_use", default: "2"
    t.string   "other_controller_url"
    t.text     "link_url"
    t.text     "icon_path"
    t.string   "link_div_class"
    t.integer  "class_external",       default: 0
    t.string   "class_sso",            default: "0"
    t.string   "field_account"
    t.string   "field_pass"
    t.integer  "css_id",               default: 0
    t.integer  "is_public"
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
  end

  create_table "gw_holidays", force: true do |t|
    t.integer  "creator_uid"
    t.string   "creator_ucode"
    t.text     "creator_uname"
    t.integer  "creator_gid"
    t.string   "creator_gcode"
    t.text     "creator_gname"
    t.integer  "title_category_id"
    t.string   "title"
    t.integer  "is_public"
    t.text     "memo"
    t.integer  "schedule_repeat_id"
    t.integer  "dirty_repeat_id"
    t.integer  "no_time_id"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_holidays", ["st_at", "ed_at"], name: "st_at", using: :btree

  create_table "gw_icon_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_icons", force: true do |t|
    t.integer  "icon_gid"
    t.integer  "idx"
    t.string   "title"
    t.string   "path"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_ind_portal_pieces", force: true do |t|
    t.integer  "uid"
    t.integer  "sort_no"
    t.text     "name",       null: false
    t.text     "title"
    t.text     "piece"
    t.text     "genre"
    t.integer  "tid"
    t.integer  "limit"
    t.text     "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_infos", force: true do |t|
    t.string   "cls"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_meeting_access_logs", force: true do |t|
    t.text     "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_meeting_guide_backgrounds", force: true do |t|
    t.string   "published"
    t.string   "state"
    t.integer  "area"
    t.integer  "sort_no"
    t.text     "file_path"
    t.text     "file_directory"
    t.text     "file_name"
    t.text     "original_file_name"
    t.string   "content_type"
    t.integer  "width"
    t.integer  "height"
    t.string   "background_color"
    t.text     "caption"
    t.datetime "deleted_at"
    t.integer  "deleted_uid"
    t.integer  "deleted_gid"
    t.datetime "updated_at"
    t.integer  "updated_uid"
    t.integer  "updated_gid"
    t.datetime "created_at"
    t.integer  "created_uid"
    t.integer  "created_gid"
  end

  create_table "gw_meeting_guide_notices", force: true do |t|
    t.string   "published"
    t.string   "state"
    t.integer  "sort_no"
    t.text     "title"
    t.datetime "deleted_at"
    t.integer  "deleted_uid"
    t.integer  "deleted_gid"
    t.datetime "updated_at"
    t.integer  "updated_uid"
    t.integer  "updated_gid"
    t.datetime "created_at"
    t.integer  "created_uid"
    t.integer  "created_gid"
  end

  create_table "gw_meeting_guide_places", force: true do |t|
    t.text     "state"
    t.integer  "sort_no"
    t.text     "place"
    t.text     "place_master"
    t.integer  "place_type"
    t.integer  "prop_id"
    t.datetime "deleted_at"
    t.integer  "deleted_uid"
    t.integer  "deleted_gid"
    t.datetime "updated_at"
    t.integer  "updated_uid"
    t.integer  "updated_gid"
    t.datetime "created_at"
    t.integer  "created_uid"
    t.integer  "created_gid"
  end

  create_table "gw_meeting_monitor_managers", force: true do |t|
    t.integer  "manager_group_id"
    t.integer  "manager_user_id"
    t.text     "manager_user_addr"
    t.text     "state"
    t.text     "created_user"
    t.text     "updated_user"
    t.text     "deleted_user"
    t.text     "created_group"
    t.text     "updated_group"
    t.text     "deleted_group"
    t.datetime "deleted_at"
    t.integer  "deleted_uid"
    t.integer  "deleted_gid"
    t.datetime "updated_at"
    t.integer  "updated_uid"
    t.integer  "updated_gid"
    t.datetime "created_at"
    t.integer  "created_uid"
    t.integer  "created_gid"
  end

  create_table "gw_meeting_monitor_settings", force: true do |t|
    t.text     "state"
    t.text     "mail_from"
    t.text     "mail_title"
    t.text     "mail_body"
    t.text     "notice_body"
    t.text     "conditions"
    t.text     "weekday_notice"
    t.text     "holiday_notice"
    t.integer  "monitor_type"
    t.text     "name"
    t.text     "ip_address"
    t.text     "created_user"
    t.text     "updated_user"
    t.text     "deleted_user"
    t.text     "created_group"
    t.text     "updated_group"
    t.text     "deleted_group"
    t.datetime "deleted_at"
    t.integer  "deleted_uid"
    t.integer  "deleted_gid"
    t.datetime "updated_at"
    t.integer  "updated_uid"
    t.integer  "updated_gid"
    t.datetime "created_at"
    t.integer  "created_uid"
    t.integer  "created_gid"
  end

  create_table "gw_memo_mobiles", force: true do |t|
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_memo_users", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "class_id"
    t.integer  "uid"
    t.string   "ucode"
    t.string   "uname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_memo_users", ["schedule_id"], name: "index_gw_memo_users_on_schedule_id", using: :btree

  create_table "gw_memos", force: true do |t|
    t.integer  "class_id"
    t.integer  "uid"
    t.string   "ucode"
    t.string   "uname"
    t.string   "title"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished",        default: 0
    t.integer  "is_system"
    t.string   "fr_group"
    t.string   "fr_user"
    t.integer  "memo_category_id"
    t.string   "memo_category_text"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_monitor_reminders", force: true do |t|
    t.integer  "state"
    t.integer  "uid"
    t.string   "u_code"
    t.integer  "gid"
    t.string   "g_code"
    t.integer  "class_id"
    t.text     "title"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished"
    t.integer  "is_system"
    t.text     "options"
    t.text     "body"
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "gw_monitor_reminders", ["ed_at"], name: "ed_at", using: :btree
  add_index "gw_monitor_reminders", ["state"], name: "state", using: :btree
  add_index "gw_monitor_reminders", ["uid"], name: "uid", using: :btree

  create_table "gw_notes", force: true do |t|
    t.integer  "uid"
    t.integer  "position"
    t.string   "title"
    t.text     "body"
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_plus_updates", force: true do |t|
    t.string   "doc_id"
    t.string   "post_id"
    t.string   "state"
    t.text     "project_users"
    t.text     "project_users_json"
    t.string   "project_id"
    t.string   "project_code"
    t.integer  "class_id"
    t.text     "title"
    t.datetime "doc_updated_at"
    t.text     "author"
    t.text     "project_url"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_portal_ad_daily_accesses", force: true do |t|
    t.text     "state"
    t.integer  "ad_id"
    t.text     "content"
    t.integer  "click_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "accessed_at"
  end

  create_table "gw_portal_add_access_logs", force: true do |t|
    t.integer  "add_id"
    t.datetime "accessed_at"
    t.string   "ipaddr"
    t.text     "user_agent"
    t.text     "referer"
    t.text     "path"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_portal_add_access_logs", ["add_id", "accessed_at"], name: "index_gw_portal_add_access_logs_on_add_id_and_accessed_at", using: :btree

  create_table "gw_portal_add_patterns", force: true do |t|
    t.integer  "pattern"
    t.integer  "place"
    t.text     "state"
    t.integer  "add_id"
    t.integer  "sort_no"
    t.integer  "group_id"
    t.text     "title"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
  end

  create_table "gw_portal_adds", force: true do |t|
    t.text     "state"
    t.text     "published"
    t.text     "file_path"
    t.text     "file_directory"
    t.text     "file_name"
    t.text     "original_file_name"
    t.text     "content_type"
    t.integer  "width"
    t.integer  "height"
    t.integer  "place"
    t.integer  "sort_no"
    t.text     "title"
    t.text     "body"
    t.text     "url"
    t.datetime "publish_start_at"
    t.datetime "publish_end_at"
    t.integer  "class_external"
    t.string   "class_sso"
    t.string   "field_account"
    t.string   "field_pass"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.integer  "click_count",        default: 0, null: false
    t.integer  "is_large"
  end

  create_table "gw_portal_user_settings", force: true do |t|
    t.integer  "uid"
    t.integer  "idx"
    t.string   "arrange"
    t.string   "title"
    t.string   "gadget"
    t.string   "options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_pref_assembly_members", force: true do |t|
    t.integer  "gid"
    t.string   "g_code"
    t.string   "g_name"
    t.integer  "g_order"
    t.integer  "uid"
    t.string   "u_code"
    t.text     "u_lname"
    t.text     "u_name"
    t.integer  "u_order"
    t.text     "title"
    t.string   "state"
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
  end

  create_table "gw_pref_configs", force: true do |t|
    t.text     "state"
    t.text     "option_type"
    t.text     "name"
    t.text     "options"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
  end

  create_table "gw_pref_director_temps", force: true do |t|
    t.integer  "parent_gid"
    t.string   "parent_g_code"
    t.string   "parent_g_name"
    t.integer  "parent_g_order"
    t.integer  "gid"
    t.string   "g_code"
    t.string   "g_name"
    t.integer  "g_order"
    t.integer  "uid"
    t.string   "u_code"
    t.text     "u_lname"
    t.text     "u_name"
    t.integer  "u_order"
    t.text     "title"
    t.string   "state"
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
    t.integer  "is_governor_view"
    t.integer  "display_parent_gid"
    t.string   "version"
  end

  create_table "gw_pref_directors", force: true do |t|
    t.integer  "parent_gid"
    t.string   "parent_g_code"
    t.string   "parent_g_name"
    t.integer  "parent_g_order"
    t.integer  "gid"
    t.string   "g_code"
    t.string   "g_name"
    t.integer  "g_order"
    t.integer  "uid"
    t.string   "u_code"
    t.text     "u_lname"
    t.text     "u_name"
    t.integer  "u_order"
    t.text     "title"
    t.string   "state"
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
    t.integer  "is_governor_view"
    t.integer  "display_parent_gid"
    t.string   "version"
  end

  create_table "gw_pref_executives", force: true do |t|
    t.integer  "parent_gid"
    t.string   "parent_g_code"
    t.string   "parent_g_name"
    t.integer  "parent_g_order"
    t.integer  "gid"
    t.string   "g_code"
    t.string   "g_name"
    t.integer  "g_order"
    t.integer  "uid"
    t.string   "u_code"
    t.text     "u_lname"
    t.text     "u_name"
    t.integer  "u_order"
    t.text     "title"
    t.string   "state"
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
    t.integer  "is_other_view"
    t.integer  "is_governor_view"
  end

  create_table "gw_pref_soumu_messages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body"
    t.integer  "sort_no"
    t.integer  "state"
    t.integer  "tab_keys"
  end

  create_table "gw_prop_extra_pm_meetingroom_actuals", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "schedule_prop_id"
    t.integer  "car_id"
    t.integer  "driver_user_id"
    t.string   "driver_user_code"
    t.string   "driver_user_name"
    t.integer  "driver_group_id"
    t.string   "driver_group_code"
    t.string   "driver_group_name"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "start_meter"
    t.integer  "end_meter"
    t.integer  "run_meter"
    t.text     "summaries_state"
    t.text     "bill_state"
    t.integer  "toll_fee"
    t.integer  "refuel_amount"
    t.text     "to_go"
    t.text     "title"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_prop_extra_pm_meetingroom_actuals", ["car_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_car_id", using: :btree
  add_index "gw_prop_extra_pm_meetingroom_actuals", ["driver_group_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_driver_group_id", using: :btree
  add_index "gw_prop_extra_pm_meetingroom_actuals", ["driver_user_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_driver_user_id", using: :btree
  add_index "gw_prop_extra_pm_meetingroom_actuals", ["schedule_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_schedule_id", using: :btree
  add_index "gw_prop_extra_pm_meetingroom_actuals", ["schedule_prop_id"], name: "index_gw_prop_extra_pm_meetingroom_actuals_on_schedule_prop_id", using: :btree

  create_table "gw_prop_extra_pm_meetingroom_csvput_histories", force: true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "created_at"
  end

  create_table "gw_prop_extra_pm_meetingroom_summaries", force: true do |t|
    t.datetime "summaries_at"
    t.integer  "group_id"
    t.integer  "run_meter"
    t.integer  "bill_amount"
    t.text     "bill_state"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_meetingroom_summarize_histories", force: true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_messages", force: true do |t|
    t.text     "body"
    t.integer  "sort_no"
    t.integer  "state"
    t.integer  "prop_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_remarks", force: true do |t|
    t.integer  "prop_class_id"
    t.string   "state"
    t.integer  "sort_no"
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_renewal_groups", force: true do |t|
    t.integer  "present_group_id"
    t.string   "present_group_code"
    t.integer  "incoming_group_id"
    t.text     "incoming_group_name"
    t.datetime "modified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "present_group_name"
    t.string   "incoming_group_code"
  end

  create_table "gw_prop_extra_pm_rentcar_actuals", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "schedule_prop_id"
    t.integer  "car_id"
    t.integer  "driver_user_id"
    t.string   "driver_user_code"
    t.string   "driver_user_name"
    t.integer  "driver_group_id"
    t.string   "driver_group_code"
    t.string   "driver_group_name"
    t.text     "user_uname"
    t.text     "user_gname"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "start_meter"
    t.integer  "end_meter"
    t.integer  "run_meter"
    t.text     "summaries_state"
    t.text     "bill_state"
    t.integer  "toll_fee"
    t.integer  "refuel_amount"
    t.text     "to_go"
    t.text     "title"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_prop_extra_pm_rentcar_actuals", ["car_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_car_id", using: :btree
  add_index "gw_prop_extra_pm_rentcar_actuals", ["driver_group_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_driver_group_id", using: :btree
  add_index "gw_prop_extra_pm_rentcar_actuals", ["driver_user_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_driver_user_id", using: :btree
  add_index "gw_prop_extra_pm_rentcar_actuals", ["schedule_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_schedule_id", using: :btree
  add_index "gw_prop_extra_pm_rentcar_actuals", ["schedule_prop_id"], name: "index_gw_prop_extra_pm_rentcar_actuals_on_schedule_prop_id", using: :btree

  create_table "gw_prop_extra_pm_rentcar_csvput_histories", force: true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_rentcar_summaries", force: true do |t|
    t.datetime "summaries_at"
    t.integer  "group_id"
    t.integer  "run_meter"
    t.integer  "bill_amount"
    t.text     "bill_state"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_rentcar_summarize_histories", force: true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_extra_pm_rentcar_unit_prices", force: true do |t|
    t.integer  "unit_price"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_meetingroom_images", force: true do |t|
    t.integer  "parent_id"
    t.integer  "idx"
    t.string   "note"
    t.string   "path"
    t.string   "orig_filename"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_meetingrooms", force: true do |t|
    t.integer  "sort_no"
    t.integer  "type_id"
    t.integer  "delete_state"
    t.integer  "reserved_state"
    t.string   "name"
    t.string   "position"
    t.string   "tel"
    t.integer  "max_person"
    t.integer  "max_tables"
    t.integer  "max_chairs"
    t.string   "note"
    t.string   "extra_flag"
    t.text     "extra_data"
    t.string   "gid"
    t.string   "gname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_images", force: true do |t|
    t.integer  "parent_id"
    t.integer  "idx"
    t.string   "note"
    t.string   "path"
    t.string   "orig_filename"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_limits", force: true do |t|
    t.integer  "sort_no"
    t.string   "state"
    t.integer  "gid"
    t.integer  "limit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_roles", force: true do |t|
    t.integer  "prop_id"
    t.integer  "gid"
    t.string   "auth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_prop_other_roles", ["prop_id"], name: "prop_id", using: :btree

  create_table "gw_prop_others", force: true do |t|
    t.integer  "sort_no"
    t.string   "name"
    t.integer  "type_id"
    t.text     "state"
    t.integer  "edit_state"
    t.integer  "delete_state",   default: 0
    t.integer  "reserved_state", default: 1
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "extra_flag"
    t.text     "extra_data"
    t.integer  "gid"
    t.string   "gname"
    t.integer  "creator_uid"
    t.integer  "updater_uid"
  end

  create_table "gw_prop_rentcar_images", force: true do |t|
    t.integer  "parent_id"
    t.integer  "idx"
    t.string   "note"
    t.string   "path"
    t.string   "orig_filename"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_rentcar_meters", force: true do |t|
    t.integer  "parent_id"
    t.integer  "travelled_km"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_rentcars", force: true do |t|
    t.integer  "sort_no"
    t.string   "car_model"
    t.string   "name"
    t.integer  "type_id"
    t.integer  "delete_state"
    t.integer  "reserved_state"
    t.string   "register_no"
    t.string   "exhaust"
    t.integer  "year_type"
    t.text     "comment"
    t.string   "extra_flag"
    t.text     "extra_data"
    t.string   "gid"
    t.string   "gname"
    t.integer  "travelled_km"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_types", force: true do |t|
    t.string   "state"
    t.string   "name"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "restricted"
    t.text     "user_str"
  end

  create_table "gw_prop_types_messages", force: true do |t|
    t.integer  "state"
    t.integer  "sort_no"
    t.text     "body"
    t.integer  "type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_types_users", force: true do |t|
    t.integer  "user_id"
    t.text     "user_name"
    t.integer  "type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_reminder_external_systems", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "user_id"
    t.string   "password"
    t.string   "sso_user_field"
    t.string   "sso_pass_field"
    t.string   "css_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_reminder_externals", force: true do |t|
    t.text     "system"
    t.text     "data_id"
    t.text     "title"
    t.datetime "updated"
    t.text     "link"
    t.text     "author"
    t.text     "contributor"
    t.text     "member"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "gw_reminders", force: true do |t|
    t.string   "state"
    t.integer  "sort_no"
    t.text     "title"
    t.text     "name"
    t.string   "css_name"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  add_index "gw_reminders", ["state"], name: "index_gw_reminders_on_state", using: :btree

  create_table "gw_rss_caches", force: true do |t|
    t.text     "uri"
    t.datetime "fetched"
    t.text     "title"
    t.datetime "published"
    t.text     "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_rss_reader_caches", force: true do |t|
    t.integer  "rrid"
    t.text     "uri"
    t.text     "title"
    t.text     "link"
    t.datetime "fetched_at"
    t.datetime "published_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "gw_rss_readers", force: true do |t|
    t.text     "state"
    t.integer  "sort_no"
    t.text     "title"
    t.text     "uri"
    t.integer  "max"
    t.integer  "interval"
    t.datetime "checked_at"
    t.datetime "fetched_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gw_schedule_event_masters", force: true do |t|
    t.integer  "edit_auth"
    t.integer  "management_parent_gid"
    t.integer  "management_gid"
    t.integer  "management_uid"
    t.integer  "range_class_id"
    t.integer  "division_parent_gid"
    t.integer  "division_gid"
    t.integer  "creator_uid"
    t.integer  "creator_gid"
    t.integer  "updator_uid"
    t.integer  "updator_gid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_schedule_events", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "gid"
    t.string   "gcode"
    t.string   "gname"
    t.integer  "parent_gid"
    t.string   "parent_gcode"
    t.string   "parent_gname"
    t.integer  "uid"
    t.string   "ucode"
    t.string   "uname"
    t.integer  "sort_id"
    t.string   "title"
    t.text     "event_word"
    t.string   "place"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "event_week"
    t.integer  "week_approval"
    t.datetime "week_approved_at"
    t.integer  "week_approval_uid"
    t.string   "week_approval_ucode"
    t.string   "week_approval_uname"
    t.integer  "week_approval_gid"
    t.string   "week_approval_gcode"
    t.string   "week_approval_gname"
    t.integer  "week_open"
    t.datetime "week_opened_at"
    t.integer  "week_open_uid"
    t.string   "week_open_ucode"
    t.string   "week_open_uname"
    t.integer  "week_open_gid"
    t.string   "week_open_gcode"
    t.string   "week_open_gname"
    t.integer  "event_month"
    t.integer  "month_approval"
    t.datetime "month_approved_at"
    t.integer  "month_approval_uid"
    t.string   "month_approval_ucode"
    t.string   "month_approval_uname"
    t.integer  "month_approval_gid"
    t.string   "month_approval_gcode"
    t.string   "month_approval_gname"
    t.integer  "month_open"
    t.datetime "month_opened_at"
    t.integer  "month_open_uid"
    t.string   "month_open_ucode"
    t.string   "month_open_uname"
    t.integer  "month_open_gid"
    t.string   "month_open_gcode"
    t.string   "month_open_gname"
    t.integer  "allday"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_schedule_events", ["schedule_id"], name: "index_gw_schedule_events_on_schedule_id", using: :btree

  create_table "gw_schedule_options", force: true do |t|
    t.integer  "schedule_id"
    t.string   "kind",        limit: 50
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_schedule_props", force: true do |t|
    t.integer  "schedule_id"
    t.string   "prop_type"
    t.integer  "prop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "extra_data"
    t.integer  "confirmed_uid"
    t.integer  "confirmed_gid"
    t.datetime "confirmed_at"
    t.integer  "rented_uid"
    t.integer  "rented_gid"
    t.datetime "rented_at"
    t.integer  "returned_uid"
    t.integer  "returned_gid"
    t.datetime "returned_at"
    t.integer  "cancelled_uid"
    t.integer  "cancelled_gid"
    t.datetime "cancelled_at"
    t.datetime "st_at"
    t.datetime "ed_at"
  end

  add_index "gw_schedule_props", ["prop_id"], name: "prop_id", using: :btree
  add_index "gw_schedule_props", ["schedule_id", "prop_type", "prop_id"], name: "schedule_id", using: :btree
  add_index "gw_schedule_props", ["schedule_id"], name: "index_gw_schedule_props_on_schedule_id", using: :btree

  create_table "gw_schedule_public_roles", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "class_id"
    t.integer  "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_schedule_public_roles", ["schedule_id"], name: "index_gw_schedule_public_roles_on_schedule_id", using: :btree

  create_table "gw_schedule_repeats", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "st_date_at"
    t.datetime "ed_date_at"
    t.datetime "st_time_at"
    t.datetime "ed_time_at"
    t.integer  "class_id"
    t.string   "weekday_ids"
  end

  create_table "gw_schedule_todos", force: true do |t|
    t.integer  "schedule_id"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "todo_ed_at_indefinite", default: 0, null: false
    t.integer  "is_finished",           default: 0
    t.integer  "todo_st_at_id",         default: 0
    t.integer  "todo_ed_at_id",         default: 0
    t.integer  "todo_repeat_time_id",   default: 0
    t.datetime "finished_at"
    t.integer  "finished_uid"
    t.integer  "finished_gid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "todo_id"
  end

  add_index "gw_schedule_todos", ["schedule_id"], name: "index_gw_schedule_todos_on_schedule_id", using: :btree

  create_table "gw_schedule_users", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "class_id"
    t.integer  "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "st_at"
    t.datetime "ed_at"
  end

  add_index "gw_schedule_users", ["schedule_id", "class_id", "uid"], name: "schedule_id", using: :btree
  add_index "gw_schedule_users", ["schedule_id"], name: "schedule_id2", using: :btree
  add_index "gw_schedule_users", ["uid"], name: "uid", using: :btree

  create_table "gw_schedules", force: true do |t|
    t.integer  "creator_uid"
    t.string   "creator_ucode"
    t.text     "creator_uname"
    t.integer  "creator_gid"
    t.string   "creator_gcode"
    t.text     "creator_gname"
    t.integer  "updater_uid"
    t.string   "updater_ucode"
    t.text     "updater_uname"
    t.integer  "updater_gid"
    t.string   "updater_gcode"
    t.text     "updater_gname"
    t.integer  "owner_uid"
    t.string   "owner_ucode"
    t.text     "owner_uname"
    t.integer  "owner_gid"
    t.string   "owner_gcode"
    t.text     "owner_gname"
    t.integer  "title_category_id"
    t.string   "title"
    t.integer  "place_category_id"
    t.string   "place"
    t.integer  "to_go"
    t.integer  "is_public"
    t.integer  "is_pr"
    t.text     "memo"
    t.text     "admin_memo"
    t.integer  "repeat_id"
    t.integer  "schedule_repeat_id"
    t.integer  "dirty_repeat_id"
    t.integer  "no_time_id"
    t.integer  "schedule_parent_id"
    t.integer  "participant_nums_inner"
    t.integer  "participant_nums_outer"
    t.integer  "check_30_over"
    t.text     "inquire_to"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "todo",                   default: 0
    t.integer  "allday"
    t.integer  "guide_state"
    t.integer  "guide_place_id"
    t.text     "guide_place"
    t.integer  "guide_ed_at"
    t.integer  "event_week"
    t.integer  "event_month"
  end

  add_index "gw_schedules", ["ed_at"], name: "ed_at", using: :btree
  add_index "gw_schedules", ["schedule_parent_id"], name: "index_gw_schedules_on_schedule_parent_id", using: :btree
  add_index "gw_schedules", ["schedule_repeat_id"], name: "schedule_repeat_id", using: :btree
  add_index "gw_schedules", ["st_at", "ed_at"], name: "st_at", using: :btree

  create_table "gw_section_admin_master_func_names", force: true do |t|
    t.text     "func_name"
    t.text     "name"
    t.text     "state"
    t.integer  "sort_no"
    t.integer  "creator_uid"
    t.integer  "creator_gid"
    t.datetime "created_at"
    t.integer  "updator_uid"
    t.integer  "updator_gid"
    t.datetime "updated_at"
    t.integer  "deleted_uid"
    t.integer  "deleted_gid"
    t.datetime "deleted_at"
  end

  create_table "gw_section_admin_masters", force: true do |t|
    t.text     "func_name"
    t.string   "state"
    t.integer  "edit_auth"
    t.integer  "management_parent_gid"
    t.integer  "management_gid"
    t.integer  "management_uid"
    t.integer  "range_class_id"
    t.integer  "division_parent_gid"
    t.integer  "division_gid"
    t.string   "management_ucode"
    t.integer  "fyear_id_sb04"
    t.string   "management_gcode"
    t.string   "division_gcode"
    t.integer  "management_uid_sb04"
    t.integer  "management_gid_sb04"
    t.integer  "division_gid_sb04"
    t.integer  "creator_uid"
    t.integer  "creator_gid"
    t.integer  "updator_uid"
    t.integer  "updator_gid"
    t.integer  "deleted_uid"
    t.integer  "deleted_gid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "gw_todos", force: true do |t|
    t.integer  "class_id"
    t.integer  "uid"
    t.string   "title"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "prior_id"
    t.integer  "category_id"
    t.text     "body"
  end

  create_table "gw_user_properties", force: true do |t|
    t.integer  "class_id"
    t.string   "uid"
    t.string   "name"
    t.string   "type_name"
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_user_properties", ["class_id", "uid", "name", "type_name"], name: "idx_gw_user_properties_searches", using: :btree

  create_table "gw_workflow_controls", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "doc_body_size_capacity"
    t.integer  "doc_body_size_currently"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                 precision: 17, scale: 0
    t.decimal  "upload_document_file_size_currently",                precision: 17, scale: 0
    t.integer  "commission_limit"
    t.string   "create_section"
    t.string   "create_section_flag"
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern"
    t.string   "left_index_bg_color"
    t.string   "default_mode"
    t.text     "other_system_link"
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id"
    t.text     "wallpaper"
    t.text     "css"
    t.text     "font_color"
    t.integer  "icon_id"
    t.text     "icon"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.boolean  "group_view"
    t.integer  "one_line_use"
    t.integer  "notification"
    t.boolean  "restrict_access"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",                              limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision"
    t.string   "editor_id",                               limit: 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.text     "notes_field01"
    t.text     "notes_field02"
    t.text     "notes_field03"
    t.text     "notes_field04"
    t.text     "notes_field05"
    t.text     "notes_field06"
    t.text     "notes_field07"
    t.text     "notes_field08"
    t.text     "notes_field09"
    t.text     "notes_field10"
    t.datetime "docslast_updated_at"
  end

  create_table "gw_workflow_custom_route_steps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "custom_route_id"
    t.integer  "number"
  end

  create_table "gw_workflow_custom_route_users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "step_id"
    t.integer  "user_id"
    t.text     "user_name"
    t.text     "user_gname"
  end

  create_table "gw_workflow_custom_routes", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_uid"
    t.integer  "sort_no"
    t.text     "state"
    t.text     "name"
  end

  create_table "gw_workflow_docs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "state"
    t.text     "title"
    t.text     "body",           limit: 16777215
    t.datetime "expired_at"
    t.datetime "applied_at"
    t.integer  "creater_id"
    t.string   "creater_name",   limit: 20
    t.string   "creater_gname",  limit: 20
    t.integer  "attachmentfile"
    t.integer  "current_number",                  default: 0
  end

  create_table "gw_workflow_itemdeletes", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code"
    t.integer  "title_id"
    t.text     "board_title"
    t.string   "board_state"
    t.string   "board_view_hide"
    t.integer  "board_sort_no"
    t.integer  "public_doc_count"
    t.integer  "void_doc_count"
    t.string   "dbname"
    t.string   "limit_date"
    t.string   "board_limit_date"
  end

  create_table "gw_workflow_mail_settings", force: true do |t|
    t.integer "unid"
    t.boolean "notifying"
  end

  create_table "gw_workflow_route_steps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "doc_id"
    t.integer  "number"
  end

  create_table "gw_workflow_route_users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "step_id"
    t.datetime "decided_at"
    t.string   "state"
    t.text     "comment"
    t.integer  "user_id"
    t.text     "user_name"
    t.text     "user_gname"
  end

  create_table "gw_year_fiscal_jps", force: true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "fyear"
    t.text     "fyear_f"
    t.text     "markjp"
    t.text     "markjp_f"
    t.text     "namejp"
    t.text     "namejp_f"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gw_year_mark_jps", force: true do |t|
    t.text     "name"
    t.text     "mark"
    t.datetime "start_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwbbs_adms", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "gwbbs_adms", ["title_id"], name: "index_gwbbs_adms_on_title_id", using: :btree

  create_table "gwbbs_categories", force: true do |t|
    t.integer  "unid"
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.text     "name"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwbbs_categories", ["title_id"], name: "index_gwbbs_categories_on_title_id", using: :btree

  create_table "gwbbs_comments", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.text     "content_state"
    t.integer  "title_id"
    t.text     "name"
    t.text     "pname"
    t.text     "title"
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keyword1"
    t.text     "keyword2"
    t.text     "keyword3"
    t.text     "keywords"
    t.text     "createdate"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
    t.datetime "expiry_date"
    t.text     "inpfld_001"
    t.text     "inpfld_002"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwbbs_comments", ["parent_id"], name: "index_gwbbs_comments_on_parent_id", using: :btree
  add_index "gwbbs_comments", ["title_id"], name: "index_gwbbs_comments_on_title_id", using: :btree

  create_table "gwbbs_controls", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "doc_body_size_capacity"
    t.integer  "doc_body_size_currently"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                 precision: 17, scale: 0
    t.decimal  "upload_document_file_size_currently",                precision: 17, scale: 0
    t.string   "create_section"
    t.string   "create_section_flag"
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern"
    t.string   "left_index_bg_color"
    t.string   "default_mode"
    t.text     "other_system_link"
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id"
    t.text     "wallpaper"
    t.text     "css"
    t.text     "font_color"
    t.integer  "icon_id"
    t.text     "icon"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.boolean  "group_view"
    t.integer  "one_line_use"
    t.integer  "notification"
    t.boolean  "restrict_access"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",                              limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision"
    t.string   "editor_id",                               limit: 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.text     "notes_field01"
    t.text     "notes_field02"
    t.text     "notes_field03"
    t.text     "notes_field04"
    t.text     "notes_field05"
    t.text     "notes_field06"
    t.text     "notes_field07"
    t.text     "notes_field08"
    t.text     "notes_field09"
    t.text     "notes_field10"
    t.datetime "docslast_updated_at"
    t.text     "icon_filename"
    t.string   "icon_position"
  end

  add_index "gwbbs_controls", ["notification"], name: "index_gwbbs_controls_on_notification", using: :btree

  create_table "gwbbs_db_files", force: true do |t|
    t.integer "title_id"
    t.integer "parent_id"
    t.binary  "data",      limit: 2147483647
    t.integer "serial_no"
    t.integer "migrated"
  end

  add_index "gwbbs_db_files", ["parent_id"], name: "index_gwbbs_db_files_on_parent_id", using: :btree
  add_index "gwbbs_db_files", ["title_id"], name: "index_gwbbs_db_files_on_title_id", using: :btree

  create_table "gwbbs_docs", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.text     "content_state"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "importance"
    t.integer  "one_line_note"
    t.integer  "title_id"
    t.text     "name"
    t.text     "pname"
    t.text     "title"
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use"
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keywords"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "attachmentfile"
    t.string   "form_name"
    t.text     "inpfld_001"
    t.text     "inpfld_002"
    t.text     "inpfld_003"
    t.text     "inpfld_004"
    t.text     "inpfld_005"
    t.text     "inpfld_006"
    t.string   "inpfld_006w"
    t.datetime "inpfld_006d"
    t.text     "inpfld_007"
    t.text     "inpfld_008"
    t.text     "inpfld_009"
    t.text     "inpfld_010"
    t.text     "inpfld_011"
    t.text     "inpfld_012"
    t.text     "inpfld_013"
    t.text     "inpfld_014"
    t.text     "inpfld_015"
    t.text     "inpfld_016"
    t.text     "inpfld_017"
    t.text     "inpfld_018"
    t.text     "inpfld_019"
    t.text     "inpfld_020"
    t.text     "inpfld_021"
    t.text     "inpfld_022"
    t.text     "inpfld_023"
    t.text     "inpfld_024"
    t.text     "inpfld_025"
    t.integer  "wiki"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwbbs_docs", ["title_id"], name: "index_gwbbs_docs_on_title_id", using: :btree

  create_table "gwbbs_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwbbs_files", ["parent_id"], name: "index_gwbbs_files_on_parent_id", using: :btree
  add_index "gwbbs_files", ["title_id"], name: "index_gwbbs_files_on_title_id", using: :btree

  create_table "gwbbs_images", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.text     "parent_name"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  add_index "gwbbs_images", ["parent_id"], name: "index_gwbbs_images_on_parent_id", using: :btree
  add_index "gwbbs_images", ["title_id"], name: "index_gwbbs_images_on_title_id", using: :btree

  create_table "gwbbs_itemdeletes", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code"
    t.integer  "title_id"
    t.text     "board_title"
    t.string   "board_state"
    t.string   "board_view_hide"
    t.integer  "board_sort_no"
    t.integer  "public_doc_count"
    t.integer  "void_doc_count"
    t.string   "dbname"
    t.string   "limit_date"
    t.string   "board_limit_date"
  end

  create_table "gwbbs_itemimages", force: true do |t|
    t.string   "type_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.text     "filename"
    t.integer  "width"
    t.integer  "height"
  end

  create_table "gwbbs_recognizers", force: true do |t|
    t.integer  "unid"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "code"
    t.text     "name"
    t.datetime "recognized_at"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwbbs_recognizers", ["parent_id"], name: "index_gwbbs_recognizers_on_parent_id", using: :btree
  add_index "gwbbs_recognizers", ["title_id"], name: "index_gwbbs_recognizers_on_title_id", using: :btree

  create_table "gwbbs_roles", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.string   "role_code"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "gwbbs_roles", ["title_id"], name: "index_gwbbs_roles_on_title_id", using: :btree

  create_table "gwbbs_themes", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "board_id"
    t.integer  "theme_id"
    t.text     "section_code"
    t.text     "section_name"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
  end

  create_table "gwboard_bgcolors", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "title"
    t.string   "color_code_hex"
    t.string   "color_code_class"
    t.string   "pair_font_color"
    t.text     "memo"
  end

  create_table "gwboard_images", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "share"
    t.integer  "range_of_use"
    t.text     "filename"
    t.string   "content_type"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.text     "section_code"
    t.text     "section_name"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
  end

  create_table "gwboard_maps", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "system_name"
    t.integer  "title_id"
    t.integer  "parent_id"
    t.string   "field_name"
    t.integer  "use_param"
    t.text     "address"
    t.string   "latlong"
    t.string   "latitude"
    t.string   "longitude"
    t.text     "memo"
    t.string   "url"
  end

  create_table "gwboard_renewal_groups", force: true do |t|
    t.integer  "present_group_id"
    t.string   "present_group_code"
    t.text     "present_group_name"
    t.integer  "incoming_group_id"
    t.string   "incoming_group_code"
    t.text     "incoming_group_name"
    t.datetime "start_date"
  end

  create_table "gwboard_syntheses", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "latest_updated_at"
    t.string   "system_name"
    t.text     "state"
    t.integer  "title_id"
    t.integer  "parent_id"
    t.string   "board_name"
    t.text     "title"
    t.text     "url"
    t.text     "editordivision"
    t.text     "editor"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "acl_flag"
    t.string   "acl_section_code"
    t.string   "acl_user_code"
  end

  create_table "gwboard_synthesetups", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "gwbbs_check"
    t.boolean  "gwfaq_check"
    t.boolean  "gwqa_check"
    t.boolean  "doclib_check"
    t.boolean  "digitallib_check"
    t.string   "limit_date"
  end

  create_table "gwboard_themes", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.string   "record_use"
    t.integer  "sort_no"
    t.text     "if_name"
    t.integer  "if_icon_id"
    t.text     "if_icon"
    t.integer  "if_bg_setup"
    t.text     "if_font_color"
    t.integer  "if_wallpaper_id"
    t.text     "if_wallpaper"
    t.text     "if_css"
    t.text     "name"
    t.boolean  "preview_mode"
    t.integer  "bg_setup"
    t.integer  "icon_id"
    t.text     "icon"
    t.text     "css"
    t.text     "font_color"
    t.integer  "wallpaper_id"
    t.text     "wallpaper"
    t.text     "section_code"
    t.text     "section_name"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
  end

  create_table "gwcircular_adms", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "gwcircular_adms", ["title_id"], name: "index_gwcircular_adms_on_title_id", using: :btree

  create_table "gwcircular_controls", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "doc_body_size_capacity"
    t.integer  "doc_body_size_currently"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                 precision: 17, scale: 0
    t.decimal  "upload_document_file_size_currently",                precision: 17, scale: 0
    t.integer  "commission_limit"
    t.string   "create_section"
    t.string   "create_section_flag"
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern"
    t.string   "left_index_bg_color"
    t.string   "default_mode"
    t.text     "other_system_link"
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id"
    t.text     "wallpaper"
    t.text     "css"
    t.text     "font_color"
    t.integer  "icon_id"
    t.text     "icon"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.boolean  "group_view"
    t.integer  "one_line_use"
    t.integer  "notification"
    t.boolean  "restrict_access"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",                              limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision"
    t.string   "editor_id",                               limit: 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.text     "notes_field01"
    t.text     "notes_field02"
    t.text     "notes_field03"
    t.text     "notes_field04"
    t.text     "notes_field05"
    t.text     "notes_field06"
    t.text     "notes_field07"
    t.text     "notes_field08"
    t.text     "notes_field09"
    t.text     "notes_field10"
    t.datetime "docslast_updated_at"
  end

  create_table "gwcircular_custom_groups", force: true do |t|
    t.integer  "parent_id"
    t.integer  "class_id"
    t.integer  "owner_uid"
    t.integer  "owner_gid"
    t.integer  "updater_uid"
    t.integer  "updater_gid"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.text     "name"
    t.text     "name_en"
    t.integer  "sort_no"
    t.text     "sort_prefix"
    t.integer  "is_default"
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
  end

  add_index "gwcircular_custom_groups", ["owner_uid"], name: "index_gwcircular_custom_groups_on_owner_uid", using: :btree

  create_table "gwcircular_docs", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.integer  "target_user_id"
    t.string   "target_user_code",   limit: 20
    t.text     "target_user_name"
    t.integer  "confirmation"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "importance"
    t.integer  "title_id"
    t.text     "name"
    t.text     "title"
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use"
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keywords"
    t.integer  "commission_count"
    t.integer  "unread_count"
    t.integer  "already_count"
    t.integer  "draft_count"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "attachmentfile"
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
    t.integer  "wiki"
  end

  add_index "gwcircular_docs", ["parent_id"], name: "parent_id", using: :btree
  add_index "gwcircular_docs", ["title_id"], name: "index_gwcircular_docs_on_title_id", using: :btree

  create_table "gwcircular_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  add_index "gwcircular_files", ["parent_id"], name: "index_gwcircular_files_on_parent_id", using: :btree
  add_index "gwcircular_files", ["title_id"], name: "index_gwcircular_files_on_title_id", using: :btree

  create_table "gwcircular_itemdeletes", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code"
    t.integer  "title_id"
    t.text     "board_title"
    t.string   "board_state"
    t.string   "board_view_hide"
    t.integer  "board_sort_no"
    t.integer  "public_doc_count"
    t.integer  "void_doc_count"
    t.string   "dbname"
    t.string   "limit_date"
    t.string   "board_limit_date"
  end

  create_table "gwcircular_roles", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.string   "role_code"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "gwcircular_roles", ["title_id"], name: "index_gwcircular_roles_on_title_id", using: :btree

  create_table "gwfaq_adms", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "gwfaq_adms", ["title_id"], name: "index_gwfaq_adms_on_title_id", using: :btree

  create_table "gwfaq_categories", force: true do |t|
    t.integer  "unid"
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.text     "name"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwfaq_categories", ["title_id"], name: "index_gwfaq_categories_on_title_id", using: :btree

  create_table "gwfaq_controls", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                 precision: 17, scale: 0
    t.decimal  "upload_document_file_size_currently",                precision: 17, scale: 0
    t.string   "create_section"
    t.integer  "addnew_forbidden"
    t.integer  "draft_forbidden"
    t.integer  "delete_forbidden"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern"
    t.string   "left_index_bg_color"
    t.text     "other_system_link"
    t.text     "wallpaper"
    t.text     "css"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.boolean  "group_view"
    t.integer  "notification"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",                              limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision"
    t.string   "editor_id",                               limit: 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.datetime "docslast_updated_at"
  end

  add_index "gwfaq_controls", ["notification"], name: "index_gwfaq_controls_on_notification", using: :btree

  create_table "gwfaq_db_files", force: true do |t|
    t.integer "title_id"
    t.integer "parent_id"
    t.binary  "data",      limit: 2147483647
    t.integer "serial_no"
    t.integer "migrated"
  end

  add_index "gwfaq_db_files", ["parent_id"], name: "index_gwfaq_db_files_on_parent_id", using: :btree
  add_index "gwfaq_db_files", ["title_id"], name: "index_gwfaq_db_files_on_title_id", using: :btree

  create_table "gwfaq_docs", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.text     "content_state"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "importance"
    t.integer  "one_line_note"
    t.integer  "title_id"
    t.text     "name"
    t.text     "pname"
    t.text     "title"
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use"
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keywords"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
    t.integer  "attachmentfile"
    t.integer  "wiki"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwfaq_docs", ["category1_id"], name: "category1_id", using: :btree
  add_index "gwfaq_docs", ["category1_id"], name: "gwfaq_docs_category1_id", using: :btree
  add_index "gwfaq_docs", ["state"], name: "gwfaq_docs_state", length: {"state"=>30}, using: :btree
  add_index "gwfaq_docs", ["state"], name: "state", length: {"state"=>30}, using: :btree
  add_index "gwfaq_docs", ["title_id"], name: "gwfaq_docs_title_id", using: :btree
  add_index "gwfaq_docs", ["title_id"], name: "title_id", using: :btree

  create_table "gwfaq_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwfaq_files", ["parent_id"], name: "index_gwfaq_files_on_parent_id", using: :btree
  add_index "gwfaq_files", ["title_id"], name: "index_gwfaq_files_on_title_id", using: :btree

  create_table "gwfaq_images", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.text     "parent_name"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  add_index "gwfaq_images", ["parent_id"], name: "index_gwfaq_images_on_parent_id", using: :btree
  add_index "gwfaq_images", ["title_id"], name: "index_gwfaq_images_on_title_id", using: :btree

  create_table "gwfaq_recognizers", force: true do |t|
    t.integer  "unid"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "code"
    t.text     "name"
    t.datetime "recognized_at"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwfaq_recognizers", ["parent_id"], name: "index_gwfaq_recognizers_on_parent_id", using: :btree
  add_index "gwfaq_recognizers", ["title_id"], name: "index_gwfaq_recognizers_on_title_id", using: :btree

  create_table "gwfaq_roles", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.string   "role_code"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "gwfaq_roles", ["title_id"], name: "index_gwfaq_roles_on_title_id", using: :btree

  create_table "gwmonitor_base_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  add_index "gwmonitor_base_files", ["title_id"], name: "index_gwmonitor_base_files_on_title_id", using: :btree

  create_table "gwmonitor_controls", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "latest_updated_at"
    t.string   "section_code"
    t.string   "section_name"
    t.integer  "section_sort"
    t.string   "name"
    t.integer  "form_id"
    t.string   "form_name"
    t.string   "form_caption"
    t.integer  "upload_system"
    t.integer  "admin_setting"
    t.integer  "spec_config"
    t.string   "title"
    t.text     "caption"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "reminder_start_section"
    t.integer  "reminder_start_personal"
    t.integer  "public_count"
    t.integer  "draft_count"
    t.text     "createdate"
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",                              limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision"
    t.string   "editor_id",                               limit: 20
    t.text     "editor"
    t.integer  "default_limit"
    t.text     "dsp_admin_name"
    t.string   "send_change"
    t.text     "custom_groups"
    t.text     "custom_groups_json"
    t.text     "reader_groups"
    t.text     "reader_groups_json"
    t.text     "custom_readers"
    t.text     "custom_readers_json"
    t.text     "readers"
    t.text     "readers_json"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                 precision: 17, scale: 0
    t.decimal  "upload_document_file_size_currently",                precision: 17, scale: 0
    t.integer  "wiki"
    t.text     "form_configs"
  end

  create_table "gwmonitor_custom_groups", force: true do |t|
    t.integer  "parent_id"
    t.integer  "class_id"
    t.integer  "owner_uid"
    t.integer  "owner_gid"
    t.integer  "updater_uid"
    t.integer  "updater_gid"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.text     "name"
    t.text     "name_en"
    t.integer  "sort_no"
    t.text     "sort_prefix"
    t.integer  "is_default"
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
  end

  add_index "gwmonitor_custom_groups", ["owner_uid"], name: "index_gwmonitor_custom_groups_on_owner_uid", using: :btree

  create_table "gwmonitor_custom_user_groups", force: true do |t|
    t.integer  "parent_id"
    t.integer  "class_id"
    t.integer  "owner_uid"
    t.integer  "owner_gid"
    t.integer  "updater_uid"
    t.integer  "updater_gid"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.text     "name"
    t.text     "name_en"
    t.integer  "sort_no"
    t.text     "sort_prefix"
    t.integer  "is_default"
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
  end

  add_index "gwmonitor_custom_user_groups", ["owner_uid"], name: "index_gwmonitor_custom_user_groups_on_owner_uid", using: :btree

  create_table "gwmonitor_docs", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "latest_updated_at"
    t.integer  "send_division"
    t.string   "user_code",                  limit: 20
    t.string   "user_name"
    t.string   "l2_section_code"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "section_sort"
    t.string   "email"
    t.boolean  "email_send"
    t.integer  "title_id"
    t.text     "name"
    t.text     "title"
    t.text     "head",                       limit: 16777215
    t.text     "body",                       limit: 16777215
    t.text     "note",                       limit: 16777215
    t.text     "keywords"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id",         limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",                 limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",          limit: 20
    t.text     "editordivision"
    t.string   "editor_id",                  limit: 20
    t.text     "editor"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.datetime "remind_start_date"
    t.datetime "remind_start_date_personal"
    t.string   "receipt_user_code"
    t.integer  "attachmentfile"
  end

  add_index "gwmonitor_docs", ["title_id"], name: "index_gwmonitor_docs_on_title_id", using: :btree

  create_table "gwmonitor_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  add_index "gwmonitor_files", ["parent_id"], name: "index_gwmonitor_files_on_parent_id", using: :btree
  add_index "gwmonitor_files", ["title_id"], name: "index_gwmonitor_files_on_title_id", using: :btree

  create_table "gwmonitor_forms", force: true do |t|
    t.integer  "unid"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.string   "form_name"
    t.text     "form_caption"
  end

  create_table "gwmonitor_itemdeletes", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code"
    t.integer  "title_id"
    t.text     "board_title"
    t.string   "board_state"
    t.string   "board_view_hide"
    t.integer  "board_sort_no"
    t.integer  "public_doc_count"
    t.integer  "void_doc_count"
    t.string   "dbname"
    t.string   "limit_date"
    t.string   "board_limit_date"
  end

  create_table "gwqa_adms", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "gwqa_adms", ["title_id"], name: "index_gwqa_adms_on_title_id", using: :btree

  create_table "gwqa_categories", force: true do |t|
    t.integer  "unid"
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.text     "name"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwqa_categories", ["title_id"], name: "index_gwqa_categories_on_title_id", using: :btree

  create_table "gwqa_controls", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                 precision: 17, scale: 0
    t.decimal  "upload_document_file_size_currently",                precision: 17, scale: 0
    t.string   "create_section"
    t.integer  "addnew_forbidden"
    t.integer  "draft_forbidden"
    t.integer  "delete_forbidden"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern"
    t.string   "left_index_bg_color"
    t.text     "other_system_link"
    t.text     "wallpaper"
    t.text     "css"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.boolean  "group_view"
    t.integer  "notification"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",                              limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision"
    t.string   "editor_id",                               limit: 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.datetime "docslast_updated_at"
  end

  add_index "gwqa_controls", ["notification"], name: "index_gwqa_controls_on_notification", using: :btree

  create_table "gwqa_db_files", force: true do |t|
    t.integer "title_id"
    t.integer "parent_id"
    t.binary  "data",      limit: 2147483647
    t.integer "serial_no"
    t.integer "migrated"
  end

  add_index "gwqa_db_files", ["parent_id"], name: "index_gwqa_db_files_on_parent_id", using: :btree
  add_index "gwqa_db_files", ["title_id"], name: "index_gwqa_db_files_on_title_id", using: :btree

  create_table "gwqa_docs", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.text     "content_state"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "importance"
    t.integer  "one_line_note"
    t.integer  "title_id"
    t.text     "name"
    t.text     "pname"
    t.text     "title"
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use"
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keywords"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
    t.datetime "expiry_date"
    t.integer  "attachmentfile"
    t.integer  "answer_count"
    t.text     "inpfld_001"
    t.text     "inpfld_002"
    t.datetime "latest_answer"
    t.integer  "wiki"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwqa_docs", ["title_id"], name: "index_gwqa_docs_on_title_id", using: :btree

  create_table "gwqa_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwqa_files", ["parent_id"], name: "index_gwqa_files_on_parent_id", using: :btree
  add_index "gwqa_files", ["title_id"], name: "index_gwqa_files_on_title_id", using: :btree

  create_table "gwqa_images", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.text     "parent_name"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  add_index "gwqa_images", ["parent_id"], name: "index_gwqa_images_on_parent_id", using: :btree
  add_index "gwqa_images", ["title_id"], name: "index_gwqa_images_on_title_id", using: :btree

  create_table "gwqa_recognizers", force: true do |t|
    t.integer  "unid"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "code"
    t.text     "name"
    t.datetime "recognized_at"
    t.integer  "serial_no"
    t.integer  "migrated"
  end

  add_index "gwqa_recognizers", ["parent_id"], name: "index_gwqa_recognizers_on_parent_id", using: :btree
  add_index "gwqa_recognizers", ["title_id"], name: "index_gwqa_recognizers_on_title_id", using: :btree

  create_table "gwqa_roles", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.string   "role_code"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  add_index "gwqa_roles", ["title_id"], name: "index_gwqa_roles_on_title_id", using: :btree

  create_table "gwsub_capacityunitsets", force: true do |t|
    t.integer  "code_int"
    t.text     "code"
    t.text     "name"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  add_index "gwsub_capacityunitsets", ["code_int"], name: "index_gwsub_capacityunitsets_on_code_int", using: :btree

  create_table "gwsub_externalmediakinds", force: true do |t|
    t.integer  "sort_order_int"
    t.text     "sort_order"
    t.text     "kind"
    t.text     "name"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  add_index "gwsub_externalmediakinds", ["sort_order_int"], name: "index_gwsub_externalmediakinds_on_sort_order_int", using: :btree

  create_table "gwsub_externalmedias", force: true do |t|
    t.integer  "new_registedno"
    t.integer  "section_id"
    t.string   "section_code"
    t.text     "section_name"
    t.text     "registedno"
    t.integer  "externalmediakind_id"
    t.string   "externalmediakind_name"
    t.text     "registed_seq"
    t.datetime "registed_at"
    t.text     "equipmentname"
    t.integer  "user_section_id"
    t.integer  "user_id"
    t.string   "user"
    t.integer  "categories"
    t.datetime "ending_at"
    t.text     "remarks"
    t.datetime "last_updated_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  add_index "gwsub_externalmedias", ["externalmediakind_id"], name: "index_gwsub_externalmedias_on_externalmediakind_id", using: :btree
  add_index "gwsub_externalmedias", ["section_id"], name: "index_gwsub_externalmedias_on_section_id", using: :btree
  add_index "gwsub_externalmedias", ["user_id"], name: "index_gwsub_externalmedias_on_user_id", using: :btree
  add_index "gwsub_externalmedias", ["user_section_id"], name: "index_gwsub_externalmedias_on_user_section_id", using: :btree

  create_table "gwsub_externalusbs", force: true do |t|
    t.integer  "new_registedno"
    t.integer  "section_id"
    t.string   "section_code"
    t.text     "section_name"
    t.text     "registedno"
    t.integer  "externalmediakind_id"
    t.datetime "registed_at"
    t.text     "equipmentname"
    t.text     "capacity"
    t.integer  "capacityunit_id"
    t.text     "sendstate"
    t.integer  "user_section_id"
    t.integer  "user_id"
    t.string   "user"
    t.integer  "categories"
    t.datetime "ending_at"
    t.text     "remarks"
    t.datetime "last_updated_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  add_index "gwsub_externalusbs", ["capacityunit_id"], name: "index_gwsub_externalusbs_on_capacityunit_id", using: :btree
  add_index "gwsub_externalusbs", ["externalmediakind_id"], name: "index_gwsub_externalusbs_on_externalmediakind_id", using: :btree
  add_index "gwsub_externalusbs", ["section_id"], name: "index_gwsub_externalusbs_on_section_id", using: :btree
  add_index "gwsub_externalusbs", ["user_id"], name: "index_gwsub_externalusbs_on_user_id", using: :btree
  add_index "gwsub_externalusbs", ["user_section_id"], name: "index_gwsub_externalusbs_on_user_section_id", using: :btree

  create_table "gwsub_sb00_conference_managers", force: true do |t|
    t.text     "controler"
    t.text     "controler_title"
    t.text     "memo_str"
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.integer  "group_id"
    t.text     "group_code"
    t.text     "group_name"
    t.integer  "user_id"
    t.text     "user_code"
    t.text     "user_name"
    t.integer  "official_title_id"
    t.text     "official_title_name"
    t.text     "send_state"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb00_conference_references", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "kind_code"
    t.text     "title"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.text     "kind_name"
    t.integer  "group_id"
  end

  create_table "gwsub_sb00_conference_section_manager_names", force: true do |t|
    t.integer  "fyear_id"
    t.text     "markjp"
    t.string   "state"
    t.integer  "parent_gid"
    t.integer  "gid"
    t.integer  "g_sort_no"
    t.string   "g_code"
    t.text     "g_name"
    t.text     "manager_name"
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "gwsub_sb01_training_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  add_index "gwsub_sb01_training_files", ["parent_id"], name: "index_gwsub_sb01_training_files_on_parent_id", using: :btree

  create_table "gwsub_sb01_training_guides", force: true do |t|
    t.text     "categories"
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "title"
    t.text     "bbs_url"
    t.text     "remarks"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "state"
    t.integer  "member_id"
    t.integer  "group_id"
  end

  create_table "gwsub_sb01_training_schedule_conditions", force: true do |t|
    t.integer  "training_id"
    t.integer  "members_max"
    t.text     "title"
    t.text     "from_start"
    t.text     "from_start_min"
    t.text     "from_end"
    t.text     "from_end_min"
    t.integer  "member_id"
    t.integer  "prop_id"
    t.text     "repeat_flg"
    t.text     "repeat_monthly"
    t.text     "repeat_weekday"
    t.datetime "from_at"
    t.datetime "to_at"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "state"
    t.integer  "group_id"
    t.text     "extension"
    t.integer  "prop_kind"
    t.text     "prop_name"
    t.integer  "repeat_class_id"
  end

  add_index "gwsub_sb01_training_schedule_conditions", ["training_id"], name: "index_gwsub_sb01_training_schedule_conditions_on_training_id", using: :btree

  create_table "gwsub_sb01_training_schedule_members", force: true do |t|
    t.integer  "training_id"
    t.integer  "schedule_id"
    t.integer  "condition_id"
    t.integer  "training_schedule_id"
    t.integer  "training_user_id"
    t.integer  "training_group_id"
    t.integer  "entry_user_id"
    t.integer  "entry_group_id"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "training_user_tel"
    t.text     "entry_user_tel"
  end

  add_index "gwsub_sb01_training_schedule_members", ["training_id"], name: "index_gwsub_sb01_training_schedule_members_on_training_id", using: :btree

  create_table "gwsub_sb01_training_schedule_props", force: true do |t|
    t.integer  "training_id"
    t.integer  "schedule_id"
    t.integer  "prop_id"
    t.integer  "members_max"
    t.integer  "members_current"
    t.integer  "member_id"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.integer  "condition_id"
    t.text     "from_start"
    t.text     "from_end"
    t.text     "state"
    t.integer  "group_id"
  end

  create_table "gwsub_sb01_training_schedules", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "training_id"
    t.integer  "condition_id"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.integer  "members_max"
    t.integer  "members_current"
    t.text     "state"
    t.datetime "from_start"
    t.datetime "from_end"
    t.text     "prop_name"
  end

  add_index "gwsub_sb01_training_schedules", ["training_id"], name: "index_gwsub_sb01_training_schedules_on_training_id", using: :btree

  create_table "gwsub_sb01_trainings", force: true do |t|
    t.text     "categories"
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "title"
    t.text     "bbs_url"
    t.text     "body"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "state"
    t.integer  "member_id"
    t.integer  "group_id"
    t.integer  "member_max"
    t.text     "group_code"
    t.text     "group_name"
    t.text     "member_code"
    t.text     "member_name"
    t.text     "member_tel"
    t.integer  "bbs_doc_id"
  end

  create_table "gwsub_sb04_check_assignedjobs", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.integer  "section_id"
    t.text     "section_code"
    t.text     "section_name"
    t.integer  "code_int"
    t.text     "code"
    t.text     "name"
    t.text     "tel"
    t.text     "address"
    t.text     "remarks"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb04_check_officialtitles", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.integer  "code_int"
    t.text     "code"
    t.text     "name"
    t.text     "remarks"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb04_check_sections", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "code"
    t.text     "name"
    t.text     "remarks"
    t.text     "bbs_url"
    t.text     "ldap_code"
    t.text     "ldap_name"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb04_check_stafflists", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "staff_no"
    t.text     "multi_section_flg"
    t.text     "name"
    t.text     "name_print"
    t.text     "kana"
    t.integer  "section_id"
    t.text     "section_code"
    t.text     "section_name"
    t.integer  "assignedjobs_id"
    t.integer  "assignedjobs_code_int"
    t.text     "assignedjobs_code"
    t.text     "assignedjobs_name"
    t.text     "assignedjobs_tel"
    t.text     "assignedjobs_address"
    t.integer  "official_title_id"
    t.text     "official_title_code"
    t.integer  "official_title_code_int"
    t.text     "official_title_name"
    t.integer  "categories_id"
    t.text     "categories_code"
    t.text     "categories_name"
    t.text     "extension"
    t.text     "divide_duties"
    t.text     "divide_duties_order"
    t.integer  "divide_duties_order_int"
    t.text     "remarks"
    t.text     "personal_state"
    t.text     "display_state"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb04_editable_dates", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.datetime "published_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "headline_at"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
  end

  create_table "gwsub_sb04_limit_settings", force: true do |t|
    t.string   "type_name"
    t.integer  "limit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
  end

  create_table "gwsub_sb04_seating_lists", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "title"
    t.text     "bbs_url"
    t.text     "remarks"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
  end

  create_table "gwsub_sb04_settings", force: true do |t|
    t.string   "name"
    t.string   "type_name"
    t.text     "data"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gwsub_sb04_year_copy_logs", force: true do |t|
    t.string   "type"
    t.integer  "origin_fyear_id"
    t.integer  "origin_section_id"
    t.string   "origin_section_code"
    t.text     "origin_section_name"
    t.integer  "destination_fyear_id"
    t.integer  "destination_section_id"
    t.string   "destination_section_code"
    t.text     "destination_section_name"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb04assignedjobs", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.integer  "section_id"
    t.text     "section_code"
    t.text     "section_name"
    t.integer  "code_int"
    t.text     "code"
    t.text     "name"
    t.text     "tel"
    t.text     "address"
    t.text     "remarks"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb04helps", force: true do |t|
    t.integer  "categories"
    t.text     "title"
    t.text     "bbs_url"
    t.text     "remarks"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb04officialtitles", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.integer  "code_int"
    t.text     "code"
    t.text     "name"
    t.text     "remarks"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb04sections", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "code"
    t.text     "name"
    t.text     "remarks"
    t.text     "bbs_url"
    t.text     "ldap_code"
    t.text     "ldap_name"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  add_index "gwsub_sb04sections", ["code"], name: "code", length: {"code"=>10}, using: :btree
  add_index "gwsub_sb04sections", ["fyear_id"], name: "fyear_id", using: :btree

  create_table "gwsub_sb04stafflists", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "staff_no"
    t.text     "multi_section_flg"
    t.text     "name"
    t.text     "name_print"
    t.text     "kana"
    t.integer  "section_id"
    t.text     "section_code"
    t.text     "section_name"
    t.integer  "assignedjobs_id"
    t.integer  "assignedjobs_code_int"
    t.text     "assignedjobs_code"
    t.text     "assignedjobs_name"
    t.text     "assignedjobs_tel"
    t.text     "assignedjobs_address"
    t.integer  "official_title_id"
    t.text     "official_title_code"
    t.integer  "official_title_code_int"
    t.text     "official_title_name"
    t.integer  "categories_id"
    t.text     "categories_code"
    t.text     "categories_name"
    t.text     "extension"
    t.text     "divide_duties"
    t.text     "divide_duties_order"
    t.integer  "divide_duties_order_int"
    t.text     "remarks"
    t.text     "personal_state"
    t.text     "display_state"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  add_index "gwsub_sb04stafflists", ["fyear_id"], name: "fyear_id", using: :btree
  add_index "gwsub_sb04stafflists", ["fyear_markjp"], name: "fyear_markjp", length: {"fyear_markjp"=>10}, using: :btree

  create_table "gwsub_sb05_db_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.text     "file_state"
  end

  create_table "gwsub_sb05_desired_date_conditions", force: true do |t|
    t.integer  "media_id"
    t.boolean  "w1",         default: false
    t.boolean  "w2",         default: false
    t.boolean  "w3",         default: false
    t.boolean  "w4",         default: false
    t.boolean  "w5",         default: false
    t.boolean  "d0",         default: false
    t.boolean  "d1",         default: false
    t.boolean  "d2",         default: false
    t.boolean  "d3",         default: false
    t.boolean  "d4",         default: false
    t.boolean  "d5",         default: false
    t.boolean  "d6",         default: false
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gwsub_sb05_desired_dates", force: true do |t|
    t.integer  "media_id"
    t.datetime "desired_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.text     "media_code"
    t.text     "weekday"
    t.text     "monthly"
    t.datetime "edit_limit_at"
  end

  create_table "gwsub_sb05_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.text     "file_state"
  end

  create_table "gwsub_sb05_media_types", force: true do |t|
    t.integer  "media_code"
    t.text     "media_name"
    t.integer  "categories_code"
    t.text     "categories_name"
    t.integer  "max_size"
    t.integer  "state"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb05_notices", force: true do |t|
    t.integer  "media_id"
    t.integer  "media_code"
    t.text     "media_name"
    t.integer  "categories_code"
    t.text     "categories_name"
    t.text     "sample"
    t.text     "remarks"
    t.text     "form_templates"
    t.text     "admin_remarks"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb05_recognizers", force: true do |t|
    t.integer  "parent_id"
    t.integer  "user_id"
    t.text     "recognized_at"
    t.integer  "mode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gwsub_sb05_requests", force: true do |t|
    t.integer  "sb05_users_id"
    t.text     "user_code"
    t.text     "user_name"
    t.text     "user_display"
    t.text     "org_code"
    t.text     "org_name"
    t.text     "org_display"
    t.text     "telephone"
    t.integer  "media_id"
    t.integer  "media_code"
    t.text     "media_name"
    t.integer  "categories_code"
    t.text     "categories_name"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "title"
    t.text     "body1"
    t.text     "magazine_url"
    t.text     "magazine_url_mobile"
    t.integer  "mm_attachiment"
    t.text     "img"
    t.datetime "contract_at"
    t.datetime "base_at"
    t.text     "magazine_state"
    t.text     "r_state"
    t.text     "m_state"
    t.text     "admin_remarks"
    t.text     "notes_imported"
    t.datetime "notes_updated_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.text     "mm_image_state"
    t.text     "attaches_file"
  end

  create_table "gwsub_sb05_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "org_id"
    t.text     "user_code"
    t.text     "user_name"
    t.text     "user_display"
    t.text     "org_code"
    t.text     "org_name"
    t.text     "org_display"
    t.text     "telephone"
    t.text     "notes_imported"
    t.datetime "notes_updated_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb06_assigned_conf_categories", force: true do |t|
    t.integer  "cat_sort_no"
    t.text     "cat_code"
    t.text     "cat_name"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "select_list"
  end

  create_table "gwsub_sb06_assigned_conf_groups", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.integer  "group_id"
    t.text     "group_code"
    t.text     "group_name"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.integer  "categories_id"
    t.integer  "cat_sort_no"
    t.text     "cat_code"
    t.text     "cat_name"
  end

  create_table "gwsub_sb06_assigned_conf_items", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.integer  "conf_kind_id"
    t.integer  "item_sort_no"
    t.text     "item_title"
    t.integer  "item_max_count"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.integer  "select_list"
  end

  create_table "gwsub_sb06_assigned_conf_kinds", force: true do |t|
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.integer  "conf_cat_id"
    t.text     "conf_kind_code"
    t.text     "conf_kind_name"
    t.integer  "conf_kind_sort_no"
    t.text     "conf_menu_name"
    t.text     "conf_to_name"
    t.text     "conf_title"
    t.text     "conf_form_no"
    t.integer  "conf_max_count"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.integer  "select_list"
    t.text     "conf_body"
  end

  create_table "gwsub_sb06_assigned_conference_members", force: true do |t|
    t.datetime "created_at"
    t.text     "created_user"
    t.integer  "created_user_id"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.integer  "updated_user_id"
    t.text     "updated_group"
    t.integer  "conference_id"
    t.text     "state"
    t.integer  "categories_id"
    t.integer  "cat_sort_no"
    t.text     "cat_code"
    t.text     "cat_name"
    t.integer  "conf_kind_id"
    t.integer  "conf_kind_sort_no"
    t.text     "conf_kind_name"
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "fyear_namejp"
    t.text     "conf_mark"
    t.text     "conf_no"
    t.integer  "conf_group_id"
    t.text     "conf_group_code"
    t.text     "conf_group_name"
    t.datetime "conf_at"
    t.integer  "section_manager_id"
    t.integer  "group_id"
    t.text     "group_code"
    t.text     "group_name"
    t.text     "group_name_display"
    t.text     "conf_kind_place"
    t.integer  "conf_item_id"
    t.integer  "conf_item_sort_no"
    t.text     "conf_item_title"
    t.text     "work_name"
    t.text     "work_kind"
    t.integer  "official_title_id"
    t.text     "official_title_name"
    t.integer  "sort_no"
    t.integer  "user_id"
    t.text     "user_name"
    t.text     "extension"
    t.text     "user_mail"
    t.text     "user_job_name"
    t.datetime "start_at"
    t.text     "remarks"
    t.integer  "user_section_id"
    t.text     "user_section_name"
    t.integer  "user_section_sort_no"
    t.integer  "main_group_id"
    t.text     "main_group_name"
    t.integer  "main_group_sort_no"
  end

  create_table "gwsub_sb06_assigned_conferences", force: true do |t|
    t.datetime "created_at"
    t.text     "created_user"
    t.integer  "created_user_id"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.integer  "updated_user_id"
    t.text     "updated_group"
    t.text     "state"
    t.integer  "categories_id"
    t.integer  "cat_sort_no"
    t.text     "cat_code"
    t.text     "cat_name"
    t.integer  "conf_kind_id"
    t.integer  "conf_kind_sort_no"
    t.text     "conf_kind_name"
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.text     "fyear_namejp"
    t.text     "conf_mark"
    t.text     "conf_no"
    t.integer  "conf_group_id"
    t.text     "conf_group_code"
    t.text     "conf_group_name"
    t.datetime "conf_at"
    t.integer  "section_manager_id"
    t.integer  "group_id"
    t.text     "group_code"
    t.text     "group_name"
    t.text     "group_name_display"
    t.text     "conf_kind_place"
    t.integer  "conf_item_id"
    t.integer  "conf_item_sort_no"
    t.text     "conf_item_title"
    t.text     "work_name"
    t.text     "work_kind"
    t.integer  "official_title_id"
    t.text     "official_title_name"
    t.integer  "sort_no"
    t.integer  "user_id"
    t.text     "user_name"
    t.text     "extension"
    t.text     "user_mail"
    t.text     "user_job_name"
    t.datetime "start_at"
    t.text     "remarks"
    t.integer  "user_section_id"
    t.text     "user_section_name"
    t.integer  "user_section_sort_no"
    t.integer  "main_group_id"
    t.text     "main_group_name"
    t.integer  "main_group_sort_no"
    t.integer  "admin_group_id"
    t.text     "admin_group_code"
    t.text     "admin_group_name"
  end

  create_table "gwsub_sb06_assigned_helps", force: true do |t|
    t.integer  "help_kind"
    t.integer  "conf_cat_id"
    t.integer  "conf_kind_sort_no"
    t.integer  "conf_kind_id"
    t.integer  "fyear_id"
    t.text     "fyear_markjp"
    t.integer  "conf_group_id"
    t.text     "title"
    t.text     "bbs_url"
    t.text     "remarks"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.string   "state"
    t.integer  "sort_no"
  end

  create_table "gwsub_sb06_assigned_official_titles", force: true do |t|
    t.text     "official_title_code"
    t.text     "official_title_name"
    t.integer  "official_title_sort_no"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
  end

  create_table "gwsub_sb06_budget_assign_admins", force: true do |t|
    t.integer  "group_parent_id"
    t.text     "group_parent_ou"
    t.text     "group_parent_code"
    t.text     "group_parent_name"
    t.integer  "group_id"
    t.text     "group_ou"
    t.text     "group_code"
    t.text     "group_name"
    t.integer  "multi_group_parent_id"
    t.text     "multi_group_parent_ou"
    t.text     "multi_group_parent_code"
    t.text     "multi_group_parent_name"
    t.integer  "multi_group_id"
    t.text     "multi_group_ou"
    t.text     "multi_group_code"
    t.text     "multi_group_name"
    t.text     "multi_sequence"
    t.text     "multi_user_code"
    t.integer  "user_id"
    t.text     "user_code"
    t.text     "user_name"
    t.integer  "budget_role_id"
    t.text     "budget_role_code"
    t.text     "budget_role_name"
    t.text     "admin_state"
    t.text     "main_state"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb06_budget_assign_mains", force: true do |t|
    t.integer  "group_parent_id"
    t.text     "group_parent_ou"
    t.text     "group_parent_code"
    t.text     "group_parent_name"
    t.integer  "group_id"
    t.text     "group_ou"
    t.text     "group_code"
    t.text     "group_name"
    t.integer  "multi_group_parent_id"
    t.text     "multi_group_parent_ou"
    t.text     "multi_group_parent_code"
    t.text     "multi_group_parent_name"
    t.integer  "multi_group_id"
    t.text     "multi_group_ou"
    t.text     "multi_group_code"
    t.text     "multi_group_name"
    t.text     "multi_sequence"
    t.text     "multi_user_code"
    t.integer  "user_id"
    t.text     "user_code"
    t.text     "user_name"
    t.integer  "budget_role_id"
    t.text     "budget_role_code"
    t.text     "budget_role_name"
    t.text     "admin_state"
    t.text     "main_state"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb06_budget_assigns", force: true do |t|
    t.integer  "group_parent_id"
    t.text     "group_parent_ou"
    t.text     "group_parent_code"
    t.text     "group_parent_name"
    t.integer  "group_id"
    t.text     "group_ou"
    t.text     "group_code"
    t.text     "group_name"
    t.integer  "multi_group_parent_id"
    t.text     "multi_group_parent_ou"
    t.text     "multi_group_parent_code"
    t.text     "multi_group_parent_name"
    t.integer  "multi_group_id"
    t.text     "multi_group_ou"
    t.text     "multi_group_code"
    t.text     "multi_group_name"
    t.text     "multi_sequence"
    t.text     "multi_user_code"
    t.integer  "user_id"
    t.text     "user_code"
    t.text     "user_name"
    t.integer  "budget_role_id"
    t.text     "budget_role_code"
    t.text     "budget_role_name"
    t.text     "admin_state"
    t.text     "main_state"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwsub_sb06_budget_editable_dates", force: true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "recognize_at"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
  end

  create_table "gwsub_sb06_budget_notices", force: true do |t|
    t.text     "kind"
    t.text     "title"
    t.text     "bbs_url"
    t.text     "remarks"
    t.text     "state"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
  end

  create_table "gwsub_sb06_budget_roles", force: true do |t|
    t.text     "code"
    t.text     "name"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
  end

  create_table "gwsub_sb06_recognizers", force: true do |t|
    t.integer  "parent_id"
    t.integer  "user_id"
    t.text     "recognized_at"
    t.integer  "mode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gwsub_sb12_groups", force: true do |t|
    t.text     "state"
    t.string   "code"
    t.text     "name"
    t.integer  "sort_no"
    t.integer  "ldap"
    t.datetime "latest_updated_at"
  end

  create_table "gwsub_sb13_groups", force: true do |t|
    t.text     "state"
    t.string   "code"
    t.text     "name"
    t.integer  "sort_no"
    t.integer  "ldap"
    t.datetime "latest_updated_at"
  end

  create_table "gwworkflow_files", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  create_table "intra_maintenances", force: true do |t|
    t.integer  "unid"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title"
    t.text     "body"
  end

  create_table "intra_messages", force: true do |t|
    t.integer  "unid"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title"
    t.text     "body"
  end

  create_table "questionnaire_bases", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section_code"
    t.string   "section_name"
    t.integer  "section_sort"
    t.boolean  "enquete_division"
    t.integer  "admin_setting"
    t.string   "manage_title"
    t.string   "title"
    t.text     "form_body"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "spec_config"
    t.string   "send_change"
    t.text     "remarks"
    t.text     "remarks_setting"
    t.integer  "send_to"
    t.integer  "send_to_kind"
    t.text     "createdate"
    t.string   "createrdivision_id",  limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",          limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",   limit: 20
    t.text     "editordivision"
    t.string   "editor_id",           limit: 20
    t.text     "editor"
    t.text     "custom_groups"
    t.text     "custom_groups_json"
    t.text     "reader_groups"
    t.text     "reader_groups_json"
    t.text     "custom_readers"
    t.text     "custom_readers_json"
    t.text     "readers"
    t.text     "readers_json"
    t.integer  "default_limit"
    t.integer  "answer_count"
    t.boolean  "include_index"
    t.boolean  "result_open_state"
    t.string   "keycode"
  end

  create_table "questionnaire_field_options", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.integer  "field_id"
    t.integer  "sort_no"
    t.string   "value"
    t.text     "title"
  end

  create_table "questionnaire_form_fields", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "sort_no"
    t.string   "question_type"
    t.string   "title"
    t.string   "field_cols"
    t.string   "field_rows"
    t.integer  "post_permit_base"
    t.integer  "post_permit"
    t.string   "post_permit_value"
    t.text     "option_body"
    t.string   "field_name"
    t.integer  "view_type"
    t.integer  "required_entry"
    t.boolean  "auto_number_state"
    t.integer  "auto_number"
    t.integer  "group_code"
    t.string   "group_field"
    t.text     "group_body"
    t.integer  "group_repeat"
    t.text     "group_name"
  end

  create_table "questionnaire_itemdeletes", force: true do |t|
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code"
    t.string   "limit_date"
  end

  create_table "questionnaire_previews", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.text     "field_001"
    t.text     "field_002"
    t.text     "field_003"
    t.text     "field_004"
    t.text     "field_005"
    t.text     "field_006"
    t.text     "field_007"
    t.text     "field_008"
    t.text     "field_009"
    t.text     "field_010"
    t.text     "field_011"
    t.text     "field_012"
    t.text     "field_013"
    t.text     "field_014"
    t.text     "field_015"
    t.text     "field_016"
    t.text     "field_017"
    t.text     "field_018"
    t.text     "field_019"
    t.text     "field_020"
    t.text     "field_021"
    t.text     "field_022"
    t.text     "field_023"
    t.text     "field_024"
    t.text     "field_025"
    t.text     "field_026"
    t.text     "field_027"
    t.text     "field_028"
    t.text     "field_029"
    t.text     "field_030"
    t.text     "field_031"
    t.text     "field_032"
    t.text     "field_033"
    t.text     "field_034"
    t.text     "field_035"
    t.text     "field_036"
    t.text     "field_037"
    t.text     "field_038"
    t.text     "field_039"
    t.text     "field_040"
    t.text     "field_041"
    t.text     "field_042"
    t.text     "field_043"
    t.text     "field_044"
    t.text     "field_045"
    t.text     "field_046"
    t.text     "field_047"
    t.text     "field_048"
    t.text     "field_049"
    t.text     "field_050"
    t.text     "field_051"
    t.text     "field_052"
    t.text     "field_053"
    t.text     "field_054"
    t.text     "field_055"
    t.text     "field_056"
    t.text     "field_057"
    t.text     "field_058"
    t.text     "field_059"
    t.text     "field_060"
    t.text     "field_061"
    t.text     "field_062"
    t.text     "field_063"
    t.text     "field_064"
    t.text     "createdate"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
  end

  create_table "questionnaire_results", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "field_id"
    t.string   "question_type"
    t.text     "question_label"
    t.integer  "option_id"
    t.text     "option_label"
    t.integer  "sort_no"
    t.integer  "answer_count"
    t.decimal  "answer_ratio",   precision: 10, scale: 5
  end

  create_table "questionnaire_template_bases", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section_code"
    t.string   "section_name"
    t.integer  "section_sort"
    t.boolean  "enquete_division"
    t.integer  "admin_setting"
    t.string   "manage_title"
    t.string   "title"
    t.text     "form_body"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "spec_config"
    t.string   "send_change"
    t.text     "createdate"
    t.string   "createrdivision_id",  limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",          limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",   limit: 20
    t.text     "editordivision"
    t.string   "editor_id",           limit: 20
    t.text     "editor"
    t.text     "custom_groups"
    t.text     "custom_groups_json"
    t.text     "reader_groups"
    t.text     "reader_groups_json"
    t.text     "custom_readers"
    t.text     "custom_readers_json"
    t.text     "readers"
    t.text     "readers_json"
    t.integer  "default_limit"
  end

  create_table "questionnaire_template_field_options", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.integer  "field_id"
    t.integer  "sort_no"
    t.string   "value"
    t.text     "title"
  end

  create_table "questionnaire_template_form_fields", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "sort_no"
    t.string   "question_type"
    t.string   "title"
    t.string   "field_cols"
    t.string   "field_rows"
    t.integer  "post_permit_base"
    t.integer  "post_permit"
    t.string   "post_permit_value"
    t.text     "option_body"
    t.string   "field_name"
    t.integer  "view_type"
    t.integer  "required_entry"
    t.boolean  "auto_number_state"
    t.integer  "auto_number"
    t.integer  "group_code"
    t.string   "group_field"
    t.text     "group_body"
    t.integer  "group_repeat"
    t.text     "group_name"
  end

  create_table "questionnaire_template_previews", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.text     "field_001"
    t.text     "field_002"
    t.text     "field_003"
    t.text     "field_004"
    t.text     "field_005"
    t.text     "field_006"
    t.text     "field_007"
    t.text     "field_008"
    t.text     "field_009"
    t.text     "field_010"
    t.text     "field_011"
    t.text     "field_012"
    t.text     "field_013"
    t.text     "field_014"
    t.text     "field_015"
    t.text     "field_016"
    t.text     "field_017"
    t.text     "field_018"
    t.text     "field_019"
    t.text     "field_020"
    t.text     "field_021"
    t.text     "field_022"
    t.text     "field_023"
    t.text     "field_024"
    t.text     "field_025"
    t.text     "field_026"
    t.text     "field_027"
    t.text     "field_028"
    t.text     "field_029"
    t.text     "field_030"
    t.text     "field_031"
    t.text     "field_032"
    t.text     "field_033"
    t.text     "field_034"
    t.text     "field_035"
    t.text     "field_036"
    t.text     "field_037"
    t.text     "field_038"
    t.text     "field_039"
    t.text     "field_040"
    t.text     "field_041"
    t.text     "field_042"
    t.text     "field_043"
    t.text     "field_044"
    t.text     "field_045"
    t.text     "field_046"
    t.text     "field_047"
    t.text     "field_048"
    t.text     "field_049"
    t.text     "field_050"
    t.text     "field_051"
    t.text     "field_052"
    t.text     "field_053"
    t.text     "field_054"
    t.text     "field_055"
    t.text     "field_056"
    t.text     "field_057"
    t.text     "field_058"
    t.text     "field_059"
    t.text     "field_060"
    t.text     "field_061"
    t.text     "field_062"
    t.text     "field_063"
    t.text     "field_064"
    t.text     "createdate"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision"
    t.string   "creater_id",         limit: 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision"
    t.string   "editor_id",          limit: 20
    t.text     "editor"
  end

  create_table "questionnaire_temporaries", force: true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "field_id"
    t.string   "question_type"
    t.text     "answer_text"
    t.integer  "answer_option"
  end

  add_index "questionnaire_temporaries", ["title_id"], name: "title_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "system_admin_logs", force: true do |t|
    t.datetime "created_at"
    t.integer  "user_id"
    t.integer  "item_unid"
    t.text     "controller"
    t.text     "action"
  end

  create_table "system_authorizations", id: false, force: true do |t|
    t.integer  "user_id",                   default: 0, null: false
    t.string   "user_code",                             null: false
    t.text     "user_name"
    t.text     "user_name_en"
    t.text     "user_password"
    t.text     "user_email"
    t.text     "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "group_id",                  default: 0, null: false
    t.string   "group_code"
    t.text     "group_name"
    t.text     "group_name_en"
    t.text     "group_email"
  end

  create_table "system_commitments", force: true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "version"
    t.text     "name"
    t.text     "value",      limit: 2147483647
  end

  create_table "system_creators", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unid"
    t.integer  "user_id",    null: false
    t.integer  "group_id",   null: false
  end

  create_table "system_custom_group_roles", primary_key: "rid", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "custom_group_id"
    t.text     "priv_name"
    t.integer  "user_id"
    t.integer  "class_id"
  end

  add_index "system_custom_group_roles", ["custom_group_id"], name: "custom_group_id", using: :btree
  add_index "system_custom_group_roles", ["group_id"], name: "group_id", using: :btree
  add_index "system_custom_group_roles", ["user_id"], name: "user_id", using: :btree

  create_table "system_custom_groups", force: true do |t|
    t.integer  "parent_id"
    t.integer  "class_id"
    t.integer  "owner_uid"
    t.integer  "owner_gid"
    t.integer  "updater_uid", null: false
    t.integer  "updater_gid", null: false
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.text     "name"
    t.text     "name_en"
    t.integer  "sort_no"
    t.text     "sort_prefix"
    t.integer  "is_default"
  end

  create_table "system_group_change_dates", force: true do |t|
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.datetime "start_at"
  end

  create_table "system_group_change_pickups", force: true do |t|
    t.datetime "target_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_group_changes", force: true do |t|
    t.text     "state"
    t.datetime "target_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_group_histories", force: true do |t|
    t.integer  "parent_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.integer  "version_id"
    t.string   "code"
    t.text     "name"
    t.text     "name_en"
    t.text     "group_s_name"
    t.text     "email"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no"
    t.string   "ldap_version"
    t.integer  "ldap"
  end

  create_table "system_group_histories_backups", force: true do |t|
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.integer  "version_id"
    t.string   "code"
    t.text     "name"
    t.text     "name_en"
    t.text     "group_s_name"
    t.text     "email"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no"
    t.string   "ldap_version"
    t.integer  "ldap"
  end

  create_table "system_group_history_temporaries", force: true do |t|
    t.integer  "parent_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.integer  "version_id"
    t.string   "code"
    t.text     "name"
    t.text     "name_en"
    t.text     "group_s_name"
    t.text     "email"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no"
    t.string   "ldap_version"
    t.integer  "ldap"
  end

  create_table "system_group_nexts", force: true do |t|
    t.integer  "group_update_id"
    t.text     "operation"
    t.integer  "old_group_id"
    t.text     "old_code"
    t.text     "old_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "old_parent_id"
  end

  create_table "system_group_temporaries", force: true do |t|
    t.integer  "parent_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.integer  "version_id"
    t.string   "code"
    t.text     "name"
    t.text     "name_en"
    t.text     "group_s_name"
    t.text     "email"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no"
    t.string   "ldap_version"
    t.integer  "ldap"
  end

  create_table "system_group_updates", force: true do |t|
    t.text     "parent_code"
    t.text     "parent_name"
    t.integer  "level_no"
    t.text     "code"
    t.text     "name"
    t.text     "state"
    t.datetime "start_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "parent_id"
  end

  create_table "system_group_versions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.datetime "start_at"
  end

  create_table "system_groups", force: true do |t|
    t.integer  "parent_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.integer  "version_id"
    t.string   "code"
    t.text     "name"
    t.text     "name_en"
    t.text     "group_s_name"
    t.text     "email"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no"
    t.string   "ldap_version"
    t.integer  "ldap"
  end

  add_index "system_groups", ["code"], name: "index_system_groups_on_code", using: :btree
  add_index "system_groups", ["ldap"], name: "index_system_groups_on_ldap", using: :btree
  add_index "system_groups", ["state"], name: "index_system_groups_on_state", using: :btree

  create_table "system_groups_backups", force: true do |t|
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.integer  "version_id"
    t.string   "code"
    t.text     "name"
    t.text     "name_en"
    t.text     "group_s_name"
    t.text     "email"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no"
    t.string   "ldap_version"
    t.integer  "ldap"
  end

  create_table "system_idconversions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "tablename"
    t.string   "modelname"
    t.datetime "converted_at"
  end

  create_table "system_inquiries", force: true do |t|
    t.integer  "unid"
    t.text     "state",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.text     "charge"
    t.text     "tel"
    t.text     "fax"
    t.text     "email"
  end

  create_table "system_languages", force: true do |t|
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no"
    t.text     "name"
    t.text     "title"
  end

  create_table "system_ldap_temporaries", force: true do |t|
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version"
    t.string   "data_type"
    t.string   "code"
    t.string   "sort_no"
    t.text     "name"
    t.text     "name_en"
    t.text     "group_s_name"
    t.text     "kana"
    t.text     "email"
    t.text     "match"
    t.string   "official_position"
    t.string   "assigned_job"
  end

  add_index "system_ldap_temporaries", ["version", "parent_id", "data_type", "sort_no"], name: "version", length: {"version"=>20, "parent_id"=>nil, "data_type"=>20, "sort_no"=>nil}, using: :btree
  add_index "system_ldap_temporaries", ["version"], name: "index_system_ldap_temporaries_on_version", using: :btree

  create_table "system_login_logs", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_login_logs", ["user_id"], name: "user_id", using: :btree

  create_table "system_maps", force: true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "name"
    t.text     "title"
    t.text     "map_lat"
    t.text     "map_lng"
    t.text     "map_zoom"
    t.text     "point1_name"
    t.text     "point1_lat"
    t.text     "point1_lng"
    t.text     "point2_name"
    t.text     "point2_lat"
    t.text     "point2_lng"
    t.text     "point3_name"
    t.text     "point3_lat"
    t.text     "point3_lng"
    t.text     "point4_name"
    t.text     "point4_lat"
    t.text     "point4_lng"
    t.text     "point5_name"
    t.text     "point5_lat"
    t.text     "point5_lng"
  end

  create_table "system_priv_names", force: true do |t|
    t.integer  "unid"
    t.text     "state"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name"
    t.text     "priv_name"
    t.integer  "sort_no"
  end

  create_table "system_product_synchro_plans", force: true do |t|
    t.string   "state"
    t.datetime "start_at"
    t.text     "product_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_product_synchro_plans", ["state", "start_at"], name: "index_system_product_synchro_plans_on_state_and_start_at", using: :btree

  create_table "system_product_synchros", force: true do |t|
    t.integer  "product_id"
    t.integer  "plan_id"
    t.string   "state"
    t.string   "version"
    t.text     "remark_temp"
    t.text     "remark_back"
    t.text     "remark_sync"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_product_synchros", ["plan_id"], name: "index_system_product_synchros_on_plan_id", using: :btree
  add_index "system_product_synchros", ["product_id"], name: "index_system_product_synchros_on_product_id", using: :btree
  add_index "system_product_synchros", ["state"], name: "index_system_product_synchros_on_state", using: :btree

  create_table "system_products", force: true do |t|
    t.string   "product_type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_no",                   default: 0
    t.integer  "product_synchro", limit: 1, default: 0
    t.integer  "sso",             limit: 1, default: 0
    t.text     "sso_url"
    t.text     "sso_url_mobile"
  end

  add_index "system_products", ["product_type"], name: "index_system_products_on_product_type", using: :btree

  create_table "system_public_logs", force: true do |t|
    t.datetime "created_at"
    t.integer  "user_id"
    t.integer  "item_unid"
    t.text     "controller"
    t.text     "action"
  end

  create_table "system_publishers", force: true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "name"
    t.text     "published_path"
    t.text     "content_type"
    t.integer  "content_length"
  end

  create_table "system_recognitions", force: true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "after_process"
  end

  create_table "system_recognizers", force: true do |t|
    t.integer  "unid"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.text     "name",          null: false
    t.integer  "user_id"
    t.datetime "recognized_at"
  end

  create_table "system_role_developers", force: true do |t|
    t.integer  "idx"
    t.integer  "class_id"
    t.string   "uid"
    t.integer  "priv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_name_id"
    t.text     "table_name"
    t.text     "priv_name"
    t.integer  "priv_user_id"
  end

  create_table "system_role_name_privs", force: true do |t|
    t.integer  "role_id"
    t.integer  "priv_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_role_name_privs", ["priv_id"], name: "index_system_role_name_privs_on_priv_id", using: :btree
  add_index "system_role_name_privs", ["role_id"], name: "index_system_role_name_privs_on_role_id", using: :btree

  create_table "system_role_names", force: true do |t|
    t.integer  "unid"
    t.text     "state"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name"
    t.text     "table_name"
    t.integer  "sort_no"
  end

  create_table "system_roles", force: true do |t|
    t.string   "table_name"
    t.string   "priv_name"
    t.integer  "idx"
    t.integer  "class_id"
    t.string   "uid"
    t.integer  "priv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_name_id"
    t.integer  "priv_user_id"
    t.integer  "group_id"
  end

  add_index "system_roles", ["table_name", "priv_name", "class_id", "uid", "idx"], name: "index_system_roles_on_table_name_and_priv_name_and_class_id_and", using: :btree

  create_table "system_sequences", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "name"
    t.integer  "version"
    t.integer  "value"
  end

  create_table "system_tags", force: true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "name"
    t.text     "word"
  end

  create_table "system_tasks", force: true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "process_at"
    t.text     "name"
  end

  create_table "system_unids", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "module"
    t.text     "item_type"
    t.integer  "item_id"
  end

  create_table "system_user_temporaries", force: true do |t|
    t.string   "air_login_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                      null: false
    t.integer  "ldap",                      null: false
    t.integer  "ldap_version"
    t.text     "auth_no"
    t.string   "sort_no"
    t.text     "name"
    t.text     "name_en"
    t.text     "kana"
    t.text     "password"
    t.integer  "mobile_access"
    t.string   "mobile_password"
    t.text     "email"
    t.string   "official_position"
    t.string   "assigned_job"
    t.text     "remember_token"
    t.datetime "remember_token_expires_at"
    t.text     "air_token"
  end

  add_index "system_user_temporaries", ["code"], name: "unique_user_code", unique: true, using: :btree

  create_table "system_users", force: true do |t|
    t.string   "air_login_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                      null: false
    t.integer  "ldap",                      null: false
    t.integer  "ldap_version"
    t.text     "auth_no"
    t.string   "sort_no"
    t.text     "name"
    t.text     "name_en"
    t.text     "group_s_name"
    t.text     "kana"
    t.text     "password"
    t.integer  "mobile_access"
    t.string   "mobile_password"
    t.text     "email"
    t.string   "official_position"
    t.string   "assigned_job"
    t.text     "remember_token"
    t.datetime "remember_token_expires_at"
    t.text     "air_token"
  end

  add_index "system_users", ["code"], name: "unique_user_code", unique: true, using: :btree
  add_index "system_users", ["ldap"], name: "index_system_users_on_ldap", using: :btree
  add_index "system_users", ["state"], name: "index_system_users_on_state", using: :btree

  create_table "system_users_backups", force: true do |t|
    t.string   "air_login_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                      null: false
    t.integer  "ldap",                      null: false
    t.integer  "ldap_version"
    t.text     "auth_no"
    t.string   "sort_no"
    t.text     "name"
    t.text     "name_en"
    t.text     "group_s_name"
    t.text     "kana"
    t.text     "password"
    t.integer  "mobile_access"
    t.string   "mobile_password"
    t.text     "email"
    t.string   "official_position"
    t.string   "assigned_job"
    t.text     "remember_token"
    t.datetime "remember_token_expires_at"
    t.text     "air_token"
  end

  add_index "system_users_backups", ["code"], name: "unique_user_code", unique: true, using: :btree

  create_table "system_users_custom_groups", primary_key: "rid", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "custom_group_id"
    t.integer  "user_id"
    t.text     "title"
    t.text     "title_en"
    t.integer  "sort_no"
    t.text     "icon"
  end

  add_index "system_users_custom_groups", ["custom_group_id"], name: "custom_group_id", using: :btree

  create_table "system_users_group_histories", primary_key: "rid", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "job_order"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code"
    t.string   "group_code"
  end

  create_table "system_users_group_histories_backups", primary_key: "rid", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "job_order"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code"
    t.string   "group_code"
  end

  create_table "system_users_group_history_temporaries", primary_key: "rid", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "job_order"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code"
    t.string   "group_code"
  end

  create_table "system_users_group_temporaries", primary_key: "rid", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "job_order"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code"
    t.string   "group_code"
  end

  create_table "system_users_groups", primary_key: "rid", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "job_order"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code"
    t.string   "group_code"
  end

  add_index "system_users_groups", ["group_id"], name: "index_system_users_groups_on_group_id", using: :btree
  add_index "system_users_groups", ["user_id"], name: "index_system_users_groups_on_user_id", using: :btree

  create_table "system_users_groups_backups", primary_key: "rid", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "job_order"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code"
    t.string   "group_code"
  end

  create_table "system_users_groups_csvdata", force: true do |t|
    t.string   "state",             null: false
    t.string   "data_type",         null: false
    t.integer  "level_no"
    t.integer  "parent_id",         null: false
    t.string   "parent_code",       null: false
    t.string   "code",              null: false
    t.integer  "sort_no"
    t.integer  "ldap",              null: false
    t.integer  "job_order"
    t.text     "name",              null: false
    t.text     "name_en"
    t.text     "kana"
    t.string   "password"
    t.integer  "mobile_access"
    t.string   "mobile_password"
    t.string   "email"
    t.string   "official_position"
    t.string   "assigned_job"
    t.datetime "start_at",          null: false
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
