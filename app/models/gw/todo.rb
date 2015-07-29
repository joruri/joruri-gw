# -*- encoding: utf-8 -*-
class Gw::Todo < Gw::Database
  #establish_connection :dev_jgw_gw rescue nil
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :title
  #gw_validates_datetime :ed_at, :allow_blank=>1

  validate :validate_count, :validate_ed_at
  def creatable?
    true
  end

  def editable?
    uid == Core.user.id
  end

  def deletable?
    uid == Core.user.id
  end

  def validate_count
    errors.add_to_base 'ToDoは２００件以上登録することができません。' if self.class.get_count >= 200 && self.new_record?
  end

  def validate_ed_at
    if !ed_at.blank? &&  !st_at.blank?
      errors.add :ed_at, 'は開始時間より後に設定してください。' if st_at >= ed_at
    end
  end

  def self.get_count(uid = Core.user.id)
    todos = Gw::Todo.find(:all, :conditions=>"uid=#{uid}")
    return todos.size
  end

  def self.cond(uid = nil)
    user = Core.user
    return "class_id = 2 and uid IS NULL" if uid.blank? && user.blank?
    uid = user.id if uid.nil?
    return "class_id = 1 and uid = #{uid}"
  end

  def _title(chop_length = 20)
    return !title.blank? ? title : Gw.chop_str(body, chop_length)
  end

  def self.finished_select
    item = [['未完了', 0],['完了', 1]]
    return item
  end
  def self.finished_show(finished)
    return "未完了" if finished.blank?
    item = [[0, '未完了'],[1, '完了']]
    finish_val = finished || 0
    show_str = item.assoc(finish_val)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end
end
