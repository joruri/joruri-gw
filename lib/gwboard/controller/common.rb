# -*- encoding: utf-8 -*-
module Gwboard::Controller::Common

  def adminlib_sort_key
    return 'kind, category1_id, dsp_bunrui_no, publisher, datum_name'
  end

  def gwboard_sort_key(params,item=nil )
    str = ''
    case params[:state]
    when "TODAY"
      str = 'latest_updated_at DESC'
    when "DATE"
      str = 'latest_updated_at DESC'
    when "GROUP"
      str = 'section_code,  latest_updated_at DESC'
    when "CATEGORY"
      case item
      when 'gwbbs'
        str = 'gwbbs_categories.sort_no ,category1_id, latest_updated_at DESC'
      when 'gwfaq'
        str = 'gwfaq_categories.sort_no ,gwfaq_docs.category1_id, gwfaq_docs.title, gwfaq_docs.latest_updated_at DESC'
      else
        str = 'category1_id, latest_updated_at DESC'
      end
    else
      str = 'latest_updated_at DESC'
    end
    return str
  end

  def gwbbs_select_status(params)
    str = ''
    table_name  = ""
    if params[:controller] and !params[:controller].blank?
      table_name  = "#{params[:controller].slice(0,params[:controller].index('/'))}_docs"
    else
      table_name  = "gwbbs_docs"
    end
    case params[:state]
    when "DRAFT"
      str  = "#{table_name}.state = 'draft'"
      str += " AND #{table_name}.section_code = '#{Core.user_group.code}'" unless @is_admin
    when "RECOGNIZE"
      str  = "#{table_name}.state = 'recognize'"
      if @is_recognize_readable
      else
        str += " AND #{table_name}.section_code = '#{Core.user_group.code}'" unless @is_admin
      end
    when "PUBLISH"
      str  = "#{table_name}.state = 'recognized'"
      str += " AND #{table_name}.section_code = '#{Core.user_group.code}'" unless @is_admin
    when "TODAY"
      str  =  "#{table_name}.state = 'public' AND #{table_name}.latest_updated_at >= '" + Date.today.strftime("%Y-%m-%d") + " 00:00:00'"
      str += " AND '#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN #{table_name}.able_date AND #{table_name}.expiry_date"
    when "NEVER"
      str  = "#{table_name}.state = 'public' AND '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}' < #{table_name}.able_date"
      str += " AND #{table_name}.section_code = '#{Core.user_group.code}'" unless @is_admin
    when "VOID"
      str  = "#{table_name}.state = 'public' AND #{table_name}.expiry_date < '#{Time.now.strftime('%Y-%m-%d %H:%M')}:00'"
      str += " AND #{table_name}.section_code = '#{Core.user_group.code}'" unless @is_admin
    else
      str  =  "#{table_name}.state = 'public'"
      str += " AND '#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN #{table_name}.able_date AND #{table_name}.expiry_date"
    end

    if @title.restrict_access
      str += " AND #{table_name}.section_code = '#{Core.user_group.code}'"
    end unless @is_admin

    unless params[:mm].blank?
      from_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, 1)
      to_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, -1)
      str += " AND #{table_name}.latest_updated_at between '#{from_date.strftime("%Y/%m/%d")} 00:00:00' and '#{to_date.strftime("%Y/%m/%d")} 23:59:59'" if from_date if to_date
    end unless params[:yyyy].blank?
    return str
  end

  def gwboard_select_status(params)
    str = ''
    case params[:state]
    when "DRAFT"
      str = "state = 'draft'"
    when "RECOGNIZE"
      str = "state = 'recognize'"
    when "PUBLISH"
      str = "state = 'recognized'"
    when "TODAY"
      str = "state = 'public' AND latest_updated_at >= '" + Date.today.strftime("%Y/%m/%d") + " 00:00:00'"
    when "VOID"
      str = "state = 'public' AND expiry_date < '" + Date.today.strftime("%Y/%m/%d") + " 00:00:00'"
    else
      str = "state = 'public'"
    end

    unless params[:mm].blank?
      from_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, 1)
      to_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, -1)
      str += " AND latest_updated_at between '#{from_date.strftime("%Y/%m/%d")} 00:00:00' and '#{to_date.strftime("%Y/%m/%d")} 23:59:59'" if from_date if to_date
    end unless params[:yyyy].blank?

    unless params[:grp].blank?
      sectioncode = params[:grp]
      str += " AND section_code like '#{sectioncode}'"
    end

    return str
  end

  def gwfaq_select_status(params)
    str = ''
    case params[:state].to_s
    when "DRAFT"
      str  = "gwfaq_docs.state = 'draft'"
      str += " AND section_code = '#{Core.user_group.code}'" unless @is_admin
    when "RECOGNIZE"
      str  = "gwfaq_docs.state = 'recognize'"
      str += " AND section_code = '#{Core.user_group.code}'" unless @is_admin
    when "PUBLISH"
      str  = "gwfaq_docs.state = 'recognized'"
      str += " AND section_code = '#{Core.user_group.code}'" unless @is_admin
    when "TODAY"
      str = "gwfaq_docs.state = 'public' AND gwfaq_docs.latest_updated_at >= '" + Date.today.strftime("%Y/%m/%d") + " 00:00:00'"
    else
      str = "gwfaq_docs.state = 'public'"
    end
    return str
  end
  def gwqa_select_status(params)
    str = ''
    case params[:state]
    when "DRAFT"
      str = "state = 'draft'"
      str += " AND (section_code = '#{Core.user_group.code}' or creater_id = '#{Core.user.code}')" unless @is_admin  #管理者なら全記事対象
    when "RECOGNIZE"
      str = "state = 'recognize'"
    when "PUBLISH"
      str = "state = 'recognized'"
    when "TODAY"
      str = "state = 'public' AND latest_updated_at >= '" + Date.today.strftime("%Y/%m/%d") + " 00:00:00'"
    else
      str = "state = 'public'"
    end

    unless params[:mm].blank?
      from_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, 1)
      to_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, -1)
      str += " AND latest_updated_at between '#{from_date.strftime("%Y/%m/%d")} 00:00:00' and '#{to_date.strftime("%Y/%m/%d")} 23:59:59'" if from_date if to_date
    end unless params[:yyyy].blank?

    unless params[:grp].blank?
      sectioncode = params[:grp]
      str += " AND section_code like '#{sectioncode}'"
    end
    return str
  end

  def gwbbs_params_set
    str = ''
    str += "&state=#{params[:state]}" unless params[:state].blank?
    str += "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    str += "&grp=#{params[:grp]}" unless params[:grp].blank?
    str += "&yyyy=#{params[:yyyy]}" unless params[:yyyy].blank?
    str += "&mm=#{params[:mm]}" unless params[:mm].blank?
    str += "&page=#{params[:page]}" unless params[:page].blank?
    str += "&kwd=#{params[:kwd]}" unless params[:kwd].blank?
    return str
  end

  def adminlib_params_set
    return "&cat=#{params[:cat]}&state=#{params[:state]}&page=#{params[:page]}&limit=#{params[:limit]}&kwd=#{params[:kwd]}"
  end

  def initialize_value_set

    params[:limit] = @title.default_limit.to_s unless is_integer(params[:limit])
    params[:limit] = @title.default_limit.to_s if params[:limit].blank?
    params[:limit] = @title.default_limit.to_s if params[:limit].to_i < 1
    params[:limit] = @title.default_limit.to_s if 100 < params[:limit].to_i

    unless Core.request_uri.index("doclibrary")
      @css = ["/_common/themes/gw/css/gwboard/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column.css"]
    else
      @css = ["/_common/themes/gw/css/gwboard/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column_dl.css"]
    end

    @img_path = "public/_common/modules/#{@title.system_name}/"
  end

  def initialize_value_set_new_css
    params[:limit] = @title.default_limit.to_s unless is_integer(params[:limit])
    params[:limit] = @title.default_limit.to_s if params[:limit].blank?
    params[:limit] = @title.default_limit.to_s if params[:limit].to_i < 1
    params[:limit] = @title.default_limit.to_s if 100 < params[:limit].to_i

    s_kwd = params[:kwd]
    s_kwd = s_kwd.gsub(/　/,'').strip unless s_kwd.blank?
    params[:kwd] = nil if s_kwd.blank?

    unless Core.request_uri.index("doclibrary")
      unless params[:preview].blank?
        css_path = "/_attaches/css/preview/#{@title.system_name}/#{@title.id}.css"
      else
        css_path = "/_attaches/css/#{@title.system_name}/#{@title.id}.css"
      end
      f_path = "#{Rails.root}/public/#{css_path}"
      if FileTest.exist?(f_path)
        @css = [css_path, "/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column.css"]
      else
        @css = ["/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column.css"]
      end
    else
      @css = ["/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column_dl.css"]
    end

    @img_path = "public/_common/modules/#{@title.system_name}/"
  end

  def initialize_value_set_new_css_dl
    params[:limit] = @title.default_limit.to_s unless is_integer(params[:limit])
    params[:limit] = @title.default_limit.to_s if params[:limit].blank?
    params[:limit] = @title.default_limit.to_s if params[:limit].to_i < 1
    params[:limit] = @title.default_limit.to_s if 100 < params[:limit].to_i

    @css = ["/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column_dl.css"]

    @img_path = "public/_common/modules/#{@title.system_name}/"
  end

  def update_creater_editor
    @item.creater_admin = true
    @item.editor_admin = false

    mode = ''
    mode = 'create' if @item.createdate.blank?
    if @before_state == 'draft'
      mode = 'create'
    end if @item.editdate.blank?

    if mode == 'create'
      @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
      @item.creater_id = Core.user.code unless Core.user.code.blank?
      @item.creater = Core.user.name unless Core.user.name.blank?
      @item.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
      @item.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?

      @item.editor_id = Core.user.code unless Core.user.code.blank?
      @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?

      @item.creater_admin = true if @is_admin
      @item.creater_admin = false unless @is_admin
      @item.editor_admin = true if @is_admin          #1
      @item.editor_admin = false unless @is_admin     #0
    else
      @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
      @item.editor = Core.user.name unless Core.user.name.blank?
      @item.editordivision = Core.user_group.name unless Core.user_group.name.blank?

      @item.editor_id = Core.user.code unless Core.user.code.blank?
      @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
      @item.editor_admin = true if @is_admin          #1
      @item.editor_admin = false unless @is_admin     #0
    end

  end

  def update_creater_editor_circular
    if @item.doc_type == 0
      up_flg = false
      if @is_admin
        up_flg = true
      end if @item.createdate.blank?
      up_flg = true unless @is_admin
      if up_flg
        @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
        @item.creater_id = Core.user.code
        @item.creater = Core.user.name
        @item.createrdivision = Core.user_group.name
        @item.createrdivision_id = Core.user_group.code
      end
    end

    if @item.doc_type == 1
      up_flg = false
      if @is_admin
        up_flg = true
      end if @item.editdate.blank?
      up_flg = true unless @is_admin
      if up_flg
        @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
        @item.editor_id = Core.user.code unless Core.user.code.blank?
        @item.editor = Core.user.name unless Core.user.name.blank?
        @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
        @item.editordivision = Core.user_group.name unless Core.user_group.name.blank?
      end
    end
  end

  def is_vender_user
    ret = false
    ret = true if Core.user.code.length <= 3
    ret = true if Core.user.code == 'gwbbs'
    return ret
  end

  def users_collection(mode=nil)
    unless mode == 'edit'
      @select_recognizers = {"1"=>'',"2"=>'',"3"=>'',"4"=>'',"5"=>''}
      @select_recognizers = params[:item][:_recognizers] unless params[:item][:_recognizers].blank? unless params[:item].blank?
    end
    @users_collection = []
    sql = Condition.new
    sql.and "sql", "system_users_groups.group_id = #{Core.user_group.id}"
    join = "INNER JOIN system_users_groups ON system_users.id = system_users_groups.user_id"

    item = System::User.new
    users = item.find(:all, :joins=>join, :order=> 'code', :conditions=>sql.where)
    users.each do |u|
      next if u == Core.user && Core.user.ldap != 0
      next unless @is_admin if u.id == Core.user.id
      @users_collection << u
    end

    unless @select_recognizers.blank?
      for i in 1..5
        uid = @select_recognizers[i.to_s]
        users_collection_add(uid.to_i) unless uid.blank?
      end
    end
  end

  def users_collection_add(uid)
    flg = true
    @users_collection.each do |u|
      if uid == u.id
        flg = false if uid == u.id
      end
    end
    add_users_collection(uid) if flg
  end

  def add_users_collection(uid)
    sql = Condition.new
    sql.and "sql", "system_users_groups.user_id = #{uid}"
    join = "INNER JOIN system_users_groups ON system_users.id = system_users_groups.user_id"

    item = System::User.new
    users = item.find(:all, :joins=>join, :order=> 'code', :conditions=>sql.where)
    users.each do |u|
      next if u == Core.user && Core.user.ldap != 0
      next unless @is_admin if u.id == Core.user.id
      @users_collection << u
    end
  end

  def admin_item_deletes_path
    return '/gwbbs/itemdeletes'
  end

end