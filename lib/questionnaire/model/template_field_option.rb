# -*- encoding: utf-8 -*-
module Questionnaire::Model::TemplateFieldOption
  def self.included(mod)
    mod.has_many :options,  :foreign_key => :field_id,  :order => "#{Questionnaire::TemplateFieldOption.table_name}.sort_no",
                 :conditions => "#{Questionnaire::TemplateFieldOption.table_name}.state = 'public'", :class_name => 'Questionnaire::TemplateFieldOption',
                 :dependent => :destroy

    mod.after_validation :validate_options
    mod.after_save :save_options
  end

  attr_accessor :_options

  def find_option_by_id(opt_id=nil)
    return nil unless options
    opt_id = self.get_answer unless opt_id

    options.each do |opt|
      return opt if opt.id.to_s == opt_id.to_s
    end
    return nil
  end

  def find_option_by_value(opt_value=nil)
    return nil unless options
    opt_value = self.get_answer unless opt_value
    options.each do |opt|
      return opt if opt.value.to_s == opt_value.to_s
    end
    return nil
  end

  def validate_options
    return true unless (self.question_type == 'radio' || self.question_type == 'select' || self.question_type == 'checkbox')

    exist = nil
    req   = nil
    dup   = nil

    if _options
      tmp = {}
      _options.each do |k, v|
        #preparation
        v['value'] =v['title'] if v['value'].blank? && !v['title'].blank?

        #exist
        exist  = true if v['title'] != ''

        v['value'] = '' if v['title'].blank?
        #required
        if v['value'] != '' && v['title'] == ''
          req  = [] unless req
          req << k.to_s
        end

        #overlap
        if v['value'] != '' && tmp.has_key?(v['value'])
          dup = [] unless dup
          dup << k.to_s
        end
        tmp[v['value']] = true
      end

      if !exist
        errors.add 'オプション', 'を指定してください。'
      elsif req
        req.each do |k| errors.add "オプション: ラベル(#{k.to_i + 1}行目)", "を入力してください。" end
      elsif dup
        dup.each do |k| errors.add "オプション: 値(#{k.to_i + 1}行目)", "が重複しています。" end
      end
    end
  end

  def save_options
    return true  unless _options
    return false if @save_option_callback_flag

    @save_option_callback_flag = true

    _options.to_a.sort.each do |i, opt|
      unless opt['id'].blank?
        option = Questionnaire::TemplateFieldOption.find_by_id(opt['id'])
        option.attributes = opt
        option.state      = 'public'
        option.published_at = Core.now
      else
        option = Questionnaire::TemplateFieldOption.new({
                        :id         => opt['id'],
                        :state      => 'public',
                        :published_at => Core.now,
                        :field_id => self.id,
                        :value => opt['value'],
                        :title => opt['title'],
                        :sort_no => opt['sort_no'],
                     }
                    )
      end
      option.value = option.title if option.value.blank? && !option.title.blank?
      if option.id && option.value.blank? && option.title.blank? && option.sort_no.blank?
        option.destroy
      else
        option.save
      end
      value_renumber
    end
    options(true)
    return true
  end

  def value_renumber
    item = Questionnaire::TemplateFieldOption.new
    item.and :field_id ,self.id
    item.and :state , 'public'
    item.order :id
    items = item.find(:all)
    i = 0
    for renum in items
      i += 1
      renum.value = i
      renum.save
    end
  end
end
