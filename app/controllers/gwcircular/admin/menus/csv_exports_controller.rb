# -*- encoding: utf-8 -*-
class Gwcircular::Admin::Menus::CsvExportsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    @parent = Gwcircular::Doc.find_by_id(params[:id])
    return http_error(404) unless @parent
    return http_error(404) unless @parent.doc_type == 0
  end
  
  def index
    get_role_index

    @is_readable = false unless @parent.target_user_code == Site.user.code unless @is_admin
    return authentication_error(403) unless @is_readable
    Page.title = @title.title
    params[:nkf] = 'sjis'
  end

  def export_csv
    filename = "gwcircular#{Time.now.strftime('%Y%m%d%H%M%S')}"
    nkf_options = case params[:item][:nkf]
        when 'utf8'
          '-w'
        else
          '-s'
        end
    item = Gwcircular::Doc.new
    item.and :title_id , @title.id
    item.and :doc_type , 1
    item.and :parent_id , @parent.id
    item.and 'sql', "state != 'preparation'"
    items = item.find(:all,:select=>"parent_id, title, id, state, target_user_code, target_user_name, body, editdate, doc_type")

    put1 = []
    items.each do |b|
      put1 << make_csv(b)
    end

    csv_header =  []
    csv_header << "回覧id"
    csv_header << "タイトル"
    csv_header << "返信id"
    csv_header << "状態"
    csv_header << "返信者コード"
    csv_header << "返信者名"
    csv_header << "返信欄"
    csv_header << "返信日時"

    put2 = [csv_header]
    put1.each do |p|
      put2 << p
    end

    options={:force_quotes => true ,:header=>nil }
    csv_string = Gw::Script::Tool.ary_to_csv(put2, options)
    send_data(NKF::nkf(nkf_options,csv_string), :type => 'text/csv', :filename => "#{filename}.csv")
  end

  def make_csv(b)
    data = []
    data << b.parent_id.to_s
    data << b.title.to_s
    data << b.id.to_s
    data << b.status_name_csv.to_s
    data << b.target_user_code.to_s
    data << b.target_user_name.to_s
    data << b.body.to_s
    data << b.editdate.to_s
    return data
  end


  private
  def invalidtoken
    return http_error(404)
  end
end
