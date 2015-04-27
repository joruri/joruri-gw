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
    r_groups = Gwboard::RenewalGroup.where("start_date = ?", @start_date).order('present_group_id, present_group_code')

    r_groups.each do |r_group|
      incoming_group = r_group.incoming_group

      next if incoming_group.blank?

      ids = Array.new
      update_fields1  = "section_code='#{incoming_group.code}', section_name='#{incoming_group.ou_name}', section_sort=#{incoming_group.sort_no}"
      sql_where1      = "section_code='#{r_group.present_group_code}'"
      _ids = Questionnaire::Base.where(:section_code=>r_group.present_group_code).select("id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Questionnaire::Base.where(:section_code=>r_group.present_group_code).update_all(:section_code=>incoming_group.code, :section_name=>incoming_group.ou_name, :section_sort => incoming_group.sort_no)
        p "questionnaire_bases_1　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end

      ids = Array.new
      update_fields2 = "createrdivision='#{incoming_group.name}', createrdivision_id ='#{incoming_group.code}'"
      sql_where2     = "createrdivision_id='#{r_group.present_group_code}'"
      _ids = Questionnaire::Base.where(:createrdivision_id=>r_group.present_group_code).select("id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Questionnaire::Base.where(:createrdivision_id=>r_group.present_group_code).update_all(:createrdivision=>incoming_group.name, :createrdivision_id => incoming_group.code)
        p "questionnaire_bases_2　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where2}, 更新SQL：#{update_fields2}, #{Time.now}."
      end
    end

    # questionnaire_template_bases
    r_groups.each do |r_group|
      incoming_group = r_group.incoming_group

      next if incoming_group.blank?

      ids = Array.new
      update_fields1  = "section_code='#{incoming_group.code}', section_name='#{incoming_group.ou_name}', section_sort=#{incoming_group.sort_no}"
      sql_where1      = "section_code='#{r_group.present_group_code}'"
      _ids = Questionnaire::TemplateBase.where(:section_code=>r_group.present_group_code).select("id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Questionnaire::TemplateBase.where(:section_code=>r_group.present_group_code).update_all(:section_code=>incoming_group.code, :section_name=>incoming_group.ou_name,:section_sort=>incoming_group.sort_no)
        p "questionnaire_template_bases_1　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end

      ids = Array.new
      update_fields2 = "createrdivision='#{incoming_group.name}', createrdivision_id ='#{incoming_group.code}'"
      sql_where2     = "createrdivision_id='#{r_group.present_group_code}'"
      _ids = Questionnaire::TemplateBase.where(sql_where2).select("id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Questionnaire::TemplateBase.where(:createrdivision_id=>r_group.present_group_code).update_all(:createrdivision=>incoming_group.name,:createrdivision_id=>incoming_group.code)
        p "questionnaire_template_bases_2　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where2}, 更新SQL：#{update_fields2}, #{Time.now}."
      end
    end

    # enquete_answers
    r_groups.each do |r_group|
      incoming_group = r_group.incoming_group

      next if incoming_group.blank?

      ids = Array.new
      update_fields1  = "section_code='#{incoming_group.code}', section_name='#{incoming_group.ou_name}', section_sort=#{incoming_group.sort_no}"
      sql_where1      = "section_code='#{r_group.present_group_code}'"
      _ids = Enquete::Answer.where(:section_code=>r_group.present_group_code).select("id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Enquete::Answer.where(:section_code=>r_group.present_group_code).update_all(:section_code=>incoming_group.code,:section_name=>incoming_group.ou_name,:section_sort=>incoming_group.sort_no)
        p "enquete_answers_1　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end

      ids = Array.new
      update_fields2 = "createrdivision='#{incoming_group.name}', createrdivision_id ='#{incoming_group.code}'"
      sql_where2     = "createrdivision_id='#{r_group.present_group_code}'"
      _ids = Enquete::Answer.where(:createrdivision_id=>r_group.present_group_code).select("id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Enquete::Answer.where(:createrdivision_id=>r_group.present_group_code).update_all(:createrdivision=>incoming_group.name,:createrdivision_id=>incoming_group.code)
        p "enquete_answers_2　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where2}, 更新SQL：#{update_fields2}, #{Time.now}."
      end
    end

    p "アンケート年次切替所属情報更新 終了:#{Time.now}."

  end

  # 異動になったユーザーが管理していたアンケートについて、管理を個人から管理へ変更
  def self.renew_admin_setting
    p "アンケート年次切替 管理範囲情報更新 開始:#{Time.now}."
    questionnaires = Questionnaire::Base.all.group("creater_id")
    questionnaires.each do |questionnaire|
      creater_id = questionnaire.creater_id
      user = System::User.where("code = '#{creater_id}'").first
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
              _ids = Questionnaire::Base.where(sql_where).select("id")
              unless _ids.empty?
                _ids.each do |_id|
                  ids << _id.id
                end
                ids = ids.uniq
                Questionnaire::Base.where(:creater_id=>creater_id, :admin_setting=>0).update_all(:admin_setting=>1)
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
