# -*- encoding: utf-8 -*-
class Gw::PrefDirector < Gw::Database
  include System::Model::Base
  include Cms::Model::Base::Content

  before_create :set_creator
  before_update :set_updator

	def self.get_members()
		rs = self.where('deleted_at IS NULL')
		return rs
	end
	
	#
	#在庁フラグをON/OFF切り替える。
	# ==== Parameters
	# * + id -対象レコードid
	# * + state -指定のフラグ値('on', 'off')。指定しない場合は現在の状態を反転させる。
	#
	def self.state_change(uid, state=nil)
		ids = self.where(:uid => uid)
		raise "Not Found@PrefDirector::state_change" unless ids
		
		rc = self.find(ids[0])
		current_state = rc.state
		
		if state
			states = ['on','off']

			case state.downcase
			when *states
				self.update_all(ids, :state => state)

			else
				#'on','off'以外は'off'にして例外をスローする
				self.update_all(ids, :state => 'off')
				raise "Invalid Parameter@PrefDirector::state_change"
			end
			new_state = state
		else
			#現在の状態の反転
			new_state = current_state == 'on' ? 'off' : 'on'
			self.update_all(['state = ?', new_state], ['uid = ?', uid])
		end

		#同じ状態を同アカウントの幹部オブジェクトに送る
    Gw::PrefExecutive.update_all(['state = ?', new_state], ['uid = ?', uid])
		return self.select(:uid => uid)
	end

  def save_with_rels(params, mode, options={})
    users = ::JsonParser.new.parse(params[:item]['schedule_users_json'])

    users.each_with_index {|user, i|
      if user[0].blank? || user[0] == "0"
        num = "0"
      else
        num = user[0]
      end
      if params["sort_no_#{user[1]}_#{num}"].blank?
        params["sort_no_#{user[1]}_#{num}"] = 0
      elsif /^[0-9]+$/ =~ params["sort_no_#{user[1]}_#{num}"] && params["sort_no_#{user[1]}_#{num}"].to_i >= 0 && params["sort_no_#{user[1]}_#{num}"].to_i <= 9999
      else
        self.errors.add :"関連ユーザーの並び順", "を確認してください。"
        break
      end
    }
    users.each_with_index {|user, i|
      if user[0].blank? || user[0] == "0"
        num = "0"
      else
        num = user[0]
      end
      if params["title_#{user[1]}_#{num}"].blank?
        self.errors.add :"関連ユーザーの役職", "を入力してください。"
        break
      end
    }
    
    if self.errors.size > 0
      return false
    else
      users.each_with_index {|user, i|
        if user[0].blank? || user[0] == "0"
          num = "0"
        else
          num = user[0]
        end
        users[i][3] = params["title_#{user[1]}_#{num}"]
        users[i][5] = params["sort_no_#{user[1]}_#{num}"]
        users[i][6] = params["is_governor_view_#{user[1]}_#{num}"]
      }
      old_users = Gw::PrefDirector.find(:all, :conditions=>["parent_g_order = ? AND state != 'deleted' AND deleted_at IS NULL", params[:g_cat]])
      temp = old_users[0]
      old_users.each_with_index{|old_user, x|
        use = 0
        users.each_with_index{|user, y|
          if old_user.uid.to_i == user[1].to_i and old_user.title == user[3]
            old_user_data = System::User.find_by_id(old_user.uid)
            unless old_user_data.blank?
              old_user.u_code           = old_user_data.code
              old_user.u_name           = old_user_data.name
              old_user_group_rel = System::UsersGroup.find(:first, :conditions=>["user_id = ? AND end_at IS NULL AND job_order = 0",old_user.uid])
              if old_user_group_rel.blank?
                old_user_group = nil
              else
                old_user_group = System::Group.find_by_id(old_user_group_rel.group_id)
              end
              unless old_user_group.blank?
                old_user.parent_gid       = temp.parent_gid
                old_user.parent_g_code    = temp.parent_g_code
                old_user.parent_g_name    = temp.parent_g_name
                old_user.parent_g_order   = temp.parent_g_order
                old_user.gid              = old_user_group.id
                old_user.g_code           = old_user_group.code
                old_user.g_name           = old_user_group.name
                old_user.g_order          = old_user_group.sort_no
              end
            end
            old_user.is_governor_view = user[6]
            old_user.u_order    = user[5]
            old_user.title      = user[3]
            if user[3] == "知事" or user[3] == "副知事" or user[3] == "政策監" or user[3] == "政策監補"
              old_user.u_lname    = user[3]
            end
            old_user.updated_at = Time.now
            old_user.save
            users.delete_at(y)
            use = 1
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
        new_user_data = System::User.find_by_id(user[1])
        unless new_user_data.blank?
          new_user_group_rel = System::UsersGroup.find(:first, :conditions=>["user_id = ? AND end_at IS NULL AND job_order = 0",user[1]])
          if new_user_group_rel.blank?
            new_user_group = nil
          else
            new_user_group = System::Group.find_by_id(new_user_group_rel.group_id)
          end
          unless new_user_group.blank?
            new_user.parent_gid       = temp.parent_gid
            new_user.parent_g_code    = temp.parent_g_code
            new_user.parent_g_name    = temp.parent_g_name
            new_user.parent_g_order   = temp.parent_g_order
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
        end
        new_user.is_governor_view = user[6]
        new_user.uid        = user[1]
        new_user.u_order    = user[5]
        new_user.title      = user[3]
        if user[3] == "知事" or user[3] == "副知事" or user[3] == "政策監" or user[3] == "政策監補"
          new_user.u_lname    = user[3]
        end

        new_user.created_at = Time.now
        new_user.updated_at = Time.now
        new_user.save
      }
      return true
    end
  end


  def self.editable?(uid = Site.user.id)
    return true if self.is_admin?(uid) == true
    return true if self.is_dev?(uid) == true
    return false
  end

  def self.is_admin?( uid = Site.user.id )
    is_admin = System::Model::Role.get(1, uid ,'gw_pref_director', 'admin')
    return true if is_admin == true
    gw_admin = System::Model::Role.get(1, uid ,'_admin', 'admin')
    return true if gw_admin == true
    return false
  end

  def self.is_dev?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'gwsub', 'developer')
  end

  def set_creator
    self.created_at     = Time.now
    self.created_user   = Site.user.name              unless Site.user.blank?
    self.created_group  = Site.user.groups[0].ou_name unless (Site.user.blank? or Site.user_group.blank?)
  end

  def set_updator
    self.updated_at     = Time.now
    self.updated_user   = Site.user.name              unless Site.user.blank?
    self.updated_group  = Site.user.groups[0].ou_name unless (Site.user.blank? or Site.user_group.blank?)
  end

  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `gw_pref_directors` ;"
    connect.execute(truncate_query)
  end

  def self.state_select
    states = [['在席','on'],['不在','off']]
    return states
  end

  def self.state_show(state)
    states = [['on','在席'],['off','不在']]
    show = states.assoc(state)
    return show[1] unless show.blank?
    return ''
  end
end
