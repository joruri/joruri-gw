class Gwsub::Sb04Setting < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  before_save :name_save

  def name_save
    self.updated_user  = Core.user.name
    self.updated_group = Core.user_group.name
  end

  def get_name
    case self.name
    when 'network_telephone_url'
      "ネットワーク電話URL"
    end
  end

  def self.get_network_telephone_url
    self.where(:name => "network_telephone_url").first.try(:data)
  end
end
