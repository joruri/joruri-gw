class Gw::AccessControl < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :user, :class_name => 'System::User'

  after_commit :delete_cache

  class << self
    def load_hash
      Rails.cache.fetch("Gw::AccessControl.load_hash") do
        self.select(:id, :user_id, :path).where(state: 'enabled').order(:priority).group_by(&:user_id)
      end
    end
  end

  private

  def delete_cache
    Rails.cache.delete("Gw::AccessControl.load_hash")
  end
end
