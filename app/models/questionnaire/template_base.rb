# -*- encoding: utf-8 -*-
class Questionnaire::TemplateBase < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Questionnaire::Model::TemplateSystemname

  validates_presence_of :state
  after_validation :validate_title

  before_save :set_section_name
  after_destroy :form_fields_destroy

  attr_accessor :_commission_state  #回覧人数制限値エラー時のボタン表示制御用

  def form_body_json
    form_str = self.form_body
    form_str = form_str.gsub(/\r\n?/, '\\n') unless form_str.blank?
    return form_str
  end

  def validate_title
    self.manage_title = self.title

    if self.manage_title.blank?
      errors.add :manage_title, "管理用名称を入力してください。"
      self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
    else
      str = self.manage_title.to_s.gsub(/　/, '').strip
      if str.blank?
        errors.add :manage_title, "スペースのみの登録はできません。"
        self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
      end
      unless str.blank?
        #文字数を確認
        s_chk = self.manage_title.gsub(/\r\n|\r|\n/, '')
        self.manage_title = s_chk
        if 140 <= s_chk.split(//).size
          errors.add :manage_title, "管理用名称は140文字以内で記入してください。"
          self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
        end
      end
    end unless self.state == 'preparation'

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
    {'public' => '公開', 'draft' => '作成中' , 'closed' => '非公開'}
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

  def admin_setting_name
    return [
      ['所属テンプレート', 0] ,
      ['共有テンプレート', 1]
    ]
  end
  def admin_setting_status
    ret = ''
    ret = '所属テンプレート' if self.admin_setting == 0
    ret = '共有テンプレート'   if self.admin_setting == 1
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

  def apply_template_path(parent_id)
    return "/questionnaire/#{parent_id}/templates/#{self.id}/apply_template"
  end

  #
  def form_fields_destroy
    Questionnaire::TemplateFormField.destroy_all("parent_id=#{self.id}")
    Questionnaire::TemplatePreview.destroy_all("parent_id=#{self.id}")
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

end
