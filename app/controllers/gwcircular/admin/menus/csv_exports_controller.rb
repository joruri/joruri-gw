class Gwcircular::Admin::Menus::CsvExportsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    params[:title_id] = 1

    @title = Gwcircular::Control.find(params[:title_id])
    @parent = @title.docs.find(params[:id])
    return http_error(404) unless @parent.doc_type == 0
    return error_auth if !@title.is_admin? && !@parent.is_editable?

    Page.title = @title.title
  end

  def index
    @item = System::Model::FileConf.new(encoding: 'sjis')
  end

  def export_csv
    @item = System::Model::FileConf.new(encoding: 'sjis')
    @item.attributes = params[:item]

    csv = @title.docs.without_preparation.where(doc_type: 1, parent_id: @parent.id)
      .select(:parent_id, :title, :id, :state, :target_user_code, :target_user_name, :body, :editdate, :doc_type)
      .to_csv(headers: ["回覧id","タイトル","返信id","状態","返信者コード","返信者名","返信欄","返信日時"]) do |item|
      [
        item.parent_id,
        item.title,
        item.id,
        item.state_label,
        item.target_user_code,
        item.target_user_name,
        item.body,
        item.editdate
      ]
    end

    send_data @item.encode(csv), type: 'text/csv', filename: "gwcircular#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
  end
end
