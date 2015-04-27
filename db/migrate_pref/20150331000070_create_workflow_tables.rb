class CreateWorkflowTables < ActiveRecord::Migration
  def change
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
      t.string   "creater_id",     limit: 20
      t.string   "creater_name",   limit: 20
      t.string   "creater_gname",  limit: 20
      t.integer  "attachmentfile"
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
  end
end
