module Gwboard::Controller::SortKey

  def gwboard_sort_key(params)
    str = ''
    case params[:state]
    when "TODAY"
      str = 'latest_updated_at DESC'
    when "DATE"
      str = 'latest_updated_at DESC'
    when "GROUP"
      str = 'section_code, createrdivision_id, createrdivision, latest_updated_at DESC'
    when "CATEGORY"
      str = 'category1_id, latest_updated_at DESC'
    else
      str = 'latest_updated_at DESC'
    end
    return str
  end

  def gwbbs_select_status(params)
    str = ''
    case params[:state]
    when "DRAFT"
      str = "state = 'draft'" if @is_admin
      str = "state = 'draft' AND editor_id = '#{Core.user.code}' OR state = 'draft' AND editordivision_id = '#{Core.user_group.code}' AND editor_admin = 0" unless @is_admin
    when "RECOGNIZE"
      str = "state = 'recognize'"
    when "PUBLISH"
      str = "state = 'recognized'"
    when "TODAY"
      str =  "state = 'public' AND latest_updated_at >= '" + Date.today.strftime("%Y/%m/%d") + " 00:00:00'"
      str += " AND '" + Time.now.strftime("%Y/%m/%d %H:%M:%S") + "' between able_date and expiry_date"
    when "NEVER"
      str = "state = 'public' AND '" + Time.now.strftime("%Y/%m/%d %H:%M:%S") + "' < able_date"
    when "VOID"
      str = "state = 'public' AND expiry_date < '" + Date.today.strftime("%Y/%m/%d") + " 00:00:00'"
    else
      str =  "state = 'public'"
      str += " AND '" + Time.now.strftime("%Y/%m/%d %H:%M:%S") + "' between able_date and expiry_date"
    end

    unless params[:mm].blank?
        from_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, 1)
        to_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, -1)
        str += " AND latest_updated_at between '#{from_date.strftime("%Y/%m/%d")} 00:00:00' and '#{to_date.strftime("%Y/%m/%d")} 23:59:59'" if from_date if to_date
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
    return str
  end

  def gwbbs_params_set
    return "&cat1=#{params[:cat1]}&kwd=#{params[:kwd]}&yyyy=#{params[:yyyy]}&mm=#{params[:mm]}&state=#{params[:state]}&page=#{params[:page]}&limit=#{params[:limit]}"
  end

end