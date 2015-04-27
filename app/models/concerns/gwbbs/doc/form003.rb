module Concerns::Gwbbs::Doc::Form003
  extend ActiveSupport::Concern

  included do
    with_options if: :form_name_form003? do |f|
      f.after_validation :set_tilte_form003
      f.validates :inpfld_012, presence: { message: "役職名を選択してください。" }
      f.validates :inpfld_013, presence: { message: "職員の名前を入力してください。" }, if: :inpfld_024_kazoku?
      f.validates :inpfld_014, presence: { message: "続柄を選択してください。" }, if: :inpfld_024_kazoku?
      f.validates :inpfld_015, presence: { message: "故人の名前を入力してください。" }, if: :inpfld_024_kazoku?
      f.validates :inpfld_025, presence: { message: "職員の名前を入力してください。" }, if: :inpfld_024_syokuin?
      f.validate :validate_form003
    end
  end

  def form_name_form003?
    form_name == 'form003'
  end

  private

  def inpfld_024_kazoku?
    inpfld_024 == "家族"
  end

  def inpfld_024_syokuin?
    inpfld_024 == "職員"
  end

  def validate_form003
    if (self.inpfld_001.to_time rescue nil) == nil || self.inpfld_001.blank?
      errors.add :inpfld_001,"逝去日を入力してください。"
    else
      self.inpfld_001 = Date.parse(self.inpfld_001).strftime('%Y-%m-%d')
    end

    if self.inpfld_003.present?
      if (self.inpfld_003.to_time rescue nil) == nil
         errors.add :inpfld_003,"通夜の日付を入力してください。"
      else
        self.inpfld_003 = Date.parse(self.inpfld_003).strftime('%Y-%m-%d')
      end
    end

    if self.inpfld_006.present?
      if (self.inpfld_006.to_time rescue nil) == nil
        errors.add :inpfld_006,"告別式の日付を入力してください。"
      else
        self.inpfld_006 = Date.parse(self.inpfld_006).strftime('%Y-%m-%d')
      end
    end
  end

  def set_tilte_form003
    str_title = '＊'
    group = System::Group.find_by(code: self.inpfld_023)
    if self.inpfld_024 == "家族"
      if group.blank?
        str_title = "#{self.inpfld_012} #{self.inpfld_013} さんの　#{self.inpfld_014} #{self.inpfld_015} 様が亡くなられました"
      else
        str_title = "#{group.name} #{self.inpfld_012} #{self.inpfld_013} さんの　#{self.inpfld_014} #{self.inpfld_015} 様が亡くなられました"
      end
    else
      if group.blank?
        str_title = "#{self.inpfld_012} #{self.inpfld_025} さんが亡くなられました"
      else
        str_title = "#{group.name} #{self.inpfld_012} #{self.inpfld_025} さんが亡くなられました"
      end
    end
    self.title = str_title
  end
end
