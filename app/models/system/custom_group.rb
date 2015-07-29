# encoding: utf-8
class System::CustomGroup < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Tree
  include System::Model::Base::Config

  belongs_to :status,     :foreign_key => :state,     :class_name => 'System::Base::Status'
  belongs_to :parent,     :foreign_key => :parent_id, :class_name => 'System::CustomGroup'
  has_many   :children ,  :foreign_key => :parent_id, :class_name => 'System::CustomGroup'
  has_many   :user_custom_group, :foreign_key => :custom_group_id,  :class_name => 'System::UsersCustomGroup'
  has_many   :custom_group_role, :foreign_key => :custom_group_id, :class_name => 'System::CustomGroupRole'
  belongs_to :owner_group, :foreign_key => :owner_gid, :class_name => 'System::Group'
  belongs_to :updater, :foreign_key => :updater_uid, :class_name => 'System::User'

  validates_presence_of :state, :name

  def save_with_rels(params, mode, options={})

      if mode == :create && Gw.is_admin_admin? != true
        temp = System::CustomGroup.find(:all, :conditions=>"owner_uid=#{Site.user.id}")
        if temp.size >= 5
          self.errors.add :base, "カスタムグループは5件までしか作成できません。"
        end
      end

      if params[:item][:sort_no].blank?
        params[:item][:sort_no] = 0
      elsif /^[0-9]+$/ =~ params[:item][:sort_no] && params[:item][:sort_no].to_i >= 0 && params[:item][:sort_no].to_i <= 9999
      else
          self.errors.add :sort_no, "は数値を入力してください。"
      end

      users = ::JsonParser.new.parse(params[:item]['schedule_users_json'])
      users.each_with_index {|user, i|
        if params["sort_no_#{user[1]}"].blank?
          params["sort_no_#{user[1]}"] = 0
        elsif /^[0-9]+$/ =~ params["sort_no_#{user[1]}"] && params["sort_no_#{user[1]}"].to_i >= 0 && params["sort_no_#{user[1]}"].to_i <= 9999
        else
          self.errors.add :base, "関連ユーザーの並び順 は数値を入力してください。"
          break
        end
      }

      self.state   = params[:item][:state]
      self.name    = params[:item][:name]
      self.name_en = params[:item][:name_en]
      if mode == :create
        self.sort_prefix = ( Gw.is_admin_admin? ? '' : Site.user.code )
      end
      self.sort_no = params[:item][:sort_no]
      self.class_id = 1
      self.owner_uid = Site.user.id if mode == :create
      self.owner_gid = Site.user.groups[0].id if mode == :create
      self.updater_uid = Site.user.id
      self.updater_gid = Site.user.groups[0].id

      self.is_default = (params[:item][:is_default].blank? ? 0 : params[:item][:is_default] )

      validation = nz(options[:validation], true)

      if self.errors.size == 0 && self.editable? && self.save(:validate => validation)
        cgid = self.id

        admin_users = ::JsonParser.new.parse(params[:item]['schedule_admin_users_json'])
        old_admin_users = System::CustomGroupRole.find(:all, :conditions=>"custom_group_id = #{cgid} and priv_name = 'admin' and class_id = 1")
        old_admin_users.each_with_index{|old_admin_user, x|
          use = 0
          admin_users.each_with_index{|admin_user, y|
            if old_admin_user.group_id.to_s == admin_user[1].to_s
                admin_users.delete_at(y)
                use = 1
            end
          }
          if use == 0
            old_admin_user.destroy
          end
        }
        admin_users.each_with_index{|admin_user, y|
          new_admin_user = System::CustomGroupRole.new()
          new_admin_user.user_id = admin_user[1]
          new_admin_user.custom_group_id = cgid
          new_admin_user.priv_name = 'admin'
          new_admin_user.class_id  = 1
          new_admin_user.created_at = 'now()'
          new_admin_user.updated_at = 'now()'
          new_admin_user.save
        }

        admin_groups = ::JsonParser.new.parse(params[:item]['schedule_admin_groups_json'])
        old_admin_groups = System::CustomGroupRole.find(:all, :conditions=>"custom_group_id = #{cgid} and priv_name = 'admin' and class_id = 2 ")
        old_admin_groups.each_with_index{|old_admin_group, x|
          use = 0
          admin_groups.each_with_index{|admin_group, y|
            if old_admin_group.group_id.to_s == admin_group[1].to_s
                admin_groups.delete_at(y)
                use = 1
            end
          }
          if use == 0
            old_admin_group.destroy
          end
        }
        admin_groups.each_with_index{|admin_group, y|
          new_admin_group = System::CustomGroupRole.new()
          new_admin_group.group_id = admin_group[1]
          new_admin_group.custom_group_id = cgid
          new_admin_group.priv_name = 'admin'
          new_admin_group.class_id  = 2
          new_admin_group.created_at = 'now()'
          new_admin_group.updated_at = 'now()'
          new_admin_group.save
        }

        edit_users = ::JsonParser.new.parse(params[:item]['schedule_edit_users_json'])
        old_edit_users = System::CustomGroupRole.find(:all, :conditions=>"custom_group_id = #{cgid} and priv_name = 'edit' and class_id = 1")
        old_edit_users.each_with_index{|old_edit_user, x|
          use = 0
          edit_users.each_with_index{|edit_user, y|
            if old_edit_user.group_id.to_s == edit_user[1].to_s
                edit_users.delete_at(y)
                use = 1
            end
          }
          if use == 0
            old_edit_user.destroy
          end
        }
        edit_users.each_with_index{|edit_user, y|
          new_edit_user = System::CustomGroupRole.new()
          new_edit_user.user_id = edit_user[1]
          new_edit_user.custom_group_id = cgid
          new_edit_user.priv_name = 'edit'
          new_edit_user.class_id  = 1
          new_edit_user.created_at = 'now()'
          new_edit_user.updated_at = 'now()'
          new_edit_user.save
        }

        edit_roles = ::JsonParser.new.parse(params[:item]['schedule_edit_roles_json'])
        old_edit_roles = System::CustomGroupRole.find(:all, :conditions=>"custom_group_id = #{cgid} and priv_name = 'edit' and class_id = 2 ")
        old_edit_roles.each_with_index{|old_edit_role, x|
          use = 0
          edit_roles.each_with_index{|edit_role, y|
            if old_edit_role.group_id.to_s == edit_role[1].to_s
                edit_roles.delete_at(y)
                use = 1
            end
          }
          if use == 0
            old_edit_role.destroy
          end
        }
        edit_roles.each_with_index{|edit_role, y|
          new_edit_role = System::CustomGroupRole.new()
          new_edit_role.group_id = edit_role[1]
          new_edit_role.custom_group_id = cgid
          new_edit_role.priv_name = 'edit'
          new_edit_role.class_id  = 2
          new_edit_role.created_at = 'now()'
          new_edit_role.updated_at = 'now()'
          new_edit_role.save
        }

        roles = ::JsonParser.new.parse(params[:item]['schedule_roles_json'])
        old_roles = System::CustomGroupRole.find(:all, :conditions=>"custom_group_id = #{cgid} and priv_name = 'read' and class_id = 2 ")
        old_roles.each_with_index{|old_role, x|
          use = 0
          roles.each_with_index{|role, y|
            if old_role.group_id.to_s == role[1].to_s
                roles.delete_at(y)
                use = 1
            end
          }
          if use == 0
            old_role.destroy
          end
        }
        roles.each_with_index{|role, y|
          new_role = System::CustomGroupRole.new()
          new_role.group_id = role[1]
          new_role.custom_group_id = cgid
          new_role.priv_name = 'read'
          new_role.class_id  = 2
          new_role.created_at = 'now()'
          new_role.updated_at = 'now()'
          new_role.save
        }

        read_users = ::JsonParser.new.parse(params[:item]['schedule_read_users_json'])
        old_read_users = System::CustomGroupRole.find(:all, :conditions=>"custom_group_id = #{cgid} and priv_name = 'read' and class_id = 1")
        old_read_users.each_with_index{|old_read_user, x|
          use = 0
          read_users.each_with_index{|read_user, y|
            if old_read_user.group_id.to_s == read_user[1].to_s
                read_users.delete_at(y)
                use = 1
            end
          }
          if use == 0
            old_read_user.destroy
          end
        }
        read_users.each_with_index{|read_user, y|
          new_read_user = System::CustomGroupRole.new()
          new_read_user.user_id = read_user[1]
          new_read_user.custom_group_id = cgid
          new_read_user.priv_name = 'read'
          new_read_user.class_id  = 1
          new_read_user.created_at = 'now()'
          new_read_user.updated_at = 'now()'
          new_read_user.save
        }

        users = ::JsonParser.new.parse(params[:item]['schedule_users_json'])
        users.each_with_index {|user, i|
          users[i][3] = params["title_#{user[1]}"]
          users[i][4] = params["icon_#{user[1]}"]
          users[i][5] = params["sort_no_#{user[1]}"]
        }
        old_users = System::UsersCustomGroup.find(:all, :conditions=>"custom_group_id= #{cgid}")
        old_users.each_with_index{|old_user, x|
          use = 0
          users.each_with_index{|user, y|
            if old_user.user_id.to_s == user[1].to_s
              old_user.sort_no    = user[5]
              old_user.title      = user[3]
              old_user.icon       = user[4]
              old_user.updated_at = 'now()'
              old_user.save
              users.delete_at(y)
              use = 1
            end
          }
          if use == 0
            old_user.destroy
          end
        }
        users.each_with_index{|user, y|
          new_user = System::UsersCustomGroup.new()
          new_user.custom_group_id = cgid
          new_user.user_id    = user[1]
          new_user.sort_no    = user[5]
          new_user.title      = user[3]
          new_user.icon   = user[4]
          new_user.created_at = 'now()'
          new_user.updated_at = 'now()'
          new_user.save
        }
      end

  end

  def self.get_my_view(options={})
    cond= " system_custom_groups.state = 'enabled' "
    cond+= " AND ( " +
      "(system_custom_group_roles.class_id = 2 AND ( system_custom_group_roles.group_id = #{Site.user_group.id}) OR system_custom_group_roles.group_id = 0 )" +
      " OR (system_custom_group_roles.class_id = 1 AND system_custom_group_roles.user_id = #{Site.user.id}) )"
    if options[:priv] == :edit
      cond+= " AND system_custom_group_roles.priv_name = 'edit' "
    else
      cond+= " AND system_custom_group_roles.priv_name = 'read' "
    end
    if options[:is_default] == 1
      cond+= " AND system_custom_groups.is_default = 1 " +
              " AND system_custom_groups.name = #{ActiveRecord::Base.send(:sanitize_sql_array, ["?", Site.user.groups[0].name])}"
    end
    unless options[:sort_prefix].blank?
      cond+= " AND system_custom_groups.sort_prefix = '#{options[:sort_prefix]}'"
    end
    row_option = :all
    if options[:first] == 1
      row_option = :first
    end
    select = "distinct id, parent_id, owner_uid, owner_gid, state, name, name_en, sort_no, sort_prefix, is_default"
    self.find( row_option,  :select => select,
      :order => 'system_custom_groups.sort_prefix, system_custom_groups.sort_no',
      :joins => [:custom_group_role], :conditions => cond
    )
  end

  def self.get_user_select(options={})
    selects = []
    selects << ['すべて',0] if options[:all]=='all'
    glist = System::CustomGroup.get_my_view( { :priv => :edit, :is_default => 1 } )
    glist.each {|x|
      x.user_custom_group.sort{|a,b| a.sort_no <=> b.sort_no }.each{|x|
        selects.push [Gw.trim( x.user.display_name ),  x.user.id]
      }
    }
    return selects
  end

  def self.schedule_get_user_select(options={})
    selects = []
    selects << ['すべて',0] if options[:all]=='all'
    glist = System::CustomGroup.get_my_view( { :priv => :edit, :is_default => 1 } )
    glist.each {|x|
      x.user_custom_group.sort{|a,b| a.sort_no <=> b.sort_no }.each{|x|
        if !x.user.blank? && x.user.state == 'enabled'
          selects.push [Gw.trim( x.user.display_name ),  x.user.id]
        end
      }
    }
    return selects
  end

  def self.create_new_custom_group(custom_group, group, customGroup_sort_no, mode)
    custom_group.name        = group.name
    custom_group.state       = 'enabled'
    custom_group.sort_no     = customGroup_sort_no
    custom_group.sort_prefix = ''
    custom_group.is_default  = 1
    custom_group.updater_uid = Site.user.id
    custom_group.updater_gid = Site.user_group.id
    custom_group.name_en     = 'sectionSchedules'
    custom_group.save(:validate => false)

    custom_group_id = custom_group.id

    if mode == :update
      custom_group.user_custom_group.each do |custom_user|
        custom_user.destroy
      end
      custom_group.custom_group_role.each do |custom_role|
        custom_role.destroy
      end
    end

    custom_group_admin = System::CustomGroupRole.new
    custom_group_admin.group_id         = group.id
    custom_group_admin.custom_group_id  = custom_group_id
    custom_group_admin.priv_name        = 'admin'
    custom_group_admin.class_id         = 2
    custom_group_admin.save(:validate => false)

    if !group.parent_id.blank? && !group.parent.blank?
      group.parent.children.each do |child|
        custom_group_edit = System::CustomGroupRole.new
        custom_group_edit.group_id         = child.id
        custom_group_edit.custom_group_id  = custom_group_id
        custom_group_edit.priv_name        = 'edit'
        custom_group_edit.class_id         = 2
        custom_group_edit.save(:validate => false)

        custom_group_read = System::CustomGroupRole.new
        custom_group_read.group_id         = child.id
        custom_group_read.custom_group_id  = custom_group_id
        custom_group_read.priv_name        = 'read'
        custom_group_read.class_id         = 2
        custom_group_read.save(:validate => false)
      end
    end

    custom_group_users = Array.new

    bu_user = nil
    if group.parent_id > 0
      parent_group = System::Group.find_by_id(group.parent_id)
      unless parent_group.blank?
        bu_user_code = parent_group.code.to_s
        bu_user_code = bu_user_code.to_s + "_0"
        bu_user = System::User.find(:first, :conditions=>["code = ? and state = ?", bu_user_code,'enabled'] )
      end
    end
    custom_group_users << bu_user unless bu_user.blank?

    ka_user_code = group.code.to_s + "_0"
    ka_user = System::User.find(:first, :conditions=>["code = ? and state = ?", ka_user_code,'enabled'])
    custom_group_users << ka_user unless ka_user.blank?

    user_ids = Array.new
    _ka_user_code = "#{group.code}0"
    group.user_group.each do |user_group|
      user_ids << user_group.user_id if !user_group.blank? && user_group.user_code != _ka_user_code
    end

    users = Array.new
    unless user_ids.empty?
      user_ids_str = Gw.join(user_ids, ',')
      users = System::User.find(:all, :conditions=>"id in (#{user_ids_str}) and state = 'enabled'", :order => 'sort_no, code')
    end

    users.each do |user|
      custom_group_users << user
    end

    custom_group_users.each_with_index do |custom_user, i|
      unless custom_user.blank?
        users_custom_group = System::UsersCustomGroup.new
        users_custom_group.user_id          = custom_user.id
        users_custom_group.sort_no          = i * 5
        users_custom_group.custom_group_id  = custom_group_id

        case custom_user.code
        when /^\w{3}_0/

          users_custom_group.title_en          = 'department'
          users_custom_group.icon             = 8
        when /^\w{6}_0/

          users_custom_group.title_en          = 'section'
          users_custom_group.icon             = 7
        else
          users_custom_group.title            = custom_user.official_position
          users_custom_group.icon             = 1
        end
        users_custom_group.save(:validate => false)
      end
    end
    return true
  end

  def self.get_error_users(params)
    users = []
    _users = ::JsonParser.new.parse(params[:item]['schedule_users_json'])
    _users.each_with_index {|_user, i|
      users[i] = [nil, _user[1], _user[2], params["title_#{_user[1]}"], params["icon_#{_user[1]}"], params["sort_no_#{_user[1]}"]]
    }
    return users
  end

  def self.states
    [['無効', 'disabled'], ['有効', 'enabled']]
  end
end
