class System::LdapTemporary < ActiveRecord::Base
  include System::Model::Base

  def synchro_target?
    return true
  end

  def children
    tmp = self.class.new
    tmp.and :version, version
    tmp.and :parent_id, id
    tmp.and :data_type, 'group'
    return tmp.find(:all,:order=>"code")
  end

  def users
    tmp = self.class.new
    tmp.and :version, version
    tmp.and :parent_id, id
    tmp.and :data_type, 'user'
    return tmp.find(:all,:order=>"code")
  end

  def self.create_temporary(version = Time.now.to_i)
    results = {:group => 0, :user => 0, :gerr => 0, :uerr => 0}
    groups = Core.ldap.group.children

    sort_no = 0
    next_sort_no = Proc.new do
      sort_no += 10
    end

    groups.each do |d|
      next unless d.synchro_target?
      d_db = System::LdapTemporary.new({
        :parent_id => 0,
        :version   => version,
        :data_type => 'group',
        :code      => d.code,
        :sort_no   => next_sort_no.call,
        :name      => d.name,
        :name_en   => d.name_en,
        :email     => d.email,
        :group_s_name => d.group_s_name
      })

      if d_db.save
        results[:group] += 1
      else
        results[:gerr] += 1
      end

      d.children.each do |s|
        s_db = System::LdapTemporary.new({
          :parent_id => d_db.id,
          :version   => version,
          :data_type => 'group',
          :code      => s.code,
          :sort_no   => next_sort_no.call,
          :name      => s.name,
          :name_en   => s.name_en,
          :email     => s.email,
          :group_s_name => s.group_s_name
        })

        if s_db.save
          results[:group] += 1
        else
          results[:gerr] += 1
        end

        s.users.each do |u|
          u_db = System::LdapTemporary.new({
            :parent_id => s_db.id,
            :version   => version,
            :data_type => 'user',
            :code      => u.uid,
            :sort_no   => u.sort_no,
            :kana      => u.kana,
            :name      => u.name,
            :name_en   => u.name_en,
            :email     => u.email,
            :official_position => u.official_position,
            :assigned_job => u.assigned_job,
            :group_s_name => u.group_s_name
          })

          if u_db.save
            results[:user] += 1
          else
            results[:uerr] += 1
          end
        end
      end
    end

    return results
  end

  def self.synchronize(version)
    errors  = []

    tmp = System::LdapTemporary.new
    tmp.and :version, version
    tmp.and :parent_id, 0
    tmp.and :data_type, 'group'
    groups = tmp.find(:all, :order => :code)

    System::User.where("ldap = 1").update_all("ldap_version = NULL")
    System::Group.where("ldap = 1").update_all("ldap_version = NULL")
    System::GroupHistory.where("ldap = 1").update_all("ldap_version = NULL")

    group_sort_no = 0
    group_next_sort_no = Proc.new do
      group_sort_no = group_sort_no + 10
    end

    now = Core.now || Time.now

    groups.each do |d|
      group = System::Group.where(:parent_id => 1, :level_no => 2, :code => d.code).order(:code).first || System::Group.new
      group.parent_id    = 1
      group.state        = 'enabled'
      group.updated_at   = now
      group.name         = d.name
      group.name_en      = d.name_en
      group.email        = d.email
      group.level_no     = 2
      group.sort_no      = group_next_sort_no.call

      group.ldap_version = version
      group.group_s_name = d.group_s_name

      group.ldap         = 1
      group.code         = d.code
      group.version_id   = 0
      group.end_at       = nil
      group.start_at   ||= Date.today
      group.created_at ||= now

      if group.id
        errors << "group2-u : #{d.code}-#{d.name}" && next unless group.save
      else
        errors << "group2-n : #{d.code}-#{d.name}" && next unless group.save
      end

      d.children.each do |s|
        c_group = System::Group.where(:parent_id => group.id, :level_no => 3, :code => s.code).order(:code).first || System::Group.new
        c_group.parent_id    = group.id
        c_group.state        = 'enabled'
        c_group.updated_at   = now
        c_group.name         = s.name
        c_group.name_en      = s.name_en
        c_group.email        = s.email
        c_group.level_no     = 3
        c_group.sort_no      = group_next_sort_no.call

        c_group.ldap_version = version
        c_group.group_s_name = s.group_s_name

        c_group.ldap         = 1
        c_group.version_id   = 0
        c_group.code         = s.code.to_s
        c_group.end_at       = nil
        c_group.start_at   ||= Date.today
        c_group.created_at ||= now

        if c_group.id
          errors << "group3-u : #{s.code} - #{s.name}" && next unless c_group.save
        else
          errors << "group3-n : #{s.code} - #{s.name}" && next unless c_group.save
        end

        s.users.each do |u|
          user = System::User.where(:code => u.code).first || System::User.new
          user.updated_at   = now
          user.state        = 'enabled'
          user.ldap         = 1
          user.name         = u.name
          user.name_en      = u.name_en
          user.email        = u.email
          user.ldap_version = version
          user.code         = u.code
          user.sort_no      = u.sort_no
          user.kana         = u.kana
          user.group_s_name = u.group_s_name
          user.official_position  = u.official_position
          user.assigned_job       = u.assigned_job
          user.created_at ||= now
          user.auth_no    ||= 3

          user.in_group_id  = c_group.id

          if user.id
            errors << "user-u : #{u.code} - #{u.name}" && next unless user.save
          else
            errors << "user-n : #{u.code} - #{u.name}" && next unless user.save
          end

        end ##/users
      end ##/sections
    end ##/departments

    cond = "ldap = 1 AND ldap_version IS NULL"
    System::User.where(cond).update_all("state = 'disabled'")
    System::Group.where(cond).update_all("state = 'disabled'")
    System::Group.where(cond).update_all("end_at = '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'")
    System::GroupHistory.where(cond).update_all("state = 'disabled'")
    System::GroupHistory.where(cond).update_all("end_at = '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'")

    sql  = "UPDATE system_users_groups"
    sql += " INNER JOIN system_users ON system_users.id = system_users_groups.user_id"
    sql += " SET system_users_groups.end_at = '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    sql += " WHERE system_users.ldap = 1 AND system_users.ldap_version IS NULL AND system_users_groups.end_at IS NULL AND system_users_groups.job_order = 0"
    System::UsersGroup.connection.execute(sql)

    sql  = "UPDATE system_users_group_histories"
    sql += " INNER JOIN system_users ON system_users.id = system_users_group_histories.user_id"
    sql += " SET system_users_group_histories.end_at = '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    sql += " WHERE system_users.ldap = 1 AND system_users.ldap_version IS NULL AND system_users_group_histories.end_at IS NULL AND system_users_group_histories.job_order = 0"
    System::UsersGroupHistory.connection.execute(sql)

    System::User.where(cond).update_all("ldap = 0")
    System::Group.where(cond).update_all("ldap = 0")
    System::GroupHistory.where(cond).update_all("ldap = 0")

    Rails.cache.clear

    return errors
  end
end
