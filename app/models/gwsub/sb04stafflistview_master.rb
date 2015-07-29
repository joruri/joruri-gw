# -*- encoding: utf-8 -*-
class Gwsub::Sb04stafflistviewMaster < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  def self.find_uniqueness(_params, action = nil, id = nil, model = Gw::SectionAdminMaster)
    # 重複チェック
    cond_str = "management_uid_sb04 = ?"
    cond_str += " and state = 'enabled'"
    cond_str += " and func_name = 'gwsub_sb04'"
    cond_str += " and management_gid_sb04 = ?"
    cond_str += " and division_gid_sb04 = ?"
    cond_str += " and fyear_id_sb04 = ?"
    cond_str += " and id <> #{id}" if action == :update
    cond = [cond_str , _params[:management_uid_sb04],_params[:management_gid_sb04],_params[:division_gid_sb04],_params[:fyear_id_sb04],]

    _item = model.find(:first, :conditions => cond)

    if _item.blank?
      return true
    else
      return false
    end
  end

  def self.params_set(params)
    ret = ""
    'page:sort_keys:s_m_gid:s_d_gid:s_f_id:s_old_f_id'.split(':').each_with_index do |col, idx|
      unless params[col.to_sym].blank?
        ret += "&" unless ret.blank?
        ret += "#{col}=#{params[col.to_sym]}"
      end
    end
    ret = '?' + ret unless ret.blank?
    return ret
  end

  def self.get_division_sb04_gids(uid = Core.user.id, func_name = 'gwsub_sb04', options = {})
    items = Gw::SectionAdminMaster.new.find(:all, :conditions=>"state = 'enabled' and func_name = '#{func_name}' and range_class_id = 2 and management_uid=#{uid}",
      :order=>"fyear_id_sb04 DESC, division_gcode")

    division_sb04_gids  = Array.new
    if items.length > 0
      items.each do |item|
        fyear_id = item.fyear_id_sb04
        cond  = "user_id=#{uid} and end_at is null"
        group = System::UsersGroup.find(:first , :order=>"job_order,start_at desc" ,:conditions=>cond)
        if group.blank?
        else
          sections = Gwsub::Sb04section.find(:all,  :conditions=>"fyear_id = #{fyear_id} and ldap_code = '#{group.group_code}'")
          unless sections.empty?
            sections.each do |section|
              division_sb04_gids << section.id
            end
          end
        end
      end
    end
    items.each do |item|
      division_sb04_gids  << item.division_gid_sb04
    end
    return division_sb04_gids.uniq
  end

  def self.is_sb04_dev?
    items = self.get_division_sb04_gids
    if items.length > 0
      return true
    else
      return false
    end
  end

  def self.sb04_dev_fyear_select(uid = Core.user.id, options={})

    cond  = "state = 'enabled' and func_name = 'gwsub_sb04' and range_class_id = 2 and management_uid=#{uid}"
    fyear_ids = Gw::SectionAdminMaster.new.find(:all, :conditions=>cond, :order=>"fyear_id_sb04 DESC").collect{|x| x.fyear_id_sb04}

    fyear_ids = fyear_ids.uniq
    selects = []
    fyear_ids.each do |fyear_id|
      fyear = Gwsub::Sb04EditableDate.find_by_fyear_id(fyear_id)
      if !fyear.blank?
        selects << [fyear.fyear_markjp, fyear_id]
      end
    end
    return selects
  end

  def self.sb04_dev_group_select(fyear_id = 0, uid = Core.user.id, options={})

    gids = Array.new
    if fyear_id.to_i > 0
      cond  = "state = 'enabled' and func_name = 'gwsub_sb04' and range_class_id = 2 and management_uid=#{uid} and fyear_id_sb04 = #{fyear_id}"
      items = Gw::SectionAdminMaster.new.find(:all, :conditions=>cond, :order=>"fyear_id_sb04 DESC, division_gcode")
      items.each do |item|
        fyear_id = item.fyear_id_sb04
        sections = Gwsub::Sb04section.find(:all,  :conditions=>"fyear_id = #{fyear_id} and ldap_code = '#{Core.user_group.code}'")
        unless sections.empty?
          sections.each do |section|
            gids << section.id
          end
        end
        gids << item.division_gid_sb04 # 主管課対象
      end
    else
    end

    gids = gids.uniq
    selects = []

    gids.each do |gid|
      g = Gwsub::Sb04section.find_by_id(gid)
      if !g.blank?
        selects << [g.name, g.id]
      end
    end
    return selects
  end

  def self.is_sb04_dev_group_role(fyear_id = 0, division_gcode = 0, uid = Core.user.id, options={})
    # 指定した所属のidが、ログインユーザーの主管課の範囲にいるかどうか確認する
    # 返り値：true 存在する、false 存在しない
    cond  = "state = 'enabled' and func_name = 'gwsub_sb04' and range_class_id = 2 and management_uid=#{uid} and division_gcode = #{division_gcode} and fyear_id_sb04 = #{fyear_id}"
    items = Gw::SectionAdminMaster.new.find(:all, :conditions=>cond, :order=>"division_gcode")

    # 自所属かどうかの確認。
    sections = Gwsub::Sb04section.find(:all, :conditions=>"fyear_id = #{fyear_id} and ldap_code = '#{Core.user_group.code}' and code = '#{division_gcode}'")
    # 指定年度に、ユーザーが主管課を持っているか確認。持っていなければ、その年度の編集権限は無し。
    section_masters = Gw::SectionAdminMaster.new.find(:all, :conditions=>"state = 'enabled' and func_name = 'gwsub_sb04' and range_class_id = 2 and management_uid=#{uid} and fyear_id_sb04 = #{fyear_id}", :order=>"division_gcode")

    if items.length > 0 || (sections.length > 0 && section_masters.length > 0)
      return true
    else
      return false
    end
  end


  # sb04 職員名簿
  def self.set_sb04_section_select( fyear_id = nil , section_id = nil, uid = Core.user.id ,all=nil)
  # 職員名簿の所属から選択指定の設定
    section_selected = 0
    return section_selected if all=='all'
    unless section_id.to_i == 0
      # 指定のIDで存在チェック
      cond  = "state = 'enabled' and func_name = 'gwsub_sb04' and range_class_id = 2 and management_uid = #{uid} and division_gid_sb04 = #{section_id}"
      items = Gw::SectionAdminMaster.new.find(:first, :conditions=>cond, :order=>"division_gcode")
      section_selected = section_id  unless  items.blank?
      section_selected = 0           if      items.blank?
      return section_selected
    end
    if fyear_id.to_i  == 0
        sec = nil
    else
      find_cond  = "state = 'enabled' and func_name = 'gwsub_sb04' and range_class_id = 2 and management_uid=#{uid} and fyear_id_sb04 = #{fyear_id}"
      find_order = "division_gcode ASC"
      sec = Gw::SectionAdminMaster.new.find(:all, :conditions=>find_cond, :order=>find_order)
    end
    section_selected = 0             if  sec.blank?
    section_selected = sec[0].id unless  sec.blank?
    return section_selected
  end
end