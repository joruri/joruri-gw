# -*- encoding: utf-8 -*-
class Questionnaire::Base < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Questionnaire::Model::Systemname

  validates_presence_of :state, :able_date, :expiry_date
  after_validation :validate_title

  before_save :set_section_name
  after_save :answer_record_expiry_date_field_update
  after_destroy :form_fields_destroy

  attr_accessor :_commission_state  #回覧人数制限値エラー時のボタン表示制御用

  def form_body_json
    form_str = self.form_body
    form_str = form_str.gsub(/\r\n?/, '\\n') unless form_str.blank?
    return form_str
  end

  def validate_title
    self.manage_title = self.title

    if self.title.blank?
      errors.add :title, "公開用タイトルを入力してください。"
      self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
    else
      str = self.title.to_s.gsub(/　/, '').strip
      if str.blank?
        errors.add :title, "スペースのみの登録はできません。"
        self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
      end
      unless str.blank?
        #文字数を確認
        s_chk = self.title.gsub(/\r\n|\r|\n/, '')
        self.title = s_chk
        if 140 <= s_chk.split(//).size
          errors.add :title, "公開用タイトルは140文字以内で記入してください。"
          self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
        end
      end
    end unless self.state == 'preparation'

    #期限日のチェック
    if self.able_date > self.expiry_date
      errors.add :expiry_date, "を確認してください。（期限日が作成日より前になっています。）"
      self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
    end unless self.able_date.blank? unless self.expiry_date.blank?

    if self.state == 'public'
      field_lists = []
      field_lists = JsonParser.new.parse(self.form_body_json) unless self.form_body.blank?
      if field_lists.size == 0
        errors.add :state, "設問が登録されていません。保存後,設問登録処理へ進んでください。"
        self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
      end
    end

  end

  #選択肢設定
  def states
    {'public' => '公開', 'draft' => '作成中' , 'closed' => '締め切り'}
  end

  #記名・無記名区分
  def enquete_division_states
    return [
      ['記名', true],
      ['無記名', false]
    ]
  end
  def enquete_division_state_name
    ret = ''
    ret = '記名' if self.enquete_division
    ret = '無記名' unless self.enquete_division
    return ret
  end

  def include_index_states
    return [
      ['一覧に表示する', true],
      ['一覧に表示しない', false]
    ]
  end
  def include_index_states_name
    ret = ''
    ret = '一覧に表示する' if self.include_index
    ret = '一覧に表示しない' unless self.include_index
    return ret
  end

  def remarks_state
    return [
      ['表示しない', "close"],
      ['上部に表示する', "upper"],
      ['下部に表示する', "footer"]
    ]
  end
  def remarks_states_name
    ret = ''
    if self.remarks_setting == "upper"
      ret = "上部に表示する"
    elsif self.remarks_setting == "footer"
      ret = "下部に表示する"
    elsif self.remarks_setting == "close"
      ret = "表示しない"
    end
    return ret
  end

  def no_include_index_answer_url
    ret = ''
    return ret if self.include_index

    rails_env = ENV['RAILS_ENV']
    ret = 'localhost'
    begin
      site = YAML.load_file('config/core.yml')
      ret = site[rails_env]['uri']
    rescue
    end
    ret = ret.chop if ret.ends_with?('/') unless ret.blank?
    ret = "#{ret}#{self.answer_new_path}?k=#{self.keycode}"
    return ret
  end

  def no_include_result_url
    ret = ''
    return ret if self.include_index

    rails_env = ENV['RAILS_ENV']
    ret = 'localhost'
    begin
      site = YAML.load_file('config/core.yml')
      ret = site[rails_env]['uri']
    rescue
    end
    ret = ret.chop if ret.ends_with?('/') unless ret.blank?
    ret = "#{ret}#{self.result_monitor_path}?k=#{self.keycode}"
    return ret
  end

   def admin_setting_name
    return [
      ['作成者が管理する', 0] ,
      ['所属で管理する', 1]
    ]
  end
  def admin_setting_status
    ret = ''
    ret = '作成者が管理する' if self.admin_setting == 0
    ret = '所属で管理する'   if self.admin_setting == 1
    return ret
  end
  def answer_count_name
    ret = ''
    ret = "一覧(0)" if self.answer_count.blank?
    ret = "一覧(#{self.answer_count})" unless self.answer_count.blank?
    return ret
  end
  def display_expiry_date
    ret = ''
    unless self.expiry_date.blank?
      ret = self.expiry_date.strftime('%Y-%m-%d %H:%M').to_s
      red_set = false
      red_set = true if self.expiry_date < Time.now
      red_set = true if self.state == 'closed'
      ret = %Q[<span style="color:red">#{ret}</span>] if red_set
    end
    return ret
  end

  def state_name
    return self.states[self.state]
  end

  def show_path
    return "/#{self.system_name}/#{self.id}"
  end
  def update_path
    return "/#{self.system_name}/#{self.id}"
  end
  def delete_path
    return "/#{self.system_name}/#{self.id}"
  end
  def edit_path
    return "/#{self.system_name}/#{self.id}/edit"
  end
  def open_enq_path
    return "/#{self.system_name}/#{self.id}/open_enq"
  end
  def template_select_path
    return "/#{self.system_name}/#{self.id}/templates"
  end
  def form_field_path
    return "/#{self.system_name}/#{self.id}/form_fields"
  end
  def form_field_new_path
    return "/#{self.system_name}/#{self.id}/form_fields/new"
  end
  def preview_path
    return "/#{self.system_name}/#{self.id}/previews"
  end
  def preview_new_path
    return "/#{self.system_name}/#{self.id}/previews/new"
  end
  def result_path
    return "/#{self.system_name}/#{self.id}/answers"
  end
  def csv_export_path
    return "/#{self.system_name}/#{self.id}/csv_exports"
  end
  def csv_export_file_path
    return "/#{self.system_name}/#{self.id}/csv_exports/export_csv"
  end
  #
  def answer_path
    return "/enquete/#{self.id}/answers"
  end
  def answer_new_path
    return "/enquete/#{self.id}/answers/new"
  end
  def answer_to_details_path
    return "/#{self.system_name}/#{self.id}/results/answer_to_details"
  end
  def closed_path
    return "/#{self.system_name}/#{self.id}/closed"
  end
  def reopen_path
    return "/#{self.system_name}/#{self.id}/open_enq"
  end
  def result_monitor_path
    return "/#{self.system_name}/#{self.id}/results"
  end

  def new_template_base_path(template_admin="admin")
    if template_admin=="admin"
      admin_setting = "1"
    else
      admin_setting = "0"
    end
    return  "/#{self.system_name}/#{self.id}/templates/new_base?admin=#{admin_setting}"
  end
  #
  def form_fields_destroy
    Questionnaire::FormField.destroy_all("parent_id=#{self.id}")
    Questionnaire::Preview.destroy_all("parent_id=#{self.id}")
    Enquete::Answer.destroy_all("title_id=#{self.id}")
    Questionnaire::Result.destroy_all("title_id=#{self.id}")
    Questionnaire::Temporary.destroy_all("title_id=#{self.id}")
  end

  def answer_record_expiry_date_field_update
    condition = "title_id=#{self.id}"
    Enquete::Answer.update_all("expiry_date='#{self.expiry_date.strftime('%Y-%m-%d %H:%M')}'", condition)

  end


  #保存前に所属情報を更新する
  def set_section_name
    self.section_name = ''
    self.section_sort = 0

    group = Gwboard::Group.new
    group.and :code ,self.section_code
    group = group.find(:first)
    if group
      self.section_name = "#{group.code}#{group.name}"
      self.section_sort = group.sort_no
    end
  end

  def save_groups_json
    return unless self.state == 'public'
      save_custom_groups_json
      save_reader_groups_json
  end
  #所属------------------------------------------------------------------------
  #所属カスタム配信先設定からの送信先作成
  def save_custom_groups_json
    unless self.custom_groups_json.blank?
      objects = JsonParser.new.parse(self.custom_groups_json)
      objects.each do |object|
        self.create_records(object[1])
      end
    end
  end
  #所属配信先設定からの送信先作成
  def save_reader_groups_json
    unless self.reader_groups_json.blank?
      objects = JsonParser.new.parse(self.reader_groups_json)
      objects.each do |object|
        self.create_records(object[1])
      end
    end
  end

  #既存のレコードで、draftのものを全てpreparationにする
  #配信先が減った時の判別に利用する
  def all_records_status_update
    condition = "title_id=#{self.id} AND state='draft'"
    Enquete::Answer.update_all("state='preparation'", condition)
  end
  #配信用明細作成
  def create_records(group_id)
    group = Gwboard::Group.find_by_id(group_id)
    self.create_group_record(group) unless group.blank?
  end
  #
  def create_group_record(group)

    l2_group_code = ''
    l2_group_code = group.parent.code unless group.parent.blank?

    item = Enquete::Answer.new
    item.and :title_id,  self.id
    item.and :section_code, group.code
    doc = item.find(:first)
    if doc.blank?
      #追加
      Enquete::Answer.create({
        :state => 'draft',
        :title_id => self.id,
        :l2_section_code => l2_group_code,
        :section_code => group.code,
        :section_name => group.name,
        :section_sort => group.sort_no,
        :createdate => self.createdate ,
        :creater_id => self.creater_id ,
        :creater => self.creater ,
        :createrdivision => self.createrdivision ,
        :createrdivision_id => self.createrdivision_id
      })
    else
      #更新
      doc.state = 'draft' unless doc.state == 'public'
      doc.l2_section_code = l2_group_code
      doc.section_code = group.code
      doc.section_name = group.name
      doc.section_sort = group.sort_no
      doc.createdate = self.createdate
      doc.creater_id = self.creater_id
      doc.creater = self.creater
      doc.createrdivision = self.createrdivision
      doc.createrdivision_id = self.createrdivision_id
      doc.save
    end
  end

end
