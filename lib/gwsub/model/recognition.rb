module Gwsub::Model::Recognition
  def self.included(mod)
    mod.after_validation :validate_recognizers
  end

  attr_accessor :_recognition
  attr_accessor :_recognizers

  def check_validate_recognizers
    valid = nil
    _recognizers.each do |k, v|
      valid = true if v.to_s != ''
    end
    errors.add "承認者", 'を選択してください' unless valid
  end

  #ログインユーザー(承認者対象)が既に承認しているか
  def search_recognized_after(item,state=2)
    case state.to_i
    when 2
      # 申請
      rec_mode = 1
    when 5
      # 回答
      rec_mode = 2
    else
      # 承認対象外
      return false
    end
    item.and :mode, rec_mode
    item.and :parent_id, self.id
    item.and :user_id, Core.user.id
    items = item.find(:first)
    unless items.blank?
      if items.recognized_at == nil
        return true
      else
        return false
      end
    end
  end
end