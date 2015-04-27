class Gwboard::Admin::SiteinfoController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    Page.title = "接続情報確認"
    @css = ["/_common/themes/gw/css/bbs.css"]
  end

  def index
    rails_env = ENV['RAILS_ENV']
    begin
      site = YAML.load_file('config/site.yml')
      @host = site[rails_env]['host']
    rescue
    end
  end
end