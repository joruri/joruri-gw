# -*- encoding: utf-8 -*-
################################################################################
#
################################################################################

class Questionnaire::Admin::Menus::CsvExportsController < Gw::Controller::Admin::Base

  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/portal_1column"

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    @system_title = 'アンケート集計システム　CSV出力'
    Page.title = @system_title
    @system_path = "/#{self.system_name}"

    @title = Questionnaire::Base.find_by_id(params[:parent_id])
    return http_error(404) unless @title
    return http_error(404) if @title.form_body.blank?
    @field_lists = JsonParser.new.parse(@title.form_body_json)
    return http_error(404) if @field_lists.size == 0
  end

  def is_creator
    system_admin_flags
    params[:cond] = '' if @title.creater_id == Site.user.code if @is_sysadm
    params[:cond] = 'admin' unless @title.creater_id == Site.user.code if @is_sysadm

    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Site.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Site.user_group.code  if @title.admin_setting == 1
    return ret
  end


  #-主なアクションの記述 START index,show,new,edit,update, destroy---------------
  def index
    return authentication_error(403) unless is_creator

    params[:nkf] = 'sjis'
  end

  def export_csv
    return authentication_error(403) unless is_creator

    filename = "enquete#{Time.now.strftime('%Y%m%d%H%M%S')}"
    nkf_options = case params[:item][:nkf]
        when 'utf8'
          '-w'
        else
          '-s'
        end
    item = Enquete::Answer.new
    item.and :title_id , @title.id
    item.and :state, 'public'
    item.order 'section_sort, l2_section_code, section_code'
    items = item.find(:all)
    put1 = []
    items.each do |b|
      put1 << make_csv(b)
    end

    csv_header =  make_csv_header

    put2 = [csv_header]
    put1.each do |p|
      put2 << p
    end

    options={:force_quotes => true ,:header=>nil }
    csv_string = Gw::Script::Tool.ary_to_csv(put2, options)
    #send_download "#{filename}.csv", NKF::nkf(nkf_options,csv_string)
    send_data(NKF::nkf(nkf_options,csv_string), :filename => "#{filename}.csv", :type => "text/csv", :charset=>params[:item][:nkf])
  end

  def make_csv_header
    return authentication_error(403) unless is_creator

    csv_header =  []
    csv_header << "アンケートid"
    csv_header << "アンケート名"
    if @title.enquete_division
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
    if @title.enquete_division
      #記名形式
      # 所属コード
      data << b.section_code.to_s
      # 所属名
      data << b.section_name.to_s
      # 回答者コード
      data << b.user_code.to_s
      # 回答者コード
      data << b.user_name.to_s
    end
    # 返信日時
    data << b.editdate.to_s

    @item = b
    for item in @field_lists
      data_string = ''
      data_string = @item[item['field_name']] if item['question_type'] == 'text'
      data_string = @item[item['field_name']] if item['question_type'] == 'textarea'
      data_string = @item[item['field_name']] if item['question_type'] == 'group'

      if item['question_type'] == 'radio'
        options = option_list_array(item['field_id'])
        check_values = []
        check_values = JsonParser.new.parse(@item[item['field_name']]) unless @item[item['field_name']].size == 0 unless @item[item['field_name']].blank?
        for option in options
          checked = false
          checked = true if check_values.index(option['value'])
          data_string = option['title'] if checked
        end
      end

      if item['question_type'] == 'checkbox'
        options = option_list_array(item['field_id'])
        check_values = []
        check_values = JsonParser.new.parse(@item[item['field_name']]) unless @item[item['field_name']].size == 0 unless @item[item['field_name']].blank?
        comma_string = ''
        for option in options
          checked = false
          comma_string = ' ; ' unless data_string.blank?
          data_string = "#{data_string}#{comma_string}#{option['title']}"  if check_values.index(option['value'])
        end
      end

      if item['question_type'] == 'select'
        options = option_list_array(item['field_id'])
        options.each { |opt|
         data_string = opt[0] if opt[1].to_s == @item[item['field_name']].to_s
        }
      end
      if item['question_type'] == 'group'
        data << group_field_value(item, data_string)
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

    item = Questionnaire::FormField.find_by_id(field['field_id'])
    return ret if item.blank?
    return ret if item.group_body.blank?

    groups = []
    groups = JsonParser.new.parse(item.group_body_json)

    group_values = ''
    group_values = JsonParser.new.parse(data_string)
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
    item = Questionnaire::FormField.find_by_id(id)
    return [] if item.blank?
    return JsonParser.new.parse(item.option_body_json)
  end

  private
  def invalidtoken
    return http_error(404)
  end
end
