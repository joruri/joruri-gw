class Questionnaire::TemplateFormField < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Questionnaire::Model::TemplateFieldOption
  include Questionnaire::Model::TemplateSystemname

  has_many :field_options, :foreign_key => :field_id, :class_name => 'Questionnaire::TemplateFieldOption', :dependent => :destroy
  belongs_to :base, :foreign_key => :parent_id, :class_name => 'Questionnaire::TemplateBase'
  belongs_to :permit, :foreign_key => :post_permit, :class_name => 'Questionnaire::TemplateFormField'

  after_validation :validate_title
  before_save :set_group_code
  after_save :create_form_fields, :create_option_body
  after_destroy :create_form_fields

  validates_presence_of :state, :sort_no, :title
  validate :validate_max_form_fields

  attr_accessor :_skip_logic

  def children
    self.class.where(:parent_id => parent_id, :group_code => group_code)
      .where.not(:question_type => "group")
      .order(:sort_no).all
  end

  def parent
    self.class.where(:parent_id => parent_id, :group_code => group_code, :question_type => "group").first
  end

  def group_body_json
    form_str = self.group_body
    form_str = form_str.gsub(/\r\n?/, '\\n') unless form_str.blank?
    return form_str
  end

  def option_body_json
    form_str = self.option_body
    form_str = form_str.gsub(/\r\n?/, '\\n') unless form_str.blank?
    return form_str
  end

  def states
    {'public' => '有効', 'closed' => '無効'}
  end

  def state_name
    states[state]
  end

  def question_types
    {'text' => 'テキストボックス', 'textarea' => 'テキストエリア', 'radio' => 'ラジオボタン', 'checkbox' => 'チェックボックス', 'select' => 'セレクトボックス', 'display' => 'ラベルテキスト', 'group' => 'グループ設定'}
  end

  def question_type_name
    question_types[question_type]
  end

  def form_field_type
    question_types.to_a.each{|a| a.reverse!}
  end

  def post_permit_base_states
    [
      ['使用しない', false],
      ['使用する', true]
    ]
  end

  def post_permit_base_state_name
    post_permit_base_states.rassoc(post_permit_base).try(:first).to_s
  end

  def required_entry_states
    [
      ['入力チェックしない', 0],
      ['必須チェックする', 1]
    ]
  end

  def required_entry_state_name
    required_entry_states.rassoc(required_entry).try(:first).to_s
  end

  def is_question_type_text
    question_type.in?(['text', 'textarea'])
  end

  def auto_number_states
    [
      ['使用する', true],
      ['使用しない', false]
    ]
  end

  def auto_number_state_name
    auto_number_states.rassoc(auto_number_state).try(:first).to_s
  end

  def auto_number_label
    auto_number_state ? auto_number : ''
  end

  def group_number_states(repeat=10)
    (1 .. repeat).to_a.map{|r| [r.to_s.tr('0-9','０-９'), r]}
  end

  def group_number_names(parent_id)
    return [] if parent_id.blank?

    group_fields = Questionnaire::TemplateFormField.where(:parent_id => parent_id, :state => "public", :question_type => "group").order(:id).all
    group_fields.map{|f| [f.group_name, f.group_code]}
  end

  #フォーム描画用のハッシュを配列にて保持する
  def create_form_fields
    return if self._skip_logic

    update_field_name
    update_group_field_name

    sql = Condition.new
    #グループ化しない通常パーツ
    sql.or {|d|
      d.and :state, 'public'
      d.and :parent_id , self.parent_id
      d.and :group_code, 'is', nil
    }
    #グループ親設定
    sql.or {|d|
      d.and :state, 'public'
      d.and :question_type, 'group'
      d.and :parent_id, self.parent_id
    }
    items = Questionnaire::TemplateFormField.where(sql.where).order(:sort_no, :id).all
    form_body = []
    items.each do |fld|
      form_body << return_normal_field_hash(fld)
      create_group_field_hash(fld) if fld.question_type == 'group'
    end
    body_string = ''
    body_string = JSON.generate(form_body)
    Questionnaire::TemplateBase.where(:id => parent_id).update_all(:form_body => body_string)
  end

private

  def validate_title
    unless self.title.blank?
      self.title = self.title.tr('"', '”')
      self.title = self.title.tr("'", '’')
    end

    #グループ設定とテキストボックス、ラジオボタン以外でグループコードの登録をさせない
    unless self.question_type == 'text' or self.question_type == 'radio' or self.question_type == 'select'
      self.group_code = nil
      self.group_repeat = nil
    end unless self.question_type == 'group'

    #テキストボックス、ラジオボタンでグループの時、入力必須チェックと投稿許可設定の登録をさせない
    if self.question_type == 'text' or self.question_type == 'radio' or self.question_type == 'select'
      self.required_entry = nil
      self.post_permit = nil
      self.post_permit_value = nil
      self.group_repeat = nil
    end unless self.group_code.blank?
    #グループ設定の時、入力必須チェックと投稿許可設定の登録をさせない
    if self.question_type == 'group'
      self.required_entry = nil
      self.post_permit = nil
      self.post_permit_value = nil
    end unless self.group_code.blank?

    #グループ化の時はコード必須
    #errors.add :group_code, "グループコードを設定してください。" if self.group_code.blank? if self.question_type == 'group'
    errors.add :group_name, "を設定してください。" if self.group_name.blank? if self.question_type == 'group'
    #グループ化の時は繰り返し行数必須
    errors.add :group_repeat, "を設定してください。" if self.group_repeat.blank? if self.question_type == 'group'

    if self.question_type == 'display'
      self.required_entry = 0
      self.post_permit = nil
      self.post_permit_value = nil
      self.title = '　' if self.title.blank?
    else
      errors.add :title, "を入力してください。" if self.title.blank?
    end

    unless self.post_permit.blank?
      if self.post_permit_value.blank?
        errors.add :post_permit_value, "投稿許可設定を行うときは、許可する値を設定してください。"
      else
        unless self.post_permit_value =~ /^[0-9,\s]+$/
          errors.add :post_permit_value, "許可する値は半角数字のみで入力してください。"
        else
          array_values = self.post_permit_value.gsub(/ /, '').split(',')
          array_values.reject! {|x| x.blank?}
          array_values.uniq!
          val = []
          for value in array_values
            val << value.to_i
          end
          val.uniq!
          self.post_permit_value = val.join(',')
        end
      end
    end
  end

  def validate_max_form_fields
    if self.state == "public"
      if self.new_record?
        current = Questionnaire::TemplateFormField.where(["parent_id = ? AND state = ?",self.parent_id,"public"]).count
      else
        current = Questionnaire::TemplateFormField.where(["parent_id = ? AND id != ? AND state = ?",self.parent_id, self.id,"public"]).count
      end
      self.errors.add_to_base "設問数は64問以内で作成してください。" unless current < 64
    end
  end

  def set_group_code
    if self.group_code.blank? && self.question_type == "group"
      old_group = Questionnaire::TemplateFormField
        .where(["parent_id = ? AND question_type = ?", self.parent_id, "group"])
        .order(:group_code => :desc).first
      if old_group.blank?
        new_group_code = 1
      else
        old_group_code = old_group.group_code
        new_group_code =  old_group_code + 1
      end
      self.group_code = new_group_code
    end
    if  !self.group_code.blank? && self.question_type != "group"
      group_set = Questionnaire::TemplateFormField
        .where(["parent_id = ? AND group_code = ? AND question_type = ?", self.parent_id,self.group_code,"group"]).first
      unless group_set.blank?
        self.group_name = group_set.group_name
      end
    end
  end

  def update_field_name
    sql = Condition.new
    #グループ化しない通常パーツ
    sql.or {|d|
      d.and :state, 'public'
      d.and :parent_id , self.parent_id
      d.and :group_code, 'is', nil
    }
    #グループ親設定
    sql.or {|d|
      d.and :state, 'public'
      d.and :question_type, 'group'
      d.and :parent_id, self.parent_id
    }
    items = Questionnaire::TemplateFormField.where(sql.where).order(:sort_no, :id).all
    i = 0
    auto = 0
    for fld in items
      i += 1
      field_name = "field_#{sprintf('%03d', i)}"
      auto += 1 if fld.auto_number_state
      auto_number = 0
      auto_number = auto if fld.auto_number_state
      Questionnaire::TemplateFormField.where("id=#{fld.id}").update_all("field_name='#{field_name}',auto_number=#{auto_number}")
    end unless items.blank?
  end

  def update_group_field_name
    item = Questionnaire::TemplateFormField.new
    item.and :state, 'public'
    item.and :parent_id , self.parent_id
    item.and :group_code, 'is not', nil
    item.order 'sort_no, id'
    items = item.find(:all)
    i = 0
    for fld in items
      unless fld.question_type == 'group'
        i += 1
        field_name = "group_#{sprintf('%03d', i)}"
      else
        field_name = ''
      end
      Questionnaire::TemplateFormField.where("id=#{fld.id}").update_all("group_field='#{field_name}'")
    end unless items.blank?
  end

  def return_normal_field_hash(fld)
    permit_field = ''
    permit_title = ''
    permit_type = ''
    unless fld.permit.blank?
      permit_field = fld.permit.field_name
      permit_title = cut_off(fld.permit.title, 26)
      permit_type = fld.permit.question_type
    end
    permit_check_value = fld.post_permit_value
    validate_check = false
    validate_title = ''
    if fld.required_entry == 1
      validate_check = true
      validate_title = cut_off(fld.title, 26)
    end
    return {
      :field_id=>fld.id,
      :question_type=>fld.question_type,
      :field_name=>fld.field_name,
      :title=>fld.title,
      :field_cols=>fld.field_cols,
      :field_rows=>fld.field_rows,
      :permit_field=>permit_field,
      :permit_title=>permit_title,
      :permit_type=>permit_type,
      :permit_check_value=>permit_check_value,
      :validate_check=>validate_check,
      :validate_title=>validate_title,
      :auto_label=>fld.auto_number ,
      :group_code=>fld.group_code ,
      :group_repeat=>fld.group_repeat
    }
  end

  def create_group_field_hash(fld)
    groups = Questionnaire::TemplateFormField.where(:state => 'public', :parent_id => self.parent_id, :group_code => fld.group_code)
      .where.not(:question_type => 'group')
      .order(:sort_no, :id).all

    group_body = []
    groups.each do |group|
      group_body << {
        :field_label => group.title, 
        :field_name => group.group_field ,
        :field_cols => group.field_cols, 
        :field_type => group.question_type, 
        :field_id => group.id
      }
    end
    group_body_string = JSON.generate(group_body)
    Questionnaire::TemplateFormField.where(:id => fld.id).update_all(:group_body => group_body_string)
  end

  #選択肢描画用データを保持する
  def create_option_body
    return if self._skip_logic

    is_option = false
    case self.question_type
    when 'text'
    when 'textarea'
    when 'radio'
      is_option = true
    when 'checkbox'
      is_option = true
    when 'select'
      is_option = true
    when 'display'
    else
    end
    form_option = []
    if self.question_type == 'select'
      form_option << [' ', '']
    end unless self.post_permit_value.blank?
    if is_option
      field_options.order(:id).all.each do |opt|
        title = opt.title
        title = " " if title.blank?
        if self.question_type == 'select'
          value = ''
          value = opt.value
          form_option << [title, value]
        else
          form_option << {:value => opt.value,:title => title}
        end unless opt.value.blank?
      end
      option_string = ''
      option_string = JSON.generate(form_option) unless form_option.size == 0
      self.option_body = option_string
      self._skip_logic = true
      self.save
    end
  end

  def cut_off(text, len)
    if text != nil
      if text.split(//).size < len
        text
      else
        text.scan(/^.{#{len}}/m)[0] + "…"
      end
    else
      ''
    end
  end
end
