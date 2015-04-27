class Questionnaire::Base < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Questionnaire::Model::Systemname

  has_many :form_fields, :foreign_key => :parent_id, :dependent => :destroy
  has_many :previews, :foreign_key => :parent_id, :dependent => :destroy
  has_many :results, :foreign_key => :title_id, :dependent => :destroy
  has_many :temporaries, :foreign_key => :title_id, :dependent => :destroy
  has_many :answers, :foreign_key => :title_id, :class_name => 'Enquete::Answer', :dependent => :destroy

  after_validation :validate_title
  before_save :set_section_name
  after_save :update_answer_record_expiry_date_field

  validates_presence_of :state, :able_date, :expiry_date

  attr_accessor :_commission_state  #回覧人数制限値エラー時のボタン表示制御用

  def view_title
    self.title
  end
  
  def form_body_json
    form_str = self.form_body
    form_str = form_str.gsub(/\r\n?/, '\\n') unless form_str.blank?
    return form_str
  end

  #選択肢設定
  def states
    {'public' => '公開', 'draft' => '作成中' , 'closed' => '締め切り'}
  end

  def state_name
    return self.states[self.state]
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

  def include_index_states
    [
      ['一覧に表示する', true],
      ['一覧に表示しない', false]
    ]
  end

  def include_index_states_name
    include_index_states.rassoc(include_index).try(:first).to_s
  end

  def remarks_state
    [
      ['表示しない', "close"],
      ['上部に表示する', "upper"],
      ['下部に表示する', "footer"]
    ]
  end

  def remarks_states_name
    remarks_state.rassoc(remarks_setting).try(:first).to_s
  end

  def admin_setting_name
    [
      ['所属で管理する', 1],
      ['作成者が管理する', 0]
    ]
  end

  def admin_setting_status
    admin_setting_name.rassoc(admin_setting).try(:first).to_s
  end

   def send_to_name
    [
      ['個人向け', 0] ,
      ['所属向け', 1]
    ]
  end

  def send_to_status
    send_to_name.rassoc(send_to).try(:first).to_s
  end

  def answer_confirm_message
    send_to == 1 ? '所属として回答します。よろしいですか？' : 'この内容で回答します。よろしいですか？'
  end

  def send_to_kind_name
    [
      ['一名のみ', 0] ,
      ['複数許可', 1]
    ]
  end

  def send_to_kind_status
    send_to_kind_name.rassoc(send_to_kind).try(:first).to_s
  end

  def answer_count_name
    "一覧(#{self.answer_count.to_i})"
  end

  def display_expiry_date
    ret = ''
    if self.expiry_date
      ret = self.expiry_date.strftime('%Y-%m-%d %H:%M')
      red_set = false
      red_set = true if self.expiry_date < Time.now
      red_set = true if self.state == 'closed'
      ret = %Q[<span style="color:red">#{ret}</span>] if red_set
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
    ret = "#{ret}/enquete/#{self.id}/answers/new?k=#{self.keycode}"
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
    ret = "#{ret}#{self.system_name}/#{self.id}/results?k=#{self.keycode}"
    return ret
  end

private

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
      field_lists = JSON.parse(self.form_body) unless self.form_body.blank?
      if field_lists.size == 0
        errors.add :state, "設問が登録されていません。保存後,設問登録処理へ進んでください。"
        self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
      end
    end
  end

  def set_section_name
    if group = System::Group.where(:code => section_code).first
      self.section_name = "#{group.code}#{group.name}"
      self.section_sort = group.sort_no
    else
      self.section_name = ''
      self.section_sort = 0
    end
  end

  def update_answer_record_expiry_date_field
    Enquete::Answer.where(:title_id => id).update_all(:expiry_date => expiry_date)
  end
end
