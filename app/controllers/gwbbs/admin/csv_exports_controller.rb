# -*- encoding: utf-8 -*-
class Gwbbs::Admin::CsvExportsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken
  layout "admin/template/portal_1column"
  
  def initialize_scaffold
    @css = ["/_common/themes/gw/css/bbs.css"]
    @title = Gwbbs::Control.find_by_id(params[:id])
    return http_error(404) unless @title

    Page.title = @title.title
  end

  def index
    admin_flags(@title.id)
    return http_error(403) unless @is_admin
    params[:nkf] = 'sjis'
  end

  def export_csv
    admin_flags(@title.id)
    return http_error(403) unless @is_admin

    filename = "掲示板-#{@title.title}-#{Time.now.strftime('%Y%m%d-%H%M')}"
    nkf_options = case params[:item][:nkf]
        when 'utf8'
          '-w'
        else
          '-s'
        end
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :title_id , @title.id
    item.and :state , 'public'
    item.order :id
    items = item.find(:all,:select=>"id, section_code, section_name, category1_id, title")
    Gwbbs::Doc.remove_connection

    category_hash

    put1 = []
    items.each do |b|
      put1 << make_csv(b)
    end

    csv_header =  []
    csv_header << "レコードid"
    csv_header << "所属コード"
    csv_header << "所属名"
    csv_header << "分類コード"
    csv_header << "分類名"
    csv_header << "件名"

    put2 = [csv_header]
    put1.each do |p|
      put2 << p
    end

    options={:force_quotes => true ,:header=>nil }
    csv_string = Gw::Script::Tool.ary_to_csv(put2, options)
    send_data NKF::nkf(nkf_options,csv_string), :filename => "#{filename}.csv"
  end

  def make_csv(b)
    data = []
    data << b.id.to_s
    data << b.section_code.to_s
    data << b.section_name.to_s
    data << b.category1_id.to_s
    strcat = ''
    strcat = @categories[b.category1_id].name unless @categories.blank?
    data << strcat
    data << b.title.to_s
    return data
  end

  def category_hash
    item = gwbbs_db_alias(Gwbbs::Category)
    item = item.new
    item.and :level_no, 1
    item.and :title_id, @title.id
    @categories = item.find(:all,:select=>'id, name', :order =>'sort_no, id').index_by(&:id)
    Gwbbs::Category.remove_connection
  end

private
  def invalidtoken
    return http_error(404)
  end
end
