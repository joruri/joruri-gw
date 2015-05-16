class Gwworkflow::CustomRoute < Gw::Database
  self.table_name = 'gw_workflow_custom_routes'
  include System::Model::Base
  include System::Model::Base::Content

  has_many :steps, ->{ order(number: :asc) }, :class_name => 'Gwworkflow::CustomRouteStep', :foreign_key => :custom_route_id,
    :dependent => :destroy

  accepts_nested_attributes_for :steps, allow_destroy: true

  validates :sort_no, presence: true, numericality: { only_integer: true }, inclusion: { in: 0..9999 }
  validates :name, presence: true
  validates :state, presence: true
  validate :validate_committees_size

  def creater_id
    owner_uid
  end

  def enabled?
    state == 'enabled'
  end

  def current_number
    -1
  end

  def unmarked_steps
    steps.reject(&:marked_for_destruction?)
  end

  def rebuild_steps_and_committees(uids)
    steps.each(&:mark_for_destruction)
    if uids.present?
      uids.each_with_index do |uid, idx|
        if user = System::User.find(uid)
          step = steps.build(number: idx)
          step.committees.build(user_id: user.id, user_name: user.name, user_gname: user.group_name)
        end
      end
    end
  end

  private

  def validate_committees_size
    if unmarked_steps.length == 0
      errors.add('承認ステップ', 'を少なくとも1つ設定してください。')
    end
  end
end
