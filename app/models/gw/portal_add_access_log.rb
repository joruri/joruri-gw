class Gw::PortalAddAccessLog < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :add, :foreign_key => 'add_id', :class_name => 'Gw::PortalAdd'

  after_save :update_daily_access

private

  def update_daily_access
    add.increment!(:click_count)
    access = add.daily_accesses.where(:content => content, :accessed_at => accessed_at.to_date).first_or_create
    access.increment!(:click_count)
  end
end
