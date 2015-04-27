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

    @categories = @title.categories.select(:id, :name).order(:sort_no, :id).index_by(&:id)

    csv = @title.docs.where(state: 'public').select(:id, :section_code, :section_name, :category1_id, :title).order(:id)
      .to_csv(headers: ["レコードid","所属コード","所属名","分類コード","分類名","件名"]) do |item|
      [
        item.id,
        item.section_code,
        item.section_name,
        item.category1_id,
        @categories[item.category1_id].try(:name),
        item.title
      ]
    end

    send_data @item.encode(csv), filename: "掲示板-#{@title.title}-#{Time.now.strftime('%Y%m%d-%H%M')}.csv"
  end
end
