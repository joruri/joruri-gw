class Gw::MemoUser < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :memo, :foreign_key => :schedule_id, :class_name => 'Gw::Memo'
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :user_property, :foreign_key => :uid, :primary_key => :uid, :class_name => 'Gw::Property::MemoMobileMail'

  before_create :set_user_data

  scope :with_user, ->(user = Core.user) { where(class_id: 1, uid: user.id) }

  def class_id_options
    [['すべて',0],['ユーザ',1],['グループ',2]]
  end

  def class_id_label
    class_id_options.rassoc(class_id).try(:first)
  end

  def display_name_with_mobile_class
    if user_property && user_property.is_email_mobile?
      %[<span class="mobileOn">#{uname} (#{ucode})</span>]
    else
      "#{uname} (#{ucode})"
    end
  end

  private

  def set_user_data
    if user
      self.ucode ||= user.code
      self.uname ||= user.name
    end
  end
end
