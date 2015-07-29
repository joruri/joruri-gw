# -*- encoding: utf-8 -*-
class Enquete::Answer < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :base , :foreign_key => :title_id  ,:class_name=>'Questionnaire::Base'

  after_validation :check_field_permit
  after_save  :commission_count_update

  attr_accessor :_field_lists
  attr_accessor :_item_params

  #
  def status_name
    str = ''
    str = '<div align="center"><span class="required">未回答</span></div>' if self.state == 'draft'
    str = '<div align="center"><span class="notice">回答済</span></div>' if self.state == 'public'
    return str
  end

  def edit_path
    return "/enquete/#{self.title_id}/answers/#{self.id}/edit"
  end
  def show_path
    return "/enquete/#{self.title_id}/answers/#{self.id}"
  end
  def update_path
    return "/enquete/#{self.title_id}/answers/#{self.id}"
  end
  def seal_path
    return "/enquete/#{self.title_id}/answers/#{self.id}/public_seal"
  end
  def result_show_path
    return "/questionnaire/#{self.title_id}/answers/#{self.id}"
  end

  def view_title
    return nil if self.base.blank?
    return self.base.title
  end
  def enquete_path
    return nil if self.base.blank?
    ret = ''
    return "/enquete/#{self.title_id}/answers/#{self.id}" if self.state == 'public' if self.base.state == 'closed'
    return "/enquete/#{self.title_id}/answers/#{self.id}/edit" if self.state == 'public' if self.base.state == 'public'
    ret = "/enquete/#{self.title_id}/answers/new" unless self.state == 'public'
    return ret
  end
  def enquete_division_state_name
    ret = ''
    ret = '記名' if self.enquete_division
    ret = '無記名' unless self.enquete_division
    return ret
  end

  #
  def target_user_name
    ret = ''
    ret = "#{self.editordivision} #{self.editor}" if self.base.enquete_division
    return ret
  end

  def target_user_code
    return ''
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

  #入力許可設定の確認
  def check_field_permit
    return if self._field_lists.blank?

    check_value_array_parameters

    for item in self._field_lists
      field_name = item['field_name']
      #入力許可設定
      unless item['permit_field'].blank?
        permit_field_name = item['permit_field']
        #許可対象の選択値が違っていたら
        is_error = true
        is_array_value = false
        is_array_value = true if item['question_type'] == 'radio'
        is_array_value = true if item['question_type'] == 'checkbox'
        unless self[permit_field_name].blank?
          permit_values = item['permit_check_value'].gsub(/ /, '').split(',')
          for permit_value in permit_values
            if is_array_value
              is_error = false if self[permit_field_name].index(permit_value)
            else
              case item['permit_type']
              when 'radio'
                is_error = false if JsonBuilder.new.build(self[permit_field_name]).index(permit_value)
              when 'checkbox'
                is_error = false if JsonBuilder.new.build(self[permit_field_name]).index(permit_value)
              else
                is_error = false if self[permit_field_name] == permit_value
              end
            end
          end
        end
        #登録あったら確認
        unless self[field_name].blank?
            errors.add field_name, "#{item['title']}　選択肢を確認してください" if is_error
        else
          #許可対象の時の必須入力確認
          errors.add field_name, "#{item['validate_title']}　選択肢によって回答が必要です" if self[field_name].blank? if item['validate_check'] unless is_error
        end
      end

      #必須入力チェック
      if item['validate_check']
        errors.add field_name, "#{item['validate_title']}　必須入力項目です。" if self[field_name].blank?
      end if item['permit_field'].blank?
    end
  end

  #
  def check_value_array_parameters
    if self._item_params.blank?
      value_array_parameters_reset
    else
      value_array_parameters_set
    end
  end
  #送信内容が無ければ全フィールドをクリア
  def value_array_parameters_reset
    for i in 1..64
      field_name = "field_#{sprintf('%03d', i)}"
      self[field_name] = nil
    end
  end
  #
  def value_array_parameters_set
    return if self._field_lists.blank?

    for item in self._field_lists
      is_array_value = false
      is_array_value = true if item['question_type'] == 'radio'
      is_array_value = true if item['question_type'] == 'checkbox'
      if is_array_value
        field_name = item['field_name']
        self[field_name] = self._item_params[field_name] if item['question_type'] == 'radio' #チェック有->全部なし
        self[field_name] = self._item_params[field_name] if item['question_type'] == 'checkbox' #チェック有->全部なし
        self[field_name] = JsonBuilder.new.build(self[field_name]) unless self[field_name].blank?
      end
    end

  end

  #回答件数を更新
  def commission_count_update
    condition = "state ='public' AND title_id=#{self.title_id}"
    public_count = Enquete::Answer.count(:conditions=>condition)

    condition = "id=#{self.title_id}"
    Questionnaire::Base.update_all("answer_count=#{public_count}", condition)
  end

end
