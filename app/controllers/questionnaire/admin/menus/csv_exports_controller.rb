class Questionnaire::Admin::Menus::CsvExportsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    Page.title = 'アンケート集計システム　CSV出力'
    @system_path = "/#{self.system_name}"

    @title = Questionnaire::Base.where(:id => params[:parent_id]).first
    return http_error(404) unless @title
    return http_error(404) if @title.form_body.blank?
    @field_lists = JSON.parse(@title.form_body)
    return http_error(404) if @field_lists.size == 0
  end

  def is_creator
    system_admin_flags
    params[:cond] = '' if @title.creater_id == Core.user.code if @is_sysadm
    params[:cond] = 'admin' unless @title.creater_id == Core.user.code if @is_sysadm

    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Core.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Core.user_group.code  if @title.admin_setting == 1
    return ret
  end

  def index
    return error_auth unless is_creator

    @item = System::Model::FileConf.new(encoding: 'sjis')
  end

  def export_csv
    return error_auth unless is_creator

    @item = System::Model::FileConf.new(encoding: 'sjis')
    @item.attributes = params[:item]

    csv = @title.answers.where(state: 'public').order(:section_sort, :l2_section_code, :section_code)
      .to_csv(headers: make_csv_header) {|item| make_csv(item) }

    send_data @item.encode(csv), type: "text/csv", filename: "enquete#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
  end

  def make_csv_header
    csv_header =  []
    csv_header << "アンケートid"
    csv_header << "アンケート名"
    if @title.enquete_division || @admin
      #記名形式
      csv_header << "所属コード"
      csv_header << "所属名"
      csv_header << "回答者コード"
      csv_header << "回答者名"
    end
    csv_header << "回答日時"
    for item in @field_lists
      csv_header << item['title'].to_s
    end

    return csv_header
  end

  def make_csv(b)
    data = []
    # parent_id
    data << b.title_id.to_s
    # title
    data << @title.title.to_s
    if @title.enquete_division || @admin
      #記名形式
      # 所属コード
      data << b.section_code.to_s
      # 所属名
      data << b.section_name.to_s
      if nz(@title.send_to, 0).to_i == 0 || (nz(@title.send_to, 0).to_i == 1 && !@title.enquete_division)  # 個人向け
        # 回答者コード
        data << b.user_code.to_s
        # 回答者コード
        data << b.user_name.to_s
      else # 所属向け
        # 回答者コード
        data << b.editor_id.to_s
        # 回答者コード
        data << b.editor.to_s
      end
    end
    # 返信日時
    data << b.editdate.to_s

    item = b
    for list in @field_lists
      data_string = ''
      data_string = item[list['field_name']] if list['question_type'] == 'text'
      data_string = item[list['field_name']] if list['question_type'] == 'textarea'
      data_string = item[list['field_name']] if list['question_type'] == 'group'

      if list['question_type'] == 'radio'
        options = option_list_array(list['field_id'])
        check_values = []
        check_values = JSON.parse(item[list['field_name']]) unless item[list['field_name']].size == 0 unless item[list['field_name']].blank?
        for option in options
          checked = false
          checked = true if check_values.index(option['value'])
          data_string = option['title'] if checked
        end
      end

      if list['question_type'] == 'checkbox'
        options = option_list_array(list['field_id'])
        check_values = []
        check_values = JSON.parse(item[list['field_name']]) unless item[list['field_name']].size == 0 unless item[list['field_name']].blank?
        comma_string = ''
        for option in options
          checked = false
          comma_string = ' ; ' unless data_string.blank?
          data_string = "#{data_string}#{comma_string}#{option['title']}"  if check_values.index(option['value'])
        end
      end

      if list['question_type'] == 'select'
        options = option_list_array(list['field_id'])
        options.each { |opt|
         data_string = opt[0] if opt[1].to_s == item[list['field_name']].to_s
        }
      end
      if list['question_type'] == 'group'
        data << group_field_value(list, data_string)
      else
        data << data_string
      end
    end
    return data
  end

  def group_field_value(field, data_string)
    ret = ''
    return ret if data_string.blank?
    return ret if field['field_id'].blank?

    item = Questionnaire::FormField.where(:id => field['field_id']).first
    return ret if item.blank?
    return ret if item.group_body.blank?

    groups = []
    groups = JSON.parse(item.group_body)

    group_values = ''
    group_values = JSON.parse(data_string)
    group_repeat = 0
    group_repeat = field['group_repeat'] unless field['group_repeat'].blank?
    for i in 1 .. group_repeat
      col = 0
      loop_text = ''
      is_all_blank = true
      max_count = groups.size
      for group in groups
        group_field_name = "#{field['field_name']}_#{group['field_name']}"
        value_array = []
        value_array = group_values[group_field_name] unless group_values[group_field_name].blank? unless group_values.blank?
        value = ''
        value = value_array[i-1]
        is_all_blank = false unless value.blank?
        col += 1
        if col < max_count
          loop_text = "#{loop_text}#{value} | "
        else
          loop_text = "#{loop_text}#{value}\n"
        end
      end
      ret = "#{ret}#{loop_text}" unless is_all_blank
    end if 0 < group_repeat
    return ret
  end

  def option_list_array(id)
    item = Questionnaire::FormField.where(:id =>id).first
    return [] if item.blank?
    return JSON.parse(item.option_body)
  end
end
