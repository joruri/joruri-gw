class Enquete::ViewQuestion < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

#ユーザに対して質問するべきアンケートの一覧を表示する
#CREATE VIEW `enquete_view_questions` AS
# SELECT `enquete_base_users`.`base_user_code`,`questionnaire_bases`.*
# FROM (`enquete_base_users` JOIN `questionnaire_bases`)
# WHERE `questionnaire_bases`.`state` = 'public'
# AND NOW() <= `questionnaire_bases`.`expiry_date`

  def enquete_path
    return "/enquete/#{self.id}/answers/new"
  end

  def view_title
    return self.title
  end

  def enquete_division_state_name
    ret = ''
    ret = '記名' if self.enquete_division
    ret = '無記名' unless self.enquete_division
    return ret
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

end
