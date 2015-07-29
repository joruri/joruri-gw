# -*- encoding: utf-8 -*-
class Questionnaire::Preview < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Questionnaire::Model::Systemname

  belongs_to :base , :foreign_key => :parent_id  ,:class_name=>'Questionnaire::Base'

  after_validation :check_field_permit

  attr_accessor :_field_lists
  attr_accessor :_item_params

  def edit_path
    return "/#{self.system_name}/#{self.parent_id}/previews/#{self.id}/edit"
  end
  def update_path
    return "/#{self.system_name}/#{self.parent_id}/previews/#{self.id}"
  end

  #
  def status_name
    str = ''
    str = '<div align="center"><span class="required">未回答</span></div>' if self.state == 'draft'
    str = '<div align="center"><span class="notice">回答済</span></div>' if self.state == 'public'
    return str
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

end
