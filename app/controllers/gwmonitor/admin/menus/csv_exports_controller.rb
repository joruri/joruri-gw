class Gwmonitor::Admin::Menus::CsvExportsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システム"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]

    @title = Gwmonitor::Control.find(params[:title_id])
    return error_auth unless @title.is_admin?
  end

  def index
    @item = System::Model::FileConf.new(encoding: 'sjis')
  end

  def export_csv
    @item = System::Model::FileConf.new(encoding: 'sjis')
    @item.attributes = params[:item]

    main_title = ["",""]
    enable  =["","","","","","","","","",""]
    label = ["","","","","","","","","",""]

    if @title.form_name == "form002" && @title.form_configs.present?
      configs = JSON.parse(@title.form_configs)
      main_title = configs[0]
      enable = configs[1]
      label = configs[2]
    end

    headers =  ["アンケートid", "アンケート名", "状態", "所属コード", "所属名", "回答者名"]
    if @title.form_name == "form002"
      headers << "項目名"
      10.times do |i|
        if enable[i] == "enabled"
          headers << "#{label[i]}"
          headers << "#{label[i]}（#{main_title[1]}）"
        end
      end
    else
      headers << "返信欄"
    end
    headers << "回答日時"

    csv = @title.docs.where.not(state: 'preparation').order(:section_sort, :l2_section_code, :section_code)
      .select(:title_id, :id, :state, :section_code, :section_name, :editor_id, :editor, :body, :editdate)
      .to_csv(headers: headers) {|item| make_csv(item, main_title, enable) }

    send_data @item.encode(csv), type: 'text/csv', filename: "gwmonitor#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
  end

  def make_csv(b, main_title, enable)
    answers   = ["","","","","","","","","",""]
    remarks   = ["","","","","","","","","",""]

    data = [b.title_id, @title.title, b.status_name_csv, b.section_code, b.section_name, b.editor]
    if @title.form_name == "form002"
      data << main_title[0]
      if b.body.present?
        answer_sets = JSON.parse(b.body)
        answers = answer_sets[0]
        remarks = answer_sets[1]
      end
      10.times do |i|
        if enable[i] == "enabled"
          data << answers[i]
          data << remarks[i]
        end
      end
    else
      data << b.body
    end
    data << b.editdate
    data
  end
end
