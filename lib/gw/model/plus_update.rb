# encoding: utf-8
module Gw::Model::Plus_update
  def self.remind(uid = nil)

    # リマインダー表示
    model = Gw::PlusUpdate.new
#    uid = Site.user.id
    @item = Gw::UserProperty.find(:first, :conditions=>["class_id = ? and uid = ? and name = ? ",1, Site.user.id,"plus_update"])
    if @item.blank?
      @array_config = [['4.days']]
    else
      @array_config = Array.new(10, ['', ''])
      @array_config = JsonParser.new.parse(@item.options) unless @item.blank?
    end
    limit_date(@array_config[0][0])
    cond = ["project_users_json LIKE ? and state= ? and doc_updated_at >= ?",%Q(%"#{Site.user.code}"%), "enabled", @date]
    items = model.find(:all, :order => 'doc_updated_at ASC',
      :conditions => cond)

    ret = []
    code = {}

    items.each do |item|
      if code.blank?
        code[item.project_code.to_sym] = [1, item.project_code, item.title, item.doc_updated_at,item.id]
      else
        if code[item.project_code.to_sym]
          project_params = code[item.project_code.to_sym]
          code[item.project_code.to_sym] = [project_params[0] + 1, item.project_code, item.title, item.doc_updated_at,item.id ]
        else
          code[item.project_code.to_sym] = [1, item.project_code, item.title, item.doc_updated_at,item.id]
        end
      end
    end
    code.each do |key, value|
      ret << {
        :date_str => value[3].blank? ? "" : value[3].strftime("%m/%d %H:%M"),
        :cls => 'JoruriPlus+',
        :title => %Q(<a href="/gw/plus_update_settings/#{value[4]}/to_project" target="_blank">#{value[2]}に#{value[0]}件の更新があります。</a>),
        :date_d => value[3]
      }
    end
    return ret
  end

  def self.limit_date(limit_str)
    case limit_str
    when 'today'
      @msg = '本日'
      @date = Date.today.strftime('%Y-%m-%d 00:00:00')
    when 'yesterday'
      @msg = '前日から'
      @date = Date.yesterday.strftime('%Y-%m-%d 00:00:00')
    when '3.days'
      @msg = '3日前から'
      @date = 3.days.ago.strftime('%Y-%m-%d 00:00:00')
    when '4.days'
      @msg = '4日前から'
      @date = 4.days.ago.strftime('%Y-%m-%d 00:00:00')
    else
      @msg = '本日'
      @date = Date.yesterday.strftime('%Y-%m-%d 00:00:00')
    end
  end

end
