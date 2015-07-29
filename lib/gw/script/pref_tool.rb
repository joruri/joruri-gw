# encoding: utf-8
class Gw::Script::PrefTool
  require 'csv'
  require 'pp'
  require 'yaml'

  def self.import_csv(input_csv, csv_setting_name,g_cat = nil)
    ret = ["",""]
    hash_raw = YAML.load_file('config/locales/csv_settings.yml')
    if csv_setting_name
      csv = []
      CSV.parse(input_csv) do |row|
        csv.push row
      end
      setting = hash_raw[csv_setting_name]
      raise TypeError, 'unknown csv_setting_name' if setting.nil?
      fields = setting['fields']
      csv_titles = csv[0]
      csv.shift
      users = []
      csv.each do |x|
        hxx = Hash.new
        fields.keys.each do |y|
          dump x
          dump y
          dump csv_titles
          idx = csv_titles.index(y)
          hxx["#{fields[y]}"] = "#{x[idx]}"
        end
        users << hxx
      end
      if  csv_setting_name == "gw_pref_executive_csv"
        ret = self.update_executives(users)
      else
        if g_cat=="all"
          ret = self.update_all_directors(users)
        else
         ret =  self.update_directors(users,g_cat)
        end

      end
    else
      raise TypeError, "不明な型です(#{hx.class})"
    end
    ret_no_user = ""
    ret_no_group_user=""
    unless ret[0].blank?
      ret_no_user = "以下のユーザーはユーザーのデータが存在しないため登録をスキップしました。<br />#{ret[0]}"
    end
    unless ret[1].blank?
      ret_no_group_user = "以下のユーザーはCSVの所属と実際の所属が異なっているため登録をスキップしました。<br />#{ret[1]}"
    end
    return "#{ret_no_user}#{ret_no_group_user}"
    #return ret
  end
  def self.user_select(u_code)
    p_user = System::User.find(:first,
      :conditions=>["code = ? AND state = 'enabled'",u_code])
   return p_user
  end

  def self.display_state(state)
    if state == "表示"
      return_state = 1
    else
      return_state =  nil
    end
    return return_state
  end


  def self.update_executives(users)
    ret_no_user = ""
    old_executives = Gw::PrefExecutive.find(:all,:conditions=>["deleted_at IS NULL"])
    old_executives.each_with_index{|old_user, y|
      use = 0
      users.each_with_index{|user, y|
        if old_user.u_code == user["u_code"] and old_user.title == user["title"]
          old_user_data = System::User.find_by_id(old_user.uid)
          if old_user_data.blank?
            ret_no_user += "#{user["u_code"]}#{user["u_name"]}<br />"
          else
            old_user.u_code           = old_user_data.code
            old_user_group_rel = System::UsersGroup.find(:first, :conditions=>["user_id = ? AND end_at IS NULL AND job_order = 0",old_user.uid])
            if old_user_group_rel.blank?
              old_user_group = nil
            else
              old_user_group = System::Group.find_by_id(old_user_group_rel.group_id)
            end
            unless old_user_group.blank?
              old_user.parent_gid       = old_user_group.parent.id
              old_user.parent_g_code    = old_user_group.parent.code
              old_user.parent_g_name    = old_user_group.parent.name
              old_user.parent_g_order   = old_user_group.parent.sort_no
              old_user.gid              = old_user_group.id
              old_user.g_code           = old_user_group.code
              old_user.g_name           = old_user_group.name
              old_user.g_order          = old_user_group.sort_no
            end
            old_user.u_name           = user["u_name"]
            old_user.is_governor_view = self.display_state(user["is_governor_view"])
            old_user.is_other_view    = self.display_state(user["is_other_view"])
            old_user.u_order          = user["u_order"]
            old_user.title            = user["title"]
            u_lname_up = false
            u_lname_up = true if user["title"] =~ /知事/
            u_lname_up = true if user["title"] =~ /副知事/
            u_lname_up = true if user["title"] =~ /政策監/
            old_user.u_lname        = user["title"]  if u_lname_up == true
            old_user.updated_at = Time.now
            old_user.save
            users.delete_at(y)
            use = 1
          end
        end
      }
      if use == 0
        old_user.deleted_at    = Time.now
        old_user.state         = "deleted"
        old_user.deleted_user  = Site.user.name
        old_user.deleted_group = Site.user_group.name
        old_user.save
      end
    }
    users.each_with_index{|user, y|
      new_user = Gw::PrefExecutive.new()
      new_user_data = self.user_select(user["u_code"])
      if new_user_data.blank?
        ret_no_user += "#{user["u_code"]}#{user["u_name"]}<br />"
      else
        new_user_group_rel = System::UsersGroup.find(:first, :conditions=>["user_id = ? AND end_at IS NULL AND job_order = 0",new_user_data.id])
        if new_user_group_rel.blank?
          new_user_group = nil
        else
          new_user_group = System::Group.find_by_id(new_user_group_rel.group_id)
        end
        unless new_user_group.blank?
          new_user.parent_gid       = new_user_group.parent.id
          new_user.parent_g_code    = new_user_group.parent.code
          new_user.parent_g_name    = new_user_group.parent.name
          new_user.parent_g_order   = new_user_group.parent.sort_no
          new_user.gid              = new_user_group.id
          new_user.g_code           = new_user_group.code
          new_user.g_name           = new_user_group.name
          new_user.g_order          = new_user_group.sort_no
        end
        new_user.u_code           = new_user_data.code
        old_title_user = Gw::PrefExecutive.find(:first, :conditions=>["uid = ?",new_user_data.id],:order=>"updated_at")
        if old_title_user.blank?
          old_state = "off"
        else
          if old_title_user.state == "on"
            old_state = "on"
          else
            old_state = "off"
          end
        end
        new_user.state = old_state
        new_user.u_name           = user["u_name"]
        new_user.is_governor_view = self.display_state(user["is_governor_view"])
        new_user.is_other_view = self.display_state(user["is_other_view"])
        new_user.uid        = new_user_data.id unless new_user_data.blank?
        new_user.u_order    = user["u_order"]
        new_user.title      = user["title"]
        u_lname_up = false
        u_lname_up = true if user["title"] =~ /知事/
        u_lname_up = true if user["title"] =~ /副知事/
        u_lname_up = true if user["title"] =~ /政策監/
        new_user.u_lname    = user["title"]  if u_lname_up == true
        #new_user.u_lname    = user[6]
        new_user.created_at = Time.now
        new_user.updated_at = Time.now
        new_user.save
      end
    }
    return [ret_no_user,""]
  end

  def self.update_directors(users,g_cat)
    ret_no_user = ""
    ret_no_group_user=""
    old_users = Gw::PrefDirector.find(:all, :conditions=>["parent_g_code = ? AND state != 'deleted' AND deleted_at IS NULL",g_cat])

    temp = System::Group.find(:first,:conditions=>["end_at IS NULL and code = ?",g_cat])
    return [ret_no_user,ret_no_group_user] if temp.blank?
    old_users.each_with_index{|old_user, x|
      use = 0
      users.each_with_index{|user, y|
        if old_user.u_code == user["u_code"] and old_user.title == user["title"]
          old_user_data = System::User.find_by_id(old_user.uid)
          if old_user_data.blank?
            ret_no_user += "#{user["u_code"]}#{user["u_name"]}<br />"
          else
            is_group_user = true
            old_user.u_code           = old_user_data.code
            old_user.u_name           = old_user_data.name
            old_user_group_rel = System::UsersGroup.find(:first, :conditions=>["user_id = ? AND end_at IS NULL AND job_order = 0",old_user.uid] ,:order=>"start_at DESC")
            if old_user_group_rel.blank?
              old_user_group = nil
            else
              old_user_group = System::Group.find_by_id(old_user_group_rel.group_id)
            end
            unless old_user_group.blank?
              if old_user_group.parent.id == temp.id
                is_group_user = true
              else
                is_group_user = false
              end

            old_user.parent_gid       = temp.id
            old_user.parent_g_code    = old_user_group.parent.code
            old_user.parent_g_name    = old_user_group.parent.name
            old_user.parent_g_order   = old_user_group.parent.sort_no
              old_user.gid              = old_user_group.id
              old_user.g_code           = old_user_group.code
              old_user.g_name           = old_user_group.name
              old_user.g_order          = old_user_group.sort_no
            end
            old_user.is_governor_view    = self.display_state(user["is_other_view"])
            old_user.u_name           = user["u_name"]
            old_user.u_order          = user["u_order"]
            old_user.title            = user["title"]
            u_lname_up = false
            u_lname_up = true if user["title"] =~ /知事/
            u_lname_up = true if user["title"] =~ /副知事/
            u_lname_up = true if user["title"] =~ /政策監/
            old_user.u_lname        = user["title"] if u_lname_up == true
            old_user.updated_at = Time.now
            if is_group_user==true
              old_user.save
              users.delete_at(y)
              use = 1
            else
              ret_no_group_user += "#{user["u_code"]}#{user["u_name"]}<br />"
            end
          end
        end
      }
      if use == 0
        old_user.deleted_at    = Time.now
        old_user.state         = "deleted"
        old_user.deleted_user  = Site.user.name
        old_user.deleted_group = Site.user_group.name
        old_user.save
      end
    }
    users.each_with_index{|user, y|

      new_user = Gw::PrefDirector.new()
      new_user_data = self.user_select(user["u_code"])
      if new_user_data.blank?
        ret_no_user += "#{user["u_code"]}#{user["u_name"]}<br />"
      else
        is_group_user = true
        new_user_group_rel = System::UsersGroup.find(:first, :conditions=>["user_id = ? AND end_at IS NULL AND job_order = 0",new_user_data.id])
        if new_user_group_rel.blank?
          new_user_group = nil
        else
          new_user_group = System::Group.find_by_id(new_user_group_rel.group_id)
        end

        unless new_user_group.blank?
          if new_user_group.parent.id == temp.id
            is_group_user = true
          else
            is_group_user = false
          end
          new_user.parent_gid       = temp.id
          new_user.parent_g_code    = temp.code
          new_user.parent_g_name    = temp.name
          new_user.parent_g_order   = temp.sort_no
          new_user.gid              = new_user_group.id
          new_user.g_code           = new_user_group.code
          new_user.g_name           = new_user_group.name
          new_user.g_order          = new_user_group.sort_no
        end
        new_user.u_code           = new_user_data.code
        new_user.u_name           = new_user_data.name
        old_title_user = Gw::PrefDirector.find(:first, :conditions=>["uid = ?",new_user_data.id],:order=>"updated_at")
        if old_title_user.blank?
          old_state = "off"
        else
          if old_title_user.state == "on"
            old_state = "on"
          else
            old_state = "off"
          end
        end
        new_user.state = old_state
        new_user.is_governor_view    = self.display_state(user["is_other_view"])
        new_user.u_name           = user["u_name"]
        new_user.uid        = new_user_data.id unless new_user_data.blank?
        new_user.u_order    = user["u_order"]
        new_user.title      = user["title"]
        u_lname_up = false
        u_lname_up = true if user["title"] =~ /知事/
        u_lname_up = true if user["title"] =~ /副知事/
        u_lname_up = true if user["title"] =~ /政策監/
        new_user.u_lname        = user["title"] if u_lname_up == true
        new_user.created_at = Time.now
        new_user.updated_at = Time.now
        if is_group_user==true
          new_user.save
        else
          ret_no_group_user += "#{user["u_code"]}#{user["u_name"]}<br />"
        end
      end
    }
    return [ret_no_user,ret_no_group_user]
  end

  def self.update_all_directors(users)
    ret_no_user = ""
    ret_no_group_user=""
    ret = ""
    old_users = Gw::PrefDirector.find(:all, :conditions=>"deleted_at IS NULL")
    old_users.each_with_index{|old_user, x|
      use = 0
      users.each_with_index{|user, y|
        if old_user.u_code == user["u_code"] and old_user.title == user["title"]
          old_user_data = System::User.find_by_id(old_user.uid)
          if old_user_data.blank?
            ret_no_user += "#{user["u_code"]}#{user["u_name"]}<br />"
          else
            is_group_user = true
            old_user.u_code           = old_user_data.code
            old_user_group_rel = System::UsersGroup.find(:first, :conditions=>["user_id = ? AND end_at IS NULL AND job_order = 0",old_user.uid],:order=>"start_at DESC")
            if old_user_group_rel.blank?
              old_user_group = nil
            else
              old_user_group = System::Group.find_by_id(old_user_group_rel.group_id)
            end
            unless old_user_group.blank?
              old_user.parent_gid       = old_user_group.parent.id
              old_user.parent_g_code    = old_user_group.parent.code
              old_user.parent_g_name    = old_user_group.parent.name
              old_user.parent_g_order   = old_user_group.parent.sort_no
              old_user.gid              = old_user_group.id
              old_user.g_code           = old_user_group.code
              old_user.g_name           = old_user_group.name
              old_user.g_order          = old_user_group.sort_no
            end
            old_user.is_governor_view    = self.display_state(user["is_other_view"])
            old_user.u_name           = user["u_name"]
            old_user.u_order          = user["u_order"]
            old_user.title            = user["title"]
            u_lname_up = false
            u_lname_up = true if user["title"] =~ /知事/
            u_lname_up = true if user["title"] =~ /副知事/
            u_lname_up = true if user["title"] =~ /政策監/
            old_user.u_lname        = user["title"] if u_lname_up == true
            old_user.updated_at = Time.now
            if is_group_user==true
              old_user.save
              users.delete_at(y)
              use = 1
            else
              ret_no_group_user += "#{user["u_code"]}#{user["u_name"]}<br />"
            end
          end
        end
      }
      if use == 0
        old_user.deleted_at    = Time.now
        old_user.state         = "deleted"
        old_user.deleted_user  = Site.user.name
        old_user.deleted_group = Site.user_group.name
        old_user.save
      end
    }
    users.each_with_index{|user, y|
      new_user = Gw::PrefDirector.new()
      new_user_data = self.user_select(user["u_code"])
      if new_user_data.blank?
        ret_no_user += "#{user["u_code"]}#{user["u_name"]}<br />"
      else
        is_group_user = true
        new_user_group_rel = System::UsersGroup.find(:first, :conditions=>["user_id = ? AND end_at IS NULL AND job_order = 0",new_user_data.id] ,:order=>"start_at DESC")
        if new_user_group_rel.blank?
          new_user_group = nil
        else
          new_user_group = System::Group.find_by_id(new_user_group_rel.group_id)
        end
        unless new_user_group.blank?
           new_user.parent_gid       = new_user_group.parent.id
           new_user.parent_g_code    = new_user_group.parent.code
           new_user.parent_g_name    = new_user_group.parent.name
           new_user.parent_g_order   = new_user_group.parent.sort_no
           new_user.gid              = new_user_group.id
           new_user.g_code           = new_user_group.code
           new_user.g_name           = new_user_group.name
           new_user.g_order          = new_user_group.sort_no
        end
        new_user.u_code           = new_user_data.code
        new_user.u_name           = new_user_data.name
        old_title_user = Gw::PrefDirector.find(:first, :conditions=>["uid = ?",new_user_data.id],:order=>"updated_at")
        if old_title_user.blank?
          old_state = "off"
        else
          if old_title_user.state == "on"
            old_state = "on"
          else
            old_state = "off"
          end
        end
        new_user.state = old_state
        new_user.is_governor_view    = self.display_state(user["is_other_view"])
        new_user.u_name           = user["u_name"]
        new_user.uid        = new_user_data.id unless new_user_data.blank?
        new_user.u_order    = user["u_order"]
        new_user.title      = user["title"]
        u_lname_up = false
        u_lname_up = true if user["title"] =~ /知事/
        u_lname_up = true if user["title"] =~ /副知事/
        u_lname_up = true if user["title"] =~ /政策監/
        new_user.u_lname        = user["title"] if u_lname_up == true
        new_user.created_at = Time.now
        new_user.updated_at = Time.now
        if is_group_user == true
          new_user.save
        else
          ret_no_group_user += "#{user["u_code"]}#{user["u_name"]}<br />"
        end
      end
    }
    return [ret_no_user,ret_no_group_user]
  end
end
