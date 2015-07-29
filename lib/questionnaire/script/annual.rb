# -*- encoding: utf-8 -*-
#######################################################################
#アンケート　年次所属切り替え更新処理
########################################################################

class Questionnaire::Script::Annual

  def self.renew(start_date = nil)
    if start_date.blank?
      return false
    else
      @start_date = start_date
    end
    p "アンケート年次切替所属情報更新 開始:#{Time.now}."
    renew_admin_setting
    renew_group
    p "アンケート年次切替所属情報更新 終了:#{Time.now}."
  end

  # 変更所属を変更する。
  def self.renew_group
    p "アンケート年次切替所属情報更新 開始:#{Time.now}."
    ids = Array.new

    # questionnaire_bases
    r_groups = Gwboard::RenewalGroup.find(:all,:conditions=>["start_date = ?", @start_date], :order=> 'present_group_id, present_group_code')

    r_groups.each do |r_group|
      incoming_group = System::Group.find(:first, :conditions =>["state = 'enabled' and code = ?",r_group.incoming_group_code])

      next if incoming_group.blank?

      ids = Array.new
      update_fields1  = "section_code='#{incoming_group.code}', section_name='#{incoming_group.ou_name}', section_sort=#{incoming_group.sort_no}"
      update_set1 = ["section_code=?, section_name=?, section_sort=?",incoming_group.code,incoming_group.ou_name,incoming_group.sort_no]
      sql_where1      = "section_code='#{r_group.present_group_code}'"
      _ids = Questionnaire::Base.find(:all, :conditions => sql_where1, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Questionnaire::Base.update_all(update_set1, sql_where1)
        p "questionnaire_bases_1　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end

      ids = Array.new
      update_fields2 = "createrdivision='#{incoming_group.name}', createrdivision_id ='#{incoming_group.code}'"
      update_set2 = ["createrdivision=?, createrdivision_id =?",incoming_group.name,incoming_group.code]
      sql_where2     = "createrdivision_id='#{r_group.present_group_code}'"
      _ids = Questionnaire::Base.find(:all, :conditions => sql_where2, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Questionnaire::Base.update_all(update_set2, sql_where2)
        p "questionnaire_bases_2　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where2}, 更新SQL：#{update_fields2}, #{Time.now}."
      end
    end

    # questionnaire_template_bases
    r_groups.each do |r_group|
      incoming_group = System::Group.find(:first, :conditions =>"state = 'enabled' and code = '#{r_group.incoming_group_code}'")

      next if incoming_group.blank?

      ids = Array.new
      update_fields1  = "section_code='#{incoming_group.code}', section_name='#{incoming_group.ou_name}', section_sort=#{incoming_group.sort_no}"
      update_set1 = ["section_code=?, section_name=?, section_sort=?",incoming_group.code,incoming_group.ou_name,incoming_group.sort_no]
      sql_where1      = "section_code='#{r_group.present_group_code}'"
      _ids = Questionnaire::TemplateBase.find(:all, :conditions => sql_where1, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Questionnaire::TemplateBase.update_all(update_set1, sql_where1)
        p "questionnaire_template_bases_1　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end

      ids = Array.new
      update_fields2 = "createrdivision='#{incoming_group.name}', createrdivision_id ='#{incoming_group.code}'"
      update_set2 = ["createrdivision=?, createrdivision_id =?",incoming_group.name,incoming_group.code]
      sql_where2     = "createrdivision_id='#{r_group.present_group_code}'"
      _ids = Questionnaire::TemplateBase.find(:all, :conditions => sql_where2, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Questionnaire::TemplateBase.update_all(update_set2, sql_where2)
        p "questionnaire_template_bases_2　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where2}, 更新SQL：#{update_fields2}, #{Time.now}."
      end
    end

    # enquete_answers
    r_groups.each do |r_group|
      incoming_group = System::Group.find(:first, :conditions =>"state = 'enabled' and code = '#{r_group.incoming_group_code}'")

      next if incoming_group.blank?

      ids = Array.new
      update_fields1  = "section_code='#{incoming_group.code}', section_name='#{incoming_group.ou_name}', section_sort=#{incoming_group.sort_no}"
      update_set1 = ["section_code=?, section_name=?, section_sort=?",incoming_group.code,incoming_group.ou_name,incoming_group.sort_no]
      sql_where1      = "section_code='#{r_group.present_group_code}'"
      _ids = Enquete::Answer.find(:all, :conditions => sql_where1, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Enquete::Answer.update_all(update_set1, sql_where1)
        p "enquete_answers_1　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end

      ids = Array.new
      update_fields2 = "createrdivision='#{incoming_group.name}', createrdivision_id ='#{incoming_group.code}'"
      update_set2 = ["createrdivision=?, createrdivision_id =?",incoming_group.name,incoming_group.code]
      sql_where2     = "createrdivision_id='#{r_group.present_group_code}'"
      _ids = Enquete::Answer.find(:all, :conditions => sql_where2, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Enquete::Answer.update_all(update_set2, sql_where2)
        p "enquete_answers_2　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where2}, 更新SQL：#{update_fields2}, #{Time.now}."
      end
    end

    # enquete_view_questions
    r_groups.each do |r_group|
      incoming_group = System::Group.find(:first, :conditions =>"state = 'enabled' and code = '#{r_group.incoming_group_code}'")

      next if incoming_group.blank?

      ids = Array.new
      update_fields1  = "section_code='#{incoming_group.code}', section_name='#{incoming_group.ou_name}', section_sort=#{incoming_group.sort_no}"
      update_set1 = ["section_code=?, section_name=?, section_sort=?",incoming_group.code,incoming_group.ou_name,incoming_group.sort_no]
      sql_where1      = "section_code='#{r_group.present_group_code}'"
      _ids = Enquete::ViewQuestion.find(:all, :conditions => sql_where1, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Enquete::ViewQuestion.update_all(update_set1, sql_where1)
        p "enquete_view_questions_1　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end

      ids = Array.new
      update_fields2 = "createrdivision='#{incoming_group.name}', createrdivision_id ='#{incoming_group.code}'"
      update_set2 = ["createrdivision=?, createrdivision_id =?",incoming_group.name,incoming_group.code]
      sql_where2     = "createrdivision_id='#{r_group.present_group_code}'"
      _ids = Enquete::ViewQuestion.find(:all, :conditions => sql_where2, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Enquete::ViewQuestion.update_all(update_set2, sql_where2)
        p "enquete_view_questions_2　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where2}, 更新SQL：#{update_fields2}, #{Time.now}."
      end
    end

    p "アンケート年次切替所属情報更新 終了:#{Time.now}."

  end

  # 異動になったユーザーが管理していたアンケートについて、管理を個人から管理へ変更
  def self.renew_admin_setting
    p "アンケート年次切替 管理範囲情報更新 開始:#{Time.now}."
    questionnaires = Questionnaire::Base.find(:all, :group => "creater_id")
    questionnaires.each do |questionnaire|
      creater_id = questionnaire.creater_id
      user = System::User.find(:first, :conditions => "code = '#{creater_id}'")
      if user.present?
        user_groups = user.user_groups
        if user_groups.present?
          user_group = user_groups[0]
          if user_group.present?
            group_code = nz(user_group.group_code, '')

            if questionnaire.createrdivision_id != group_code # 所属コードを比較して、違っていたら更新をかける。
              ids = Array.new
              update_fields="admin_setting=1"
              sql_where = "creater_id='#{creater_id}' and admin_setting=0"
              _ids = Questionnaire::Base.find(:all, :conditions => sql_where, :select => "id")
              unless _ids.empty?
                _ids.each do |_id|
                  ids << _id.id
                end
                ids = ids.uniq
                Questionnaire::Base.update_all(update_fields, sql_where)
                p "questionnaire_bases　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where}, 更新SQL：#{update_fields}, #{Time.now}."
              end
            end

          end
        end
      end
    end
    p "アンケート年次切替 管理範囲情報更新 終了:#{Time.now}."
  end

end
