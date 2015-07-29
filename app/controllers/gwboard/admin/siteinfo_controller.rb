# encoding: utf-8
class Gwboard::Admin::SiteinfoController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  layout "admin/template/portal_1column"

  def initialize_scaffold
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