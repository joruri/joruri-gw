class Gw::Admin::PlusUpdateSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout 'admin/template/admin'

  def pre_dispatch
    @system_title = "JoruriPlus+　リマインダー表示設定"
    Page.title = @system_title

    @css = %w(/_common/themes/gw/css/gw.css)
  end

  def index
    @item = Gw::Property::PlusUpdate.where(uid: Core.user.id).first_or_new
  end

  def create
    @item = Gw::Property::PlusUpdate.where(uid: Core.user.id).first_or_new
    @item.options_value = plus_update_setting_params.values
    @item.save
    redirect_to "/gw/plus_update_settings"
  end

  def to_project
    @item = Gw::PlusUpdate.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    project_code = @item.project_code
    sns_url = redirect_to_joruri_gw_link_sso_index_path(to: 'plus', path: "/_admin/sns/projects/#{project_code}/reports")
    doc_updated_at = 5.days.ago.strftime('%Y-%m-%d 00:00:00')
    cond = ["project_users_json LIKE ? and state= ?  and project_code = ? and doc_updated_at >= ?",%Q(%"#{Core.user.code}"%), "enabled", project_code, doc_updated_at]
    project_items = Gw::PlusUpdate.where(cond).order('doc_updated_at ASC')
    project_items.each do |p_item|
      is_removed = false
      users = p_item.project_users_json
      if users =~ /\"#{Core.user.code}\",/
        users = users.gsub(/\"#{Core.user.code}\",/, "")
        is_removed = true
      end
      if is_removed
        p_item.project_users_json = users
        p_item.save(:validate=>false)
      end
    end unless project_items.blank?
    return redirect_to sns_url
  end

private
  def plus_update_setting_params
    params.require(:item).permit!
  end

end
