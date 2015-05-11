class Gwbbs::Admin::CsvExportsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/bbs.css"]

    @title = Gwbbs::Control.find(params[:id])
    return error_auth unless @title.is_admin?

    Page.title = @title.title
  end

  def index
    @item = System::Model::FileConf.new(encoding: 'sjis')
  end

  def export_csv
    @item = System::Model::FileConf.new(encoding: 'sjis')
    @item.attributes = params[:item]

    items = @title.docs.select(:id, :section_code, :section_name, :category1_id, :title)
      .where(state: 'public').order(id: :asc).preload(:category)

    csv = items.to_csv(headers: ["レコードid","所属コード","所属名","分類コード","分類名","件名"]) do |item|
      [
        item.id,
        item.section_code,
        item.section_name,
        item.category1_id,
        item.category.try(:name),
        item.title
      ]
    end

    send_data @item.encode(csv), filename: "掲示板-#{@title.title}-#{Time.now.strftime('%Y%m%d-%H%M')}.csv"
  end
end
