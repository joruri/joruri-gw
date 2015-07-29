# encoding: utf-8
class Gw::ScheduleProp < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'
  belongs_to :prop, :polymorphic => true

  def self.select_ownergroup_id_list(all = nil, extra_model_s = "")
    item = self.new
    join = "left join gw_schedules on gw_schedule_props.schedule_id = gw_schedules.id"
    cond = "prop_type='#{extra_model_s}' and owner_gid IS NOT NULL"
    items = item.find(:all, :group=>"owner_gname", :joins=>join, :conditions=>cond, :order=>"owner_gcode").map{|x| [x.schedule.owner_gname ,x.schedule.owner_gid]}
    owner_gname_list = [['すべて','0']] + items   if all=='all'
    owner_gname_list = items                      unless all=='all'
    return owner_gname_list
  end

  def self.select_prop_list(all=nil, genre=nil)
    item = Gw::PropOther
    items = item.find(:all, :order=>"sort_no")
    prop_list = [['すべて','0']] if all=='all'
    items.each do |item|
      prop_list << [item.name , item.id]
    end
    return prop_list
  end

  def self.select_st_at_list(all=nil, extra_model_s = "")
    item = self.new
    join = "left join gw_schedules on gw_schedule_props.schedule_id = gw_schedules.id"
    select = 'gw_schedule_props.*, gw_schedules.st_at, gw_schedules.ed_at, gw_schedules.creator_gcode'
    cond = "prop_type='#{extra_model_s}' and gw_schedules.st_at  IS NOT NULL"
    items = item.find(:all , :group=>"date(gw_schedules.st_at)", :joins=>join, :conditions=>cond, :order=>"gw_schedules.st_at DESC")
    st_at_list  = []
    st_at_list = [["当日以降", "0"], ["当日", "1"], ["当日以前", "2"], ["すべて", "3"]] if all == 'all'
    st_at_list = [["当日以降", "0"]] if all == 'dynasty'
    items.each do |item|
      st_at_list << [item.schedule.st_at.strftime("%Y-%m-%d") , item.schedule.st_at.strftime("%Y-%m-%d")]
    end
    return st_at_list
  end

  def self.prop_params_set(params, params_keys = [:s_genre, :gid, :tree_page, :s_date, :prop_id, :type_id, :place_id])
    _params = Array.new
    params_keys.each do |col|
      if params.key?(col)
        _params << "#{col}=#{params[col]}"
      end
    end
    if _params.length > 0
      prm = Gw.join(_params, '&')
    else
      prm = ""
    end
    return prm
  end

  def self.is_admin?(genre, extra_flag, options={})
    _ef = nz(extra_flag, 'other')
    return true if _ef == 'other'
    return false
  end

  def search_where(params)
    ret_a = []
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_genre'
        prop_type = "Gw::Prop#{v.capitalize}"
        ret_a.push "prop_type='#{prop_type}'"
      end
    end if params.size != 0
    return ret_a.collect{|x| "(#{x})"}.join(" and ")
  end

  def self.get_genres
    ':other/一般施設'.split(':').map{|x| x.split('/')}
  end

  def self.get_genre_select(options={})
    prop_types = Gw::PropType.find(:all, :conditions => ["state = ?", "public"], :select => "id, name", :order => "sort_no, id")
    types = []
    prop_types.each do |prop_type|
      types << [prop_type.name, "prop_other_#{prop_type.id}" ]
    end
    return types
  end

  def self.prop_conv(conv, val)
    ret = case conv
    when :genre_to_mdl
      "Gw::Prop#{val.camelize}"
    when :mdl_to_genre
      val.sub(/^Gw::Prop/, '').underscore
    end
    return ret
  end

  def owner_s(options={})
    genre = prop.class.name.split('::').last.gsub(/^Prop/, '').downcase
    owner_class = prop.extra_flag
    case genre
    when 'other'
      prop.gname
    else
      prop_classes_raw[genre][owner_class]
    end
  end

  def get_extra_data
    _extra_data = nz(extra_data)
    _extra_data.blank? ? {} : JsonParser.new.parse(_extra_data) rescue {:error=>1}
  end

  def set_extra_data(set_data, options={})
    set_data_h = set_data.is_a?(Hash) ? set_data : JsonParser.new.parse(s_from)
    if nz(options[:override],0) != 0
      _extra_data = set_data_h
    else
      _extra_data = get_extra_data
      _extra_data.merge! set_data_h
    end
    _extra_data.delete_if{|k,v|v.nil?}
    self.extra_data = _extra_data.blank? ? nil : _extra_data.to_json
  end

  def _name
    self.prop.name
  end

  alias :_prop_name :_name

  def _owner
    self.schedule.owner_uname
  end

  def _subscriber
    self.schedule.owner_gname
  end

  def _prop_stat
    self.prop_stat_s
  end

  def is_return_genre?
    if self.prop_type == "Gw::PropOther"
      return "other"
    end
  end

  def self.is_prop_edit?(prop_id, genre, options = {})
    if options.key?(:is_gw_admin)
      is_gw_admin = options[:is_gw_admin]
    else
      is_gw_admin = Gw.is_admin_admin?
    end

    flg = true

    if options[:prop].blank?
      prop = Gw::PropOther.find(prop_id)
    else
      prop = options[:prop]
    end

    unless prop.blank?
      if !is_gw_admin
        flg = Gw::PropOtherRole.is_edit?(prop_id) && (prop.reserved_state == 1 || prop.delete_state == 0)
      end
      if prop.reserved_state == 0 || prop.delete_state == 1
        flg = false
      end
    else
      flg = false
    end

    return flg
  end

  def self.getajax(params)
    begin
      st_at = Gw.to_time(params[:st_at]) rescue nil
      ed_at = Gw.to_time(params[:ed_at]) rescue nil

      admin = Gw.is_admin_admin?

      if st_at.blank? || ed_at.blank? || st_at >= ed_at
        item = {:errors=>'日付が異常です'}
      else
        @index_order = 'extra_flag, sort_no, gid, name'
        cond_props_within_terms = "SELECT distinct prop_id FROM gw_schedules"
        cond_props_within_terms.concat " left join gw_schedule_props on gw_schedules.id =  gw_schedule_props.schedule_id"
        cond_props_within_terms.concat " where"
        cond_props_within_terms.concat " gw_schedules.id <> #{params[:schedule_id].to_i} and " unless params[:schedule_id].blank?
        cond_props_within_terms.concat " gw_schedules.ed_at >= '#{Gw.datetime_str(st_at)}'"
        cond_props_within_terms.concat " and gw_schedules.st_at < '#{Gw.datetime_str(ed_at)}'"
        cond_props_within_terms.concat " order by prop_id"
        cond = "piwt.prop_id is null"
        cond.concat " and gw_prop_others.delete_state = 0 and gw_prop_others.reserved_state = 1"
        if nz(params[:type_id], 0).to_i != 0
          cond.concat " and type_id = #{params[:type_id].to_i}"
        end

        joins = "left join (#{cond_props_within_terms}) piwt on gw_prop_others.id = piwt.prop_id"

        item = Gw::PropOther.find(:all, :joins=>joins, :conditions=>cond, :order=>"type_id, gid, sort_no, name").select{|x|
          if admin
            true
          else
            Gw::PropOtherRole.is_edit?(x.id)
          end
          }.collect{|x| ["other", x.id, "(" + System::Group.find(x.gid).code.to_s + ")" + x.name.to_s, x.gname]}

        item = {:errors=>'該当する候補がありません'} if item.blank?
      end
      return item
    rescue
      return {:errors=>'不明なエラーが発生しました'}
    end
  end
end
