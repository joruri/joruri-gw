class Gw::PrefDirectorTemp < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  before_create :set_creator
  before_update :set_updator

  default_scope -> { where(deleted_at: nil) }

  def state_label
    self.class.state_show(state)
  end

  def self.state_select
    [['在席','on'],['不在','off']]
  end

  def self.state_show(state)
    state_select.rassoc(state).try(:first).to_s
  end

  class << self
    def group_code_conversions
      {
        "A10000" => "551",
        "A20000" => "552",
        "A30000" => "553",
        "A40000" => "555",
        "A50000" => "556",
        "A60000" => "557",
        "A70000" => "554"
      }
    end

    def rebuild(conf)
      status_item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors3', name: 'admin').first_or_create
      status_item.options = 'progress'
      status_item.save

      count_item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors4', name: 'admin').first_or_create
      count_item.options = 0
      count_item.save

      options = conf.options.split(',')
      ex_positions = options[0].to_s.gsub(/\r\n/, '').split('・')
      ex_empty_position = options[1] == '1'

      u = System::User.arel_table
      g = System::Group.arel_table
      users = System::User.eager_load(:groups).preload(:groups => :parent)
      users = users.where(u[:official_position].does_not_match_all(ex_positions.map{|p| "%#{p}%"})) if ex_positions.present?
      users = users.where(u[:official_position].not_eq_all([nil, ''])) if ex_empty_position
      users = users.order(g[:sort_no].asc, u[:sort_no].asc)

      num = 0
      Gw::PrefDirectorTemp.transaction do
        Gw::PrefDirectorTemp.truncate_table

        users.each_with_index do |user, index|
          group = user.groups.first
          next if !group || !group.parent

          temp = Gw::PrefDirectorTemp.new
          temp.parent_gid         = group.parent_id
          temp.parent_g_code      = group.parent.code
          temp.parent_g_name      = group.parent.name
          temp.parent_g_order     = group.parent.sort_no
          temp.gid                = group.id
          temp.g_code             = group.code
          temp.g_name             = group.name
          temp.g_order            = group.sort_no
          temp.uid                = user.id
          temp.u_code             = user.code
          temp.u_lname            = nil
          temp.u_name             = user.name
          temp.u_order            = "#{group.sort_no}#{index.to_i*10}".to_i
          temp.title              = "#{group.name}・#{user.official_position}"
          temp.state              = nil
          temp.is_governor_view   = 1
          temp.display_parent_gid = group.parent_id
          temp.version            = nil

          if conv = group_code_conversions[group.code]
            temp.parent_g_code  = conv
            temp.parent_g_name  = group.name
            temp.parent_g_order = (conv + "0").to_i
          end

          num += 1 if temp.save
        end
      end
      status_item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors3', name: 'admin').first_or_create
      status_item.options = 'finish'
      status_item.save

      count_item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors4', name: 'admin').first_or_create
      count_item.options = num
      count_item.save
      num
    end
  end

private

  def set_creator
    self.created_user  = Core.user.name if Core.user
    self.created_group = Core.user_group.ou_name if Core.user_group
  end

  def set_updator
    self.updated_user  = Core.user.name if Core.user
    self.updated_group = Core.user_group.ou_name if Core.user_group
  end
end
