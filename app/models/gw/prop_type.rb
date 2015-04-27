class Gw::PropType < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  has_many :prop_messages, :foreign_key => :type_id, :class_name => 'Gw::PropTypesMessage'
  has_many :prop_users, :foreign_key => :type_id, :class_name => 'Gw::PropTypesUser'

  validates :name, :sort_no, presence: true

  def self.gw_restricted_form_kind
    [['設備予約', '1' ]]
  end

  def self.is_public_select
    [['公開（誰でも閲覧）', 1]]
  end

  def restricted_select
    [["制限しない", 0], ["制限する", 1]]
  end

  def restricted_show
    restricted_select.each{|a| return a[0] if a[1] == restricted}
  end

  def restricted?
    restricted == 1
  end

  def user_str_show
    user_str.presence || "参加者"
  end

  def schedule_get_user_select(options)
    selects = []
    selects << ['すべて',0] if options[:all]=='all'

    if options[:st_at].class != String
      st_at = options[:st_at].strftime("%Y-%m-%d %H:%M:%S") rescue ""
      ed_at = options[:ed_at].strftime("%Y-%m-%d %H:%M:%S") rescue ""
    else
      st_at = options[:st_at] rescue ""
      ed_at = options[:ed_at] rescue ""
    end

    glist = Gw::PropTypesUser.where(:type_id => self.id).order(:user_id).to_a
    ulist = glist.sort{|a,b| a.user.code <=> b.user.code}
    ulist.each {|x|
        if !x.user.blank? && x.user.state == 'enabled'
          chk_cond =  " uid = #{x.user.id.to_i} and "
          chk_cond += " ( "
          chk_cond += "( st_at < '#{st_at}' and '#{st_at}' < ed_at   ) || "
          chk_cond += "( st_at < '#{ed_at}' and '#{ed_at}' < ed_at   ) || "
          chk_cond += "( st_at = '#{st_at}' and  ed_at  < '#{ed_at}' ) || "
          chk_cond += "('#{st_at}'  < st_at and  ed_at =  '#{ed_at}' ) || "
          chk_cond += "('#{st_at}' <= st_at and  ed_at <= '#{ed_at}' ) "
          chk_cond += " )"
          chk_order = " uid , ed_at desc , st_at "
          reserved = Gw::ScheduleUser.where(chk_cond).order(chk_order)
          next unless reserved.blank?
          selects.push [Gw.trim( x.user.name ).to_s+' ( '+x.user.code+' ) ',  x.user.id]
        end
    }
    return selects
  end
end
