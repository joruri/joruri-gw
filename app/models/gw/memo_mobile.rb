class Gw::MemoMobile < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  class << self
    def load_all_items
      Rails.cache.fetch("#{self.name}.#{__method__}") do
        self.select(:id, :domain).order(:id)
      end
    end

    def is_email_mobile?(email = nil, mobile_domains = nil)
      return false if email.blank? || !email.include?("@")
      domain = email.match(/@/).post_match

      (mobile_domains || load_all_items).any?{|item| item.domain == domain}
    end
  end
end
