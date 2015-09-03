class Gw::ScheduleRepeat < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  has_many :schedules, :foreign_key => :schedule_repeat_id, :class_name => 'Gw::Schedule', :dependent=>:destroy

  def self.save_with_rels_concerning_repeat(item, params, mode,options = {})
   raise "update/create 以外は未実装です" if %w(update create).index(mode.to_s).nil?
    form_kind_id = params[:item][:form_kind_id]
    if form_kind_id == "0" || form_kind_id == "2"
      params[:item][:inquire_to] = ""
      params[:item][:schedule_props_json] = "[]"
    end
    tmp_cond_str = "tmp_id != ? and st_at <= ? and ed_at >= ? and prop_type = ? and prop_id = ? and created_at > ? and created_at <= ?"
    current_time = Time.now
    tmp_time = Time.now - 5.minutes
    option_items = params[:options].blank? ? "" : params[:options].join(",")
    _props = JSON.parse(params[:item][:schedule_props_json])
    prop_cancelled_cond = "gw_schedule_props.extra_data is null or gw_schedule_props.extra_data not like '%\"cancelled\":1%'" # キャンセルを条件に加えるSQL文
    rentcar_flg = false
    has_pm = 0; has_mr_pm = 0; has_ot_ot = 0; has_rc_pm = 0; mr_pm_ids = []; rc_pm_ids = []; ot_ot_ids = []; first_meetingroom_id = 0; first_meetingroom_name = ''
    _masters = {'meetingroom'=>Gw::PropMeetingroom, 'rentcar'=>Gw::PropRentcar, 'other'=>Gw::PropOther}
    prop_details = []
    _props.each{|x|
      _x = x
      _genre, _id = x[0], x[1]
      _x.push _masters[_genre].where("id=#{_id}").first
      prop_details.push _x
      if _genre == 'rentcar'
        rentcar_flg = true
      end
    }
    prop_details.each{|x|
      _genre, _id, _prop = x[0], x[1], x[3]
      if nz(_prop.extra_flag, 'other') == 'pm' || nz(_prop.extra_flag, 'other') == 'other'
        has_pm += 1
        if x[0] == 'meetingroom'
          has_mr_pm += 1
          mr_pm_ids.push _id
        end
        if x[0] == 'rentcar'
          has_rc_pm += 1
          rc_pm_ids.push _id
        end
        if x[0] == 'other'
          has_ot_ot += 1
          ot_ot_ids.push _id
        end
      end
    }

    #
    if !params[:item].key?(:guide_state) || has_mr_pm > 0 || has_rc_pm > 0
      params[:item][:guide_state] = '0'
    end

    is_gw_admin = Gw.is_admin_admin?
    is_pm_admin = is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin? # 管財管理者

    if mode == :update
      cg = Gw::Model::Schedule.get_group(:gid => item.creator_gid)
    else
      if params[:item][:creator_uid].blank?
        cu = Core.user
      else
        cu = System::User.get(item[:creator_uid])
      end
      cg = cu.groups[0]
    end

    if has_mr_pm > 0 || has_rc_pm > 0
      ouid = params[:item][:owner_uid]
      if ouid.blank?
        item.errors.add :owner_udisplayname, 'は空欄となっています。ユーザーを指定してください。'
        return false
      end
      ou = Gw::Model::Schedule.get_user(ouid)
      og = ou.groups[0]
      if og.blank?
        item.errors.add :owner_udisplayname, 'に指定されているユーザーは、現在、存在しません。他のユーザーを指定してください。'
      else
        ogid = og.id
      end
    end


    kanzai_flg = false
    prop_flg = false
    kanzai_flg = true if has_mr_pm > 0 || has_rc_pm > 0
    prop_flg = true if kanzai_flg || has_ot_ot > 0


    if form_kind_id == "0" || (!kanzai_flg && prop_flg)
      params[:item][:to_go] = ""
      params[:item][:participant_nums_inner] = ""
      params[:item][:participant_nums_outer] = ""
      params[:item][:check_30_over] = ""
      params[:item][:admin_memo] = ""
    end

    if form_kind_id == "1"
      params[:item][:event_week] = nil
      params[:item][:event_month] = nil
      params[:item][:event_word] = nil
    end

    # Todo
    if form_kind_id == "2"
      params[:item][:event_week] = nil
      params[:item][:event_month] = nil
      params[:item][:guide_state] = '0'
      params[:item][:title_category_id] = ""
      params[:item][:todo] = '1'
      params[:item][:todo_st_at_id] = '2'
      params[:item][:allday] = nil
      if params[:init][:repeat_mode] == '1'
        todo_ed_at = Gw.get_parsed_date(params[:item][:ed_at])
        params[:item][:st_at] = todo_ed_at.strftime("%Y-%m-%d 0:00")
        todo_st_at = Gw.get_parsed_date(params[:item][:st_at])
        if params[:item][:todo_st_at_id] == '1' || params[:item][:todo_st_at_id] == '2'
          params[:item][:st_at] = Time.local(todo_st_at.year, todo_st_at.month, todo_st_at.day, 0, 0, 0).strftime("%Y-%m-%d %H:%M")
        end
        if params[:item][:todo_ed_at_id] == '1' || params[:item][:todo_ed_at_id] == '2'
          params[:item][:ed_at] = Time.local(todo_ed_at.year, todo_ed_at.month, todo_ed_at.day, 23, 59, 59).strftime("%Y-%m-%d %H:%M")
        end
      elsif params[:init][:repeat_mode] == '2'
        params[:item][:repeat_st_time_at] = '0:00'
        if params[:item][:todo_repeat_time_id] == '1'
          params[:item][:repeat_ed_time_at] = '23:59'
        elsif params[:item][:todo_repeat_time_id] == '0'
          params[:item][:todo_ed_at_id] = '0'
        end
      end
    else
      params[:item][:todo] = '0'
      params[:item][:todo_st_at_id] = '0'
      params[:item][:todo_ed_at_id] = '0'
      params[:item][:todo_repeat_time_id] = '0'
    end

    if !params[:item][:event_week].blank? || !params[:item][:event_month].blank?
      event_flg = true
    else
      event_flg = false
    end

    if kanzai_flg || has_ot_ot > 0
      params[:item][:allday] = nil
    else
      if !params[:item][:allday_radio_id].blank?
        if params[:init][:repeat_mode] == "1"
          params[:item][:allday] = params[:item][:allday_radio_id]
        elsif params[:init][:repeat_mode] == "2"
          params[:item][:allday] = params[:item][:repeat_allday_radio_id]
        end
      end
    end
    if prop_flg || form_kind_id == "2"
      params[:item][:allday] = nil
    end

    if mode == :update
      if !item.prop_meetingroom_actual.blank? || !item.prop_rentcar_actual.blank?
        item.errors.add :"この予約","は既に貸出処理が行われているため、編集できません。"
      end
    end


    if params[:item][:guide_state] == '1'
      guide_place_id = params[:item][:guide_place_id].to_i

      title = params[:item][:title]
      title_chars = title.split(//)
      item.errors.add :title, "は、現在#{title_chars.size}文字です。会議等案内表示を選択した場合、40文字以内で登録してください。" if title_chars.size > 40

      if guide_place_id == 0
        place = params[:item][:place]
        place_chars = place.split(//)
        item.errors.add :place, "は、現在#{place_chars.size}文字です。会議等案内表示を選択した場合、20文字以内で登録してください。" if place_chars.size > 20
      end

      if has_mr_pm > 1
        item.errors.add :schedule_props_add_buf, 'は、会議等案内表示に表示する場合、会議室の予約は1つのみ可能となります。'
      end


      if guide_place_id == 0 && (params[:item][:place].blank? || params[:item][:place] == '')
        item.errors.add :place, 'は、会議等案内表示で表示する場所を入力してください。'
      elsif guide_place_id == 0 && !params[:item][:place].blank?
        params[:item][:guide_place] = params[:item][:place]
      end
      if guide_place_id != 0
        guide_place = Gw::MeetingGuidePlace.where(:id => guide_place_id).first
        params[:item][:guide_place] = guide_place.place
      end
      item.errors.add :is_public, 'は、会議等案内表示に表示する場合、公開しか選択できません。' if nz(params[:item][:is_public],0).to_s != "1"
    else params[:item][:guide_state] = '0'
      params[:item][:guide_place_id] = nil
      params[:item][:guide_place] = nil
      params[:item][:guide_ed_at] = '0'
    end

    par_item_base, par_item_repeat = Gw::Schedule.separate_repeat_params params

    other_rent_flg = true
    other_admin_flg = true
    other_car_flg = false

    if !is_gw_admin
      ot_ot_ids.each{|o_props_id|
        flg = Gw::PropOtherRole.is_edit?(o_props_id)
        unless flg
          other_rent_flg = false
        end
        other_admin_flg =  Gw::PropOtherRole.is_admin?(o_props_id, Core.user_group.id) if other_admin_flg # 自所属でない一般施設があった場合、falseとする。
      }
    end
    item.errors.add :"この設備","は照会のみ可能で予約は行えません。予約する場合は，設備の管理所属にお問い合わせください。" if !other_rent_flg

    if par_item_base[:event_week] == "1" || par_item_base[:event_month] == "1"
      item.errors.add :is_public, 'は週間/月間行事予定とする時、公開しか選択できません。' if nz(par_item_base[:is_public],0).to_s != "1"
    end

    settings = Gw::Schedule.load_system_settings
    is_pm_restrict_time = lambda{|part|
      return [nil,nil] if nf(settings["restrict_regist_with_pm_by_#{part}_time"]).blank?
      settings["restrict_regist_with_pm_#{part}_time"].scan(/^(\d{1,2}:\d{1,2})-(\d{1,2}:\d{1,2})$/)
      [$1, $2].each{|x| raise ApplicationError, '' if !Gw.validates_datetime(x)}
      return [Gw.to_time($1), Gw.to_time($2)]
    }
    restrict_operation_st, restrict_operation_ed = is_pm_restrict_time.call :operation
    restrict_reservation_st, restrict_reservation_ed = is_pm_restrict_time.call :reservation
    rentcar_restrict_reservation_st, rentcar_restrict_reservation_ed = is_pm_restrict_time.call :rentcar_reservation


    now = Time.now
    in_two_months = now.months_since(2).to_date + 1
    in_six_months = now.months_since(6).to_date + 1
    if !is_pm_admin && kanzai_flg
      start_time = Time.local(now.year.to_i, now.month.to_i, now.day.to_i, 8, 30, 00)
      end_time = Time.local(now.year.to_i, now.month.to_i, now.day.to_i, 18, 15, 00)
      today_dates = (start_time.to_date..end_time.to_date).to_a
      today_weekdays, today_holidays = Gw.extract_holidays(today_dates)
      item.errors.add :"08:30-18:15","の間しか管財施設の予約登録/編集できません。" if !(start_time <= now && now <= end_time)
      item.errors.add :"本日は","閉庁日になるため、管財施設の登録/編集はできません。" if today_holidays.length > 0
    end

    if has_rc_pm > 0 && par_item_base[:to_go].blank?
      item.errors.add :to_go, "は、管財課レンタカーをご利用の場合、入力が必須となります。"
    end

    if params[:item][:title].present?
      _title = params[:item][:title]
      _title = Gw.trim(_title)
      if _title.blank?
        item.errors.add :title, 'を入力してください。'
      elsif _title.split(//).size < 2
        item.errors.add :title, 'は、2文字以上を入力してください。'
      end
    end

    ot_car_items = Gw::PropOther.where("id in (?) and type_id = 100", ot_ot_ids)
    if rentcar_flg || ot_car_items.length > 0
      _place = params[:item][:place]
      _place = Gw.trim(_place)
      if _place.blank? || _place.split(//).size < 2
        item.errors.add :place, 'は、レンタカー、もしくは一般施設の公用車を選択しているとき、必須となっています。2文字以上を入力してください。'
      end
    end


    err_num_st = item.errors.size
    case params[:init][:repeat_mode]
    when "1"
      st_at, ed_at = par_item_base[:st_at], par_item_base[:ed_at]
      %w(st ed).each {|fld|
        item.errors.add "#{fld}_at", 'が異常です' if !Gw.validates_datetime eval("#{fld}_at")
      }

      rent_item_flg = true
      cond_shar = " and (extra_data is null or extra_data not like '%\"cancelled\":1%')" +
        " and schedule_id <> '#{item.id}'" +
        " and ( (gw_schedule_props.st_at <= '#{st_at}' and gw_schedule_props.ed_at > '#{st_at}' )" +
        " or (gw_schedule_props.st_at < '#{ed_at}' and gw_schedule_props.ed_at >= '#{ed_at}' )" +
        " or ('#{st_at}' <= gw_schedule_props.st_at and gw_schedule_props.st_at < '#{ed_at}') )"

      rc_pm_ids.each{|r_props_id|
        rent_item = Gw::Schedule.joins('inner join gw_schedule_props on gw_schedules.id = gw_schedule_props.schedule_id')
        rent_item = rent_item.where("prop_type='#{Gw::PropRentcar}' and prop_id='#{r_props_id}'" + cond_shar).to_a
        if rent_item.length > 0
          rent_item_flg = false
        end
        rent_item_flg = false if options[:check_temporaries] && Gw::SchedulePropTemporary.where(tmp_cond_str,item.tmp_id, ed_at,st_at, "Gw::PropRentcar", r_props_id,tmp_time,current_time).exists?
      }

      mee_item_flg = true

      mee_today_flg = false
      mee_spe_flg = false
      mee_p_flg = false
      mee_type_id = nil

      mee_day = Time.now.strftime("%Y-%m-%d 00:00:00").to_date

      mr_pm_ids.each{|m_props_id|
        mee_item = Gw::Schedule.joins('inner join gw_schedule_props on gw_schedules.id = gw_schedule_props.schedule_id')
        mee_item = mee_item.where("prop_type='#{Gw::PropMeetingroom}' and prop_id='#{m_props_id}'" + cond_shar).to_a
        if mee_item.length > 0
          mee_item_flg = false
        end
        mee_today_item = Gw::PropMeetingroom.where(:id=> m_props_id).first
        mee_today_flg = true if mee_today_item.type_id == 3
        mee_spe_flg = true if mee_today_item.type_id == 4
        mee_type_id = mee_today_item.type_id

        mee_p_flg = true if par_item_base[:participant_nums_inner].to_i + par_item_base[:participant_nums_outer].to_i > mee_today_item.max_person.to_i

      }

      other_item_flg = true
      ot_ot_ids.each{|o_props_id|
        other_item = Gw::Schedule.joins('inner join gw_schedule_props on gw_schedules.id = gw_schedule_props.schedule_id')
        other_item = other_item.where("prop_type='#{Gw::PropOther}' and prop_id='#{o_props_id}'" + cond_shar).to_a
        if other_item.length > 0
          other_item_flg = false
        end
      }

      if params[:item][:form_kind_id] == "1"  && prop_details.blank?
        item.errors.add :"設備","が選択されていません。"
      end


      if item.errors.size == err_num_st
        d_st_at, d_ed_at = Gw.get_parsed_date(st_at), Gw.get_parsed_date(ed_at)
        if !prop_flg && !event_flg
          item.errors.add :ed_at, 'は、開始日時以降の日時を入力してください。' if d_st_at > d_ed_at
        else
          item.errors.add :ed_at, 'は、開始日時より後の日時を入力してください。' if d_st_at >= d_ed_at
        end
        unless is_pm_admin
          item.errors.add :st_at, 'は、現在の時間以降としてください。' if d_st_at < Time.now && kanzai_flg
        end
          competition_str = "終了日時は他の予定と競合しています。別の予定時間を入力してください。"

          item.errors.add :st_at, "、#{competition_str}（レンタカー）" unless rent_item_flg
          item.errors.add :st_at, "、#{competition_str}（会議室）" unless mee_item_flg
          item.errors.add :st_at, "、#{competition_str}（一般施設）" unless other_item_flg
          item.errors.add :st_at, 'は、当日の会議室の予約のため、本日の日付を登録してください。' if mee_today_flg && (mee_day != d_st_at.to_date || d_ed_at.to_date != mee_day) && !is_pm_admin
          item.errors.add :"参加者","は、特別会議室を利用する際はひとつ以上にチェックを入れてください。" if mee_spe_flg && option_items.blank?

          item.errors.add :participant_nums_inner, '、参加人数(庁外) の合計人数が、会議室の収容人数を超えています。' if mee_p_flg && !is_pm_admin
          item.errors.add :st_at, 'は、2010年7月1日以降としてください。管財レンタカー、管財会議室の予約は2010年7月1日以降となります。' if kanzai_flg && !is_pm_admin && st_at.to_date < '2010-07-01 00:00:00'.to_date
          if d_st_at.to_date != d_ed_at.to_date
            item.errors.add :ed_at, 'は、管財課施設をご利用の場合、日をまたいでの予約はできません。' if kanzai_flg
            item.errors.add :ed_at, 'は、会議等案内表示に表示する場合、日をまたいでの予約はできません。' if params[:item][:guide_state] == '1'
          end
        end

        if item.errors.size == err_num_st
        if kanzai_flg
          item.errors.add :st_at, 'は、管財課利用の場合、15分単位でなくてはいけません。' if d_st_at.min % 15 != 0
          item.errors.add :st_at, 'からの利用時間は、管財課利用の場合、30分単位でなくてはいけません。' if (d_ed_at.to_time.to_i - d_st_at.to_time.to_i) % (30 * 60) != 0
        end
        if kanzai_flg && !is_pm_admin
          if !restrict_reservation_st.nil?
            st_w, ed_w = Gw.time_merge_to_datetime(now, d_st_at), Gw.time_merge_to_datetime(now, d_ed_at)
            st_r, ed_r = d_st_at.strftime("%Y-%m-%d 00:00:00"), d_st_at.strftime("%Y-%m-%d 12:00:00")
            item.errors.add :st_at,"・終了日時は、管財課会議室をご利用の場合、#{settings["restrict_regist_with_pm_reservation_time"]}の間しか予約登録/編集できません。" if !(restrict_reservation_st <= st_w && ed_w <= restrict_reservation_ed) && has_mr_pm > 0
            if (!(rentcar_restrict_reservation_st <= ed_w) || !(st_w <= rentcar_restrict_reservation_ed)) && has_rc_pm > 0
              item.errors.add :st_at,"・終了日時は、管財課レンタカーをご利用の場合、#{settings["restrict_regist_with_pm_rentcar_reservation_time"]}の時間帯を含む場合は0時から23時59分の時間帯も予約できますが、それ以外の時間は予約登録/編集できません。"
            end
          end
        end

          if !is_pm_admin && kanzai_flg
            if mee_item_flg
              case mee_type_id
              when 1
                item.errors.add :st_at,": 該当会議室をご利用の場合、６ヶ月以内しか予約登録／編集できません。" if in_six_months <= d_ed_at.to_date
              when 2
                item.errors.add :st_at,": 該当会議室をご利用の場合、６ヶ月以内しか予約登録／編集できません。" if in_six_months <= d_ed_at.to_date
              when 3
                item.errors.add :st_at,": 管財課レンタカー、管財課会議室をご利用の場合、２ヶ月以内しか予約登録／編集できません。" if in_two_months <= d_ed_at.to_date
              when 4
                item.errors.add :st_at,": 該当会議室をご利用の場合、６ヶ月以内しか予約登録／編集できません。" if in_six_months <= d_ed_at.to_date
              else
                item.errors.add :st_at,": 管財課レンタカー、管財課会議室をご利用の場合、２ヶ月以内しか予約登録／編集できません。" if in_two_months <= d_ed_at.to_date
              end
            else
              item.errors.add :st_at,": 管財課レンタカー、管財課会議室をご利用の場合、２ヶ月以内しか予約登録／編集できません。" if in_two_months <= d_ed_at.to_date
            end
          end
          item.errors.add :st_at, 'と終了日時は一年以内でなければいけません。' if (d_ed_at - d_st_at) > 86400 * 365

        dates = (d_st_at.to_date..d_ed_at.to_date).to_a
        weekdays, holidays = Gw.extract_holidays(dates)
        if has_mr_pm > 0 && !is_pm_admin
          item.errors.add :st_at, "は、管財課会議室をご利用の場合、休日を含めることができません(該当日: #{holidays.collect{|x|Gw.date_str(x)}.join(' ')})。" if holidays.length > 0
          item.errors.add :st_at, '、終了日時が不正です。会議室の予約時、連続して５日以上予約することはできません。' if weekdays.length > 4
        end
        if has_mr_pm > 0 && !is_pm_admin
          hours = ((d_ed_at - d_st_at) / 3600) * has_mr_pm
          if hours > 9.5
            item.errors.add :"同一所属", "の予約制限に係る不正です。管財課管理の全会議室合計で１日９時間３０分までしか予約できません。" if !is_pm_admin
          else
            sche_props_has_og = Gw::Schedule.joins('inner join gw_schedule_props on gw_schedules.id = gw_schedule_props.schedule_id')
            sche_props_has_og = sche_props_has_og.where("schedule_id <> '#{item.id}' and owner_gid = #{ogid} and prop_type='#{Gw::PropMeetingroom}' and date(gw_schedule_props.ed_at) = '#{Gw.date_str(d_ed_at)}' and (#{prop_cancelled_cond})")
            pm_sche_has_og_secs = 0
            sche_props_has_og.each {|y|
              y.schedule_props.each {|x|
                if !x.prop.blank? && x.prop.extra_flag == 'pm'
                  pm_sche_has_og_secs += y.ed_at - y.st_at
                end
              }
            }
            pm_sche_has_og_secs += (d_ed_at - d_st_at) * has_mr_pm
            item.errors.add :"同一所属", "の予約制限に係る不正です。管財課管理の全会議室合計で１日９時間３０分までしか予約できません。" if pm_sche_has_og_secs / 3600 > 9.5 && !is_pm_admin
          end
        end
      end
    when "2"
      st_date, ed_date = par_item_repeat[:st_date_at], par_item_repeat[:ed_date_at]
      st_time, ed_time = par_item_repeat[:st_time_at], par_item_repeat[:ed_time_at]
      %w(st_date ed_date st_time ed_time).each {|fld|
        item.errors.add "repeat_#{fld}_at", 'が異常です' if !Gw.validates_datetime eval(fld)
      }

      if item.errors.size == err_num_st
        d_st_date, d_ed_date = Gw.get_parsed_date(st_date), Gw.get_parsed_date(ed_date)
        d_st_time, d_ed_time = Gw.get_parsed_date(st_time), Gw.get_parsed_date(ed_time)

        item.errors.add :repeat_ed_date_at, 'は、開始日より後の日付を入力してください。' if d_st_date >= d_ed_date
        if !prop_flg
          item.errors.add :repeat_ed_time_at, 'は、開始時刻以降の時刻を入力してください。' if d_st_time > d_ed_time
        else
          item.errors.add :repeat_ed_time_at, 'は、開始時刻より後の時刻を入力してください。' if d_st_time >= d_ed_time
        end

      end
      if item.errors.size == err_num_st

        if kanzai_flg
          item.errors.add :repeat_st_time_at, 'は、管財課利用の場合、15分単位でなくてはいけません。' if d_st_time.min % 15 != 0
          #item.errors.add :repeat_ed_time_at, 'からの利用時間は、管財課利用の場合、30分単位でなくてはいけません。' if (d_ed_time - d_st_time) % (30 * 60) != 0
          #(d_ed_at.to_time.to_i - d_st_at.to_time.to_i)
          item.errors.add :repeat_ed_time_at, 'からの利用時間は、管財課利用の場合、30分単位でなくてはいけません。' if (d_ed_time.to_time.to_i - d_st_time.to_time.to_i) % (30 * 60) != 0
        end
        if kanzai_flg && !is_pm_admin
          if !restrict_reservation_st.nil?
            item.errors.add :repeat_st_time_at,"・終了時刻は、管財課会議室を利用の場合、#{settings["restrict_regist_with_pm_reservation_time"]}の間しか予約登録/編集できません。" if !(restrict_reservation_st <= d_st_time && d_ed_time <= restrict_reservation_ed) && has_mr_pm > 0

            if (!(rentcar_restrict_reservation_st <= d_ed_time) || !(d_st_time <= rentcar_restrict_reservation_ed)) && has_rc_pm > 0
              item.errors.add :st_at,"・終了日時は、管財課レンタカーをご利用の場合、#{settings["restrict_regist_with_pm_rentcar_reservation_time"]}の時間帯を含む場合は0時から23時59分の時間帯も予約できますが、それ以外の時間は予約登録/編集できません。"
            end
          end
        end

        if kanzai_flg && !is_pm_admin
        else
          item.errors.add :repeat_st_time_at, 'と終了時刻は一年以内でなければいけません。' if (d_ed_date - d_st_date) > 86400 * 365
        end
        if par_item_repeat[:class_id].blank?
          item.errors.add :repeat_class_id, 'を入力してください。'
        elsif par_item_repeat[:class_id].to_s == "3" && par_item_repeat[:weekday_ids].blank?
          item.errors.add :repeat_weekday_ids, 'を入力してください。'
        else
          dates = (d_st_date.to_date..d_ed_date.to_date).to_a
          case par_item_repeat[:class_id].to_s
          when "2"
            dates = dates.select{|x| !%w(1 2 3 4 5).index(x.wday.to_s).nil?}
          when "3"
            dates = dates.select{|x| !par_item_repeat[:weekday_ids].split(':').index(x.wday.to_s).nil?}
          end
          rent_date = st_date
          rent_item = mee_item = mee_item = []
          mee_day = Time.now.strftime("%Y-%m-%d 00:00:00").to_date

          rent_item_flg = true
          mee_item_flg = true
          mr_items_flg = true

          mee_today_flg = false
          mee_spe_flg = false
          mee_p_flg = false
          mee_type_id = nil

          other_item_flg = true

          dateslen = dates.length

          prop_join = "inner join gw_schedule_props on gw_schedules.id = gw_schedule_props.schedule_id"

          dates.each {|rent_date|
            st_at = "#{rent_date} #{st_time}"
            ed_at = "#{rent_date} #{ed_time}"

            cond_results_shar = " and (extra_data is null or extra_data not like '%\"cancelled\":1%')" +
              " and (schedule_repeat_id <> '#{item.schedule_repeat_id}' or schedule_repeat_id is null)" +
              " and ( (gw_schedule_props.st_at <= '#{st_at}' and gw_schedule_props.ed_at > '#{st_at}' )" +
              " or (gw_schedule_props.st_at < '#{ed_at}' and gw_schedule_props.ed_at >= '#{ed_at}' )" +
              " or ('#{st_at}' <= gw_schedule_props.st_at and gw_schedule_props.st_at < '#{ed_at}') )"

            cond_actual_shar = " and (extra_data is null or extra_data not like '%\"cancelled\":1%')" +
              " and schedule_repeat_id = '#{item.schedule_repeat_id}'" +
              " and ( (gw_schedule_props.st_at <= '#{st_at}' and gw_schedule_props.ed_at > '#{st_at}' )" +
              " or (gw_schedule_props.st_at < '#{ed_at}' and gw_schedule_props.ed_at >= '#{ed_at}' )" +
              " or ('#{st_at}' <= gw_schedule_props.st_at and gw_schedule_props.st_at < '#{ed_at}') )"

            rc_pm_ids.each{|r_props_id|
              if rent_item_flg
                rent_item = Gw::Schedule.joins(prop_join).where("prop_type='#{Gw::PropRentcar}' and prop_id='#{r_props_id}'" + cond_results_shar)
                if rent_item.length > 0
                  rent_item_flg = false
                end
                rent_item_flg = false if options[:check_temporaries] && Gw::SchedulePropTemporary.where(tmp_cond_str,item.tmp_id, ed_at,st_at, "Gw::PropRentcar", r_props_id,tmp_time,current_time).exists?
                if !item.schedule_repeat_id.blank?
                  rent_item = Gw::Schedule.joins(prop_join).where("prop_type='#{Gw::PropRentcar}'" + cond_actual_shar)
                  rent_item.each { |ritem|
                    if ritem.is_actual?
                      rent_item_flg = false
                    end
                  }
                end
              end
            }

            mr_pm_ids.each{|m_props_id|

              if mee_item_flg
                mee_item = Gw::Schedule.joins(prop_join).where("prop_type='#{Gw::PropMeetingroom}' and prop_id='#{m_props_id}'" + cond_results_shar)
                if mee_item.length > 0
                  mee_item_flg = false
                end

                if !item.schedule_repeat_id.blank?
                  mee_item = Gw::Schedule.joins(prop_join).where("prop_type='#{Gw::PropMeetingroom}'" + cond_actual_shar)
                  mee_item.each { |mitem|
                    if mitem.is_actual?
                      mee_item_flg = false
                    end
                  }
                end
              end
              mee_today_item = Gw::PropMeetingroom.where(:id=> m_props_id).first
              mee_today_flg = true if mee_today_item.type_id == 3
              mee_spe_flg = true if mee_today_item.type_id == 4
              mee_type_id = mee_today_item.type_id

              mee_p_flg = true if par_item_base[:participant_nums_inner].to_i + par_item_base[:participant_nums_outer].to_i > mee_today_item.max_person.to_i

            }

            ot_ot_ids.each{|o_props_id|
              if other_item_flg
                other_item = Gw::Schedule.joins(prop_join).where("prop_type='#{Gw::PropOther}' and prop_id='#{o_props_id}'" + cond_results_shar)
                if other_item.length > 0
                  other_item_flg = false
                end
              end
            }

            rent_time_st = Gw.get_parsed_date(rent_date.to_s + ' ' + st_time.to_s)
            rent_time_ed = Gw.get_parsed_date(rent_date.to_s + ' ' + ed_time.to_s)
            rent_time_st_s = rent_time_st.strftime("%Y-%m-%d 00:00:00")
            rent_time_ed_s = rent_time_ed.strftime("%Y-%m-%d 00:00:00")

            if has_mr_pm > 0 && !is_pm_admin
              hours = ((rent_time_ed - rent_time_st) / 3600) * has_mr_pm
              if hours > 9.5
                item.errors.add :"同一所属", "の予約制限に係る不正です。管財課管理の全会議室合計で１日９時間３０分までしか予約できません。" if !is_pm_admin
              else
                pm_sche_has_og_secs_cond = "owner_gid = #{ogid} and prop_type='#{Gw::PropMeetingroom}' and date(gw_schedule_props.ed_at) = '#{rent_date}' and (#{prop_cancelled_cond})"
                pm_sche_has_og_secs_cond += " and (schedule_repeat_id <> #{item.schedule_repeat_id} or schedule_repeat_id is null)" if mode == :update
                sche_props_has_og = Gw::Schedule.joins('inner join gw_schedule_props on gw_schedules.id = gw_schedule_props.schedule_id')
                sche_props_has_og = sche_props_has_og.where(pm_sche_has_og_secs_cond)
                pm_sche_has_og_secs = 0
                sche_props_has_og.each {|y|
                  y.schedule_props.each {|x|
                    if !x.prop.blank? && x.prop.extra_flag == 'pm'
                      pm_sche_has_og_secs += y.ed_at - y.st_at
                    end
                  }
                }
                pm_sche_has_og_secs += ((rent_time_ed - rent_time_st) * has_mr_pm)
                item.errors.add :"同一所属", "の予約制限に係る不正です。管財課管理の全会議室合計で１日９時間３０分までしか予約できません。" if pm_sche_has_og_secs / 3600 > 9.5 && !is_pm_admin
              end
            end
          }
          if mee_item_flg
            case mee_type_id
            when 1
              item.errors.add :st_at,": 該当会議室をご利用の場合、６ヶ月以内しか予約登録／編集できません。" if in_six_months <= d_ed_date.to_date && !is_pm_admin && kanzai_flg
            when 2
              item.errors.add :st_at,": 該当会議室をご利用の場合、６ヶ月以内しか予約登録／編集できません。" if in_six_months <= d_ed_date.to_date && !is_pm_admin && kanzai_flg
            when 3
              item.errors.add :st_at,": 管財課レンタカー、管財課会議室をご利用の場合、２ヶ月以内しか予約登録／編集できません。" if in_two_months <= d_ed_date.to_date && !is_pm_admin && kanzai_flg
            when 4
              item.errors.add :st_at,": 該当会議室をご利用の場合、６ヶ月以内しか予約登録／編集できません。" if in_six_months <= d_ed_date.to_date && !is_pm_admin && kanzai_flg
            else
              item.errors.add :st_at,": 管財課レンタカー、管財課会議室をご利用の場合、２ヶ月以内しか予約登録／編集できません。" if in_two_months <= d_ed_date.to_date && !is_pm_admin && kanzai_flg
            end
          else
            item.errors.add :st_at,": 管財課レンタカー、管財課会議室をご利用の場合、２ヶ月以内しか予約登録／編集できません。" if in_two_months <= d_ed_date.to_date && !is_pm_admin && kanzai_flg
          end
          competition_str = "終了日は他の予定と競合しています。また、繰り返し編集の場合、同じ予定でもすでに貸出・返却されている日時を入力することはできません。別の予定時間を入力してください。"
          item.errors.add :repeat_st_date_at, "、#{competition_str}（レンタカー）" unless rent_item_flg
          item.errors.add :repeat_st_date_at, "、#{competition_str}（会議室）" unless mee_item_flg
          item.errors.add :repeat_st_date_at, "、#{competition_str}（一般施設）" unless other_item_flg
          item.errors.add :st_at, 'は、当日の会議室の予約のため、本日の日付を登録してください。' if mee_today_flg && (mee_day != st_date.to_date || ed_date.to_date != mee_day) && !is_pm_admin
          item.errors.add :"参加者","は、特別会議室を利用する際はひとつ以上にチェックを入れてください。" if mee_spe_flg && option_items.blank?
          item.errors.add :participant_nums_inner, '、参加人数(庁外) の合計人数が、会議室の収容人数を超えています。' if mee_p_flg && !is_pm_admin
          item.errors.add :repeat_ed_date_at, '、が不正です。会議室の予約時、連続して５日以上予約することはできません。' if has_mr_pm > 0 && dateslen > 4 && !is_pm_admin
          item.errors.add :st_at, 'は、2010年7月1日以降としてください。管財レンタカー、管財会議室の予約は2010年7月1日以降となります。' if kanzai_flg && !is_pm_admin && st_date.to_date < '2010-07-01 00:00:00'.to_date


          item.errors.add :repeat_st_time_at, ': 繰り返し回数は2～55回のみ許されます。' if dates.length < 2 || 55 < dates.length
          if has_mr_pm > 0 && !is_pm_admin
            weekdays, holidays = Gw.extract_holidays(dates)
            item.errors.add :st_at, "は、管財課会議室をご利用の場合、休日を含めることができません(該当日: #{holidays.collect{|x|Gw.date_str(x)}.join(' ')})。" if holidays.length > 0
          end
        end
      end
    end

    %w(title is_public).each{|x| item.errors.add x, 'を入力してください。' if par_item_base[x].blank?}

    if par_item_base[:inquire_to].blank?
      if params[:s_genre] == "other"
        unless is_gw_admin
          prop_type = nil
          prop_type = Gw::PropType.find_by(id: params[:type_id]) if params[:type_id].present?
          if prop_type && prop_type.restricted == 1
            item.errors.add :inquire_to, "は、管財課施設（会議室・レンタカー）、他所属管理施設、#{prop_type.name}を予約するときに必須となります。入力してください。"
          else
            unless other_admin_flg
              item.errors.add :inquire_to, "は、管財課施設（会議室・レンタカー）、他所属管理施設を予約するときに必須となります。入力してください。"
            end
          end
        end
      else
        if kanzai_flg
          if !is_pm_admin && !is_gw_admin
            item.errors.add :inquire_to, "は、管財課施設（会議室・レンタカー）、他所属管理施設を予約するときに必須となります。入力してください。"
          end
        end
      end
    end
    if has_mr_pm > 0
      err_num_st = item.errors.size
      item.errors.add :participant_nums_inner, 'を入力してください。' if par_item_base[:participant_nums_inner].blank?
      item.errors.add :participant_nums_outer, 'を入力してください。' if par_item_base[:participant_nums_outer].blank?
      if item.errors.size == err_num_st
        item.errors.add :participant_nums_inner, 'は数値で入力してください。' if !Gw.int?(par_item_base[:participant_nums_inner])
        item.errors.add :participant_nums_outer, 'は数値で入力してください。' if !Gw.int?(par_item_base[:participant_nums_outer])
      end
      if item.errors.size == err_num_st
        item.errors.add :participant_nums_inner, 'は0以上の整数で入力してください。' if par_item_base[:participant_nums_inner].to_i < 0
        item.errors.add :participant_nums_outer, 'は0以上の整数で入力してください。' if par_item_base[:participant_nums_outer].to_i < 0
      end
      if item.errors.size == err_num_st && par_item_base[:check_30_over].blank?
        item.errors.add :check_30_over, 'のチェックを確認してください。管財課会議室を使用するとき、庁外の人数が30人を超えた場合は、衛視室へ通知文書の提出が必要となります。' if par_item_base[:participant_nums_outer].to_i > 30
      end
    end

    if nz(par_item_base[:is_public],0).to_s != "1"
      _users = JSON.parse(params[:item][:schedule_users_json])
      _users.each do |_user|
        _uid = _user[1]
        _u = System::User.where(state: 'enabled', id: _uid, code: AppConfig.gw.schedule_pref_admin['pref_admin_code']).first
        if !_u.blank?
          item.errors.add_to_base '「全庁予定」が参加者として選択されているが，「公開（誰でも閲覧可）」となっていません。'
        end
      end
    end

    if kanzai_flg && !is_pm_admin
      item.errors.add :is_public, 'は管財課設備を利用の場合、公開しか選択できません。' if nz(par_item_base[:is_public],0).to_s != "1"
    end

    item.attributes = par_item_base.reject{|k,v|!%w(schedule_users_json schedule_props_json schedule_users public_groups public_groups_json schedule_props st_at_noprop ed_at_noprop event_week event_month event_word allday_radio_id allday_radio_id repeat_allday_radio_id form_kind_id todo_st_at_id todo_st_at_id todo_st_at_id todo_ed_at_id todo_repeat_time_id prop_id).index(k).nil?}

    par_item_repeat.delete :allday_radio_id
    return false if item.errors.size != 0
    cnt = 0


    repeat_schedule_parent_id = []
    _props = JSON.parse(params[:item][:schedule_props_json])

    if _props.length > 0

      delete_props = Array.new

      case params[:init][:repeat_mode]
      when "1"

        delete_props << item.schedule_prop if !item.schedule_prop.blank?

        _props.each do |prop|
          cnt == 0 ? _item = item : _item = Gw::Schedule.new
          Gw::Schedule.save_with_rels _item, params[:item], mode, prop, delete_props,
            {:restrict_trans=>1, :repeat_mode => params[:init][:repeat_mode],
              :is_pm_admin => is_pm_admin, :option_items => option_items} unless options[:validate]
          _item.errors.each{|x| item.errors.add x[0], x[1]} if item != _item
          params[:item]['schedule_parent_id'] = _item.id if params[:item]['schedule_parent_id'].blank?  # 管財が存在する場合、schedule_parent_idを記入。
          cnt = cnt + 1
        end
      when "2"
        _props.each do |prop|
          date_for_time = Time.local(2010,4,1)
          par_item_repeat[:st_time_at] = Gw.datetime_merge_to_day(date_for_time, d_st_time)
          par_item_repeat[:ed_time_at] = Gw.datetime_merge_to_day(date_for_time, d_ed_time)
          item_org = item
          date_cnt = 0
          begin
            item_next = nil
            transaction do
              case mode
              when :update
                schedule_repeat_id = item.repeat.id
                cnt == 0 ? item_repeat = Gw::ScheduleRepeat.where(:id=> schedule_repeat_id).first : item_repeat = Gw::ScheduleRepeat.new
                item_repeat.update_attributes!(par_item_repeat)
                if cnt == 0
                  repeat_items = Gw::Schedule.where("schedule_repeat_id=#{schedule_repeat_id}")
                  repeat_items.each { |repeat_item|
                    if !repeat_item.is_actual?
                      delete_props << repeat_item.schedule_prop if !repeat_item.schedule_prop.blank?
                      repeat_item.destroy
                    end
                  }
                end
                dates.each {|d|
                  par_item_base['schedule_parent_id'] = repeat_schedule_parent_id[date_cnt]

                  item_dup = par_item_base.dup.merge({
                    :st_at => Gw.datetime_merge_to_day(d, d_st_time),
                    :ed_at => Gw.datetime_merge_to_day(d, d_ed_time),
                    :schedule_repeat_id => item_repeat.id,
                  })

                  _item = Gw::Schedule.new
                  ret_swr = Gw::Schedule.save_with_rels _item, item_dup, mode, prop, delete_props,
                    {:restrict_trans=>1, :repeat_mode => params[:init][:repeat_mode],
                      :is_pm_admin => is_pm_admin, :option_items => option_items} unless options[:validate]
                  _item.errors.each{|x| item.errors.add x[0], x[1]} if item != _item
                  item_next = _item if item_next.nil?

                  raise if !ret_swr
                  if repeat_schedule_parent_id[date_cnt].blank?
                    repeat_schedule_parent_id[date_cnt] = _item.id
                  end

                  date_cnt = date_cnt + 1

                }
                item.update_attributes item_next.attributes
                item.id = item_next.id
              when :create
                item_repeat = Gw::ScheduleRepeat.new(par_item_repeat)
                item_repeat.save!

                dates.each {|d|
                  par_item_base['schedule_parent_id'] = repeat_schedule_parent_id[date_cnt]

                  item_dup = par_item_base.dup.merge({
                    :st_at => Gw.datetime_merge_to_day(d, d_st_time),
                    :ed_at => Gw.datetime_merge_to_day(d, d_ed_time),
                    :schedule_repeat_id => item_repeat.id,
                  })


                  _item = item.id.nil? ? item : Gw::Schedule.new
                  ret_swr = Gw::Schedule.save_with_rels _item, item_dup, mode, prop, [],
                    {:restrict_trans=>1, :repeat_mode => params[:init][:repeat_mode],
                      :is_pm_admin => is_pm_admin, :option_items => option_items} unless options[:validate]
                  _item.errors.each{|x| item.errors.add x[0], x[1]} if item != _item
                  repeat_schedule_parent_id[date_cnt] = _item.id if repeat_schedule_parent_id[date_cnt].blank?
                  raise Gw::ARTransError if !ret_swr
                  date_cnt = date_cnt + 1

                }
              end
            end
          rescue => e
            case e.class.to_s
            when 'ActiveRecord::RecordInvalid', 'Gw::ARTransError'
              if item != item_org
                item_with_errors = item
                item = item_org
                item_with_errors.errors.each{|x| item.errors.add x[0], x[1]}
              end
            else
              raise e
            end
            return false
          end
          cnt = cnt + 1
        end
      else
        raise Gw::ApplicationError, "指定がおかしいです(repeat_mode=#{params[:init][:repeat_mode]})"
      end
    elsif _props.length == 0
      case params[:init][:repeat_mode]
      when "1"
        Gw::Schedule.save_with_rels item, params[:item], mode, nil, [], :option_items => option_items unless options[:validate]
      when "2"
        date_for_time = Time.local(2010,4,1)
        par_item_repeat[:st_time_at] = Gw.datetime_merge_to_day(date_for_time, d_st_time)
        par_item_repeat[:ed_time_at] = Gw.datetime_merge_to_day(date_for_time, d_ed_time)

        item_org = item
        begin
          item_next = nil
          transaction do
            case mode
            when :update

              schedule_repeat_id = item.repeat.id
              item_repeat = Gw::ScheduleRepeat.where(:id=>schedule_repeat_id).first
              item_repeat.update_attributes!(par_item_repeat)

              repeat_items = Gw::Schedule.where("schedule_repeat_id=#{schedule_repeat_id}")
              repeat_items.each { |repeat_item|
                if nz(repeat_item.todo, 0) == 0
                  repeat_item.destroy
                elsif nz(repeat_item.todo, 0) == 1 && !repeat_item.schedule_todo.blank? && nz(repeat_item.schedule_todo.is_finished, 0) == 0
                  repeat_item.destroy
                end
              }
              dates.each {|d|
                schedule_todo_item = Gw::Schedule.where("todo = 1 and schedule_repeat_id=#{schedule_repeat_id} and st_at >= '#{d.to_s} 00:00:00' and st_at <= '#{d.to_s} 23:59:59'")
                item_dup = par_item_base.dup.merge({
                  :st_at => Gw.datetime_merge_to_day(d, d_st_time),
                  :ed_at => Gw.datetime_merge_to_day(d, d_ed_time),
                  :schedule_repeat_id => item_repeat.id,
                })
                _item = Gw::Schedule.new
                if schedule_todo_item.blank?
                  ret_swr = Gw::Schedule.save_with_rels _item, item_dup, mode, nil, [],
                    {:restrict_trans=>1, :repeat_mode => params[:init][:repeat_mode], :is_pm_admin => is_pm_admin} unless options[:validate]
                else
                  ret_swr = true
                end
                _item.errors.each{|x| item.errors.add x[0], x[1]} if item != _item
                item_next = _item if item_next.nil?
                raise if !ret_swr
              }

              item.update_attributes item_next.attributes
              item.id = item_next.id
            when :create
              item_repeat = Gw::ScheduleRepeat.new(par_item_repeat)
              item_repeat.save!
              dates.each {|d|
                item_dup = par_item_base.dup.merge({
                  :st_at => Gw.datetime_merge_to_day(d, d_st_time),
                  :ed_at => Gw.datetime_merge_to_day(d, d_ed_time),
                  :schedule_repeat_id => item_repeat.id,
                })
                _item = item.id.nil? ? item : Gw::Schedule.new
                ret_swr = Gw::Schedule.save_with_rels _item, item_dup, mode, nil, [],
                  {:restrict_trans=>1, :repeat_mode => params[:init][:repeat_mode], :is_pm_admin => is_pm_admin} unless options[:validate]
                _item.errors.each{|x| item.errors.add x[0], x[1]} if item != _item

                raise Gw::ARTransError if !ret_swr
              }
            end
          end
        rescue => e
          case e.class.to_s
          when 'ActiveRecord::RecordInvalid', 'Gw::ARTransError'
            if item != item_org
              item_with_errors = item
              item = item_org
              item_with_errors.errors.each{|x| item.errors.add x[0], x[1]}
            end
          else
            raise e
          end
          return false
        end
      else
        raise Gw::ApplicationError, "指定がおかしいです(repeat_mode=#{params[:init][:repeat_mode]})"
      end
    end

    if has_mr_pm > 0 && !is_pm_admin
      _mr_pm_item = Gw::Schedule.where("id=#{item.id}").first
      system_settings = AppConfig.gw.schedule_props_settings
      if !nf(system_settings[:add_memo_send_to_confirm]).blank?
        add_memo_send_to = system_settings[:add_memo_send_to_to_confirm]
        _mr_pm_item.schedule_props.each{|prop|
          uids = add_memo_send_to.to_s.split('-')
          uids.each{|uid|
            ret = Gw.add_memo(uid, '設備施設の承認要求が来ています。', %Q(<a href="/gw/schedules/#{item.id}/show_one">予約情報の確認</a><br/><a href="/gw/prop_extras/#{prop.id}/confirm">#{prop.prop.name}承認</a>), {:is_system => 1})
          }
        }
      end
    end
    return true
  end
end
