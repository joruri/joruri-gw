module Cms::Lib::Content::Doc::Recognizer
  def recognizable?(user_id)
    return false if self.state_no != 2
    return true if self.recognize1_user_id == user_id && self.recognize1_date == nil
    return true if self.recognize2_user_id == user_id && self.recognize2_date == nil
    return true if self.recognize3_user_id == user_id && self.recognize3_date == nil
    return true if self.recognize4_user_id == user_id && self.recognize4_date == nil
    return true if self.recognize5_user_id == user_id && self.recognize5_date == nil
    return false
  end
  
  def recognized?(user_id = nil)
    if user_id == nil
      result = true
      if self.recognize1_user_id == nil && self.recognize2_user_id == nil &&
        self.recognize3_user_id == nil && self.recognize4_user_id == nil &&
        self.recognize5_user_id == nil
        result = false
      end
      result = false if self.recognize1_user_id != nil && self.recognize1_date == nil
      result = false if self.recognize2_user_id != nil && self.recognize2_date == nil
      result = false if self.recognize3_user_id != nil && self.recognize3_date == nil
      result = false if self.recognize4_user_id != nil && self.recognize4_date == nil
      result = false if self.recognize5_user_id != nil && self.recognize5_date == nil
    else
      result = false
      result = true if self.recognize1_user_id == user_id && self.recognize1_date != nil
      result = true if self.recognize2_user_id == user_id && self.recognize2_date != nil
      result = true if self.recognize3_user_id == user_id && self.recognize3_date != nil
      result = true if self.recognize4_user_id == user_id && self.recognize4_date != nil
      result = true if self.recognize5_user_id == user_id && self.recognize5_date != nil
    end
    return result 
  end
  
  def clear_recognition
    self.recognize1_date = nil
    self.recognize2_date = nil
    self.recognize3_date = nil
    self.recognize4_date = nil
    self.recognize5_date = nil
  end
  
protected
  def _recognize(user_id)
    result = true
    case user_id
      when self.recognize1_user_id
        self.recognize1_date = Core.now 
      when self.recognize2_user_id
        self.recognize2_date = Core.now
      when self.recognize3_user_id
        self.recognize3_date = Core.now
      when self.recognize4_user_id
        self.recognize4_date = Core.now
      when self.recognize5_user_id
        self.recognize5_date = Core.now
      else
        result = false
    end
    return result
  end
end