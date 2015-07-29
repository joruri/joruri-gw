# encoding: utf-8
class Gw::Admin::PlusUpdateSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout 'admin/template/admin'
  # 個人設定のうち、JoruriPlusからの更新表示に関する設定

  def initialize_scaffold
    init_params
  end

  def index
    @item = Gw::UserProperty.find(:first, :conditions=>["class_id = ? and uid = ? and name = ? ",1, Site.user.id,"plus_update"])
    if @item.blank?
      @array_config = ['4.days']
    else
      @array_config = Array.new(10, ['', ''])
      @array_config = JsonParser.new.parse(@item.options) unless @item.blank?
    end
  end

  def create
    @item = Gw::UserProperty.find(:first, :conditions=>["class_id = ? and uid = ? and name = ? ",1, Site.user.id,"plus_update"])
    if @item.blank?
      @item = Gw::UserProperty.create({:class_id=>1, :uid=>Site.user.id, :name=>"plus_update"})
    end
    config_0 = "[" + '"' + params[:config_0].to_s + '"' + "]"
    @item.options = "[" + "#{config_0}" + "]"
    @item.save
    return redirect_to "/gw/plus_update_settings"
  end

  def init_params

    search_condition
    setting_sortkeys
    @system_title = "JoruriPlus+　リマインダー表示設定"
    Page.title = @system_title

    @css = %w(/_common/themes/gw/css/gw.css)
    @limit_select = [['当日分のみ', 'today'],
      ['前日分から' , 'yesterday'],
      ['3日以内' , '3.days'],
      ['4日以内' , '4.days']]
  end
  def search_condition
    qsa = ['c1' , 'c2']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'id')
  end

  def to_project
    @item = Gw::PlusUpdate.find_by_id(params[:id])
    project_code = @item.project_code
    sns_url = "/_admin/gw/link_sso/redirect_to_plus?path=/_admin/sns/projects/#{project_code}/reports"
    doc_updated_at = 5.days.ago.strftime('%Y-%m-%d 00:00:00')
    cond = ["project_users_json LIKE ? and state= ?  and project_code = ? and doc_updated_at >= ?",%Q(%"#{Site.user.code}"%), "enabled", project_code, doc_updated_at]
    project_items = Gw::PlusUpdate.find(:all, :order => 'doc_updated_at ASC',
      :conditions => cond)
    project_items.each do |p_item|
      is_removed = false
      users = p_item.project_users_json
      if users =~ /\"#{Site.user.code}\",/
        users = users.gsub(/\"#{Site.user.code}\",/, "")
        is_removed = true
      end
      if is_removed
        p_item.project_users_json = users
        p_item.save(:validate=>false)
      end
    end unless project_items.blank?
    return redirect_to sns_url
  end


end
