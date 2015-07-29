# -*- encoding: utf-8 -*-
class Gw::PrefAssemblyMember < Gw::Database
  include System::Model::Base
  include Cms::Model::Base::Content

  validates_presence_of :g_name, :g_order, :u_name,:u_lname, :u_order

  before_create :set_creator
  before_update :set_updator

	#議長レコードを抽出する。議長は g_order = 10 のレコード
	def self.get_chairman()
		self.where('deleted_at IS NULL AND g_order = 10')
	end

	#副議長レコードを抽出する。副議長は g_order = 20 のレコード
	def self.get_vicechairmen()
		self.where('deleted_at IS NULL AND g_order = 20')
	end

	#議員一覧を抽出する。議員は g_order > 20 のレコード
	def self.get_members()
		self.where('deleted_at IS NULL AND g_order > 20')
	end

	#
	#在庁フラグをON/OFF切り替える。
	# ==== Parameters
	# * + id -対象レコードid
	# * + state -指定のフラグ値('on', 'off')。指定しない場合は現在の状態を反転させる。
	#
	def self.state_change(id, state=nil)
		rc = self.find(id)
		raise "Not Found@PrefAssemblyMember::state_change" unless rc
		
		if state
			states = ['on','off']

			case state.downcase
			when *states
				rc.update_attribute(:state, state)
			else
				#'on','off'以外は'off'にして例外をスローする
				rc.update_attribute(:state, 'off')
				raise "Invalid Parameter@PrefAssemblyMember::state_change"
			end
		else
			#現在の状態の反転
			rc.update_attribute(:state, rc.state == 'on' ? 'off' : 'on')
		end
		return rc
	end
	
  def self.editable?(uid = Site.user.id)
    return true if self.is_admin?(uid) == true
    return true if self.is_dev?(uid) == true
    return false
  end

  def self.is_admin?( uid = Site.user.id )
    is_admin = System::Model::Role.get(1, uid ,'gw_pref_assembly', 'admin')
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
    self.created_user   = Site.user.name unless Site.user.blank?
    self.created_group  = Site.user_group.id unless Site.user.blank?
  end

  def set_updator
    self.updated_at     = Time.now
    self.updated_user   = Site.user.name unless Site.user.blank?
    self.updated_group  = Site.user_group.id unless Site.user.blank?
  end

  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `gw_pref_assembly_members` ;"
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
