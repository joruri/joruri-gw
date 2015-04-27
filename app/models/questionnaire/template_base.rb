class Questionnaire::TemplateBase < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Questionnaire::Model::TemplateSystemname

  has_many :form_fields, :foreign_key => :parent_id, :class_name => 'Questionnaire::TemplateFormField', :dependent => :destroy
  has_many :previews, :foreign_key => :parent_id, :class_name => 'Questionnaire::TemplatePreview', :dependent => :destroy

  after_validation :validate_title
  before_save :set_section_name

  attr_accessor :_commission_state  #回覧人数制限値エラー時のボタン表示制御用

  validates_presence_of :state

  def form_body_json
    form_str = self.form_body
    form_str = form_str.gsub(/\r\n?/, '\\n') unless form_str.blank?
    return form_str
  end

  #選択肢設定
  def states
    {'public' => '公開', 'draft' => '作成中' , 'closed' => '非公開'}
  end

  def state_name
    states[state]
  end

  #記名・無記名区分
  def enquete_division_states
    [
      ['記名', true],
      ['無記名', false]
    ]
  end

  def enquete_division_state_name
    enquete_division_states.rassoc(enquete_division).try(:first).to_s
  end

  def admin_setting_name
    [
      ['所属テンプレート', 0] ,
      ['共有テンプレート', 1]
    ]
  end

  def admin_setting_status
    admin_setting_name.rassoc(admin_setting).try(:first).to_s
  end

private

  def validate_title
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
      field_lists = JSON.parse(self.form_body) unless self.form_body.blank?
      if field_lists.size == 0
        errors.add :state, "設問が登録されていません。保存後,設問登録処理へ進んでください。"
        self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
      end
    end
  end

  def set_section_name
    if group = System::Group.where(:code => self.section_code).first
      self.section_name = "#{group.code}#{group.name}"
      self.section_sort = group.sort_no
    else
      self.section_name = ''
      self.section_sort = 0
    end
  end
end
