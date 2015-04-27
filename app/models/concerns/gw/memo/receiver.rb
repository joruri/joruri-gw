module Concerns::Gw::Memo::Receiver
  extend ActiveSupport::Concern

  included do
    attr_accessor :selected_receiver_uids
    validate :validate_selected_receivers
    after_save :save_selected_receivers
  end

  module ClassMethods
    def receiver_options(uids, options = {})
      users = System::User.select(:id, :code, :name).where(id: uids, state: 'enabled')
      users = users.where(ldap: 1) if Joruri.config.application['system.show_only_ldap_user']
      users.order(:code).preload(:memo_mobile_property).map do |user|
        property = user.memo_mobile_property
        if property && property.is_email_mobile?
          mobile_class = 'mobileOn'
          keitai_str = 'M　'
        else
          mobile_class = 'mobileOff'
          keitai_str = '　　'
        end
        if options[:with_image_class]
          [user.display_name, user.id, {class: mobile_class}]
        else
          [%(<span class="#{mobile_class}">#{keitai_str}#{user.display_name}</span>).html_safe, user.id, {}]
        end
      end
    end
  end

  private

  def validate_selected_receivers
    return if selected_receiver_uids.blank?

    self.selected_receiver_uids = selected_receiver_uids.reject(&:blank?).map(&:to_i)
    if selected_receiver_uids.size == 0
      errors.add(:memo_users, 'を選択してください。')
    end
    if selected_receiver_uids.size > 10
      errors.add(:memo_users, 'は10人以下にしてください。')
    end
  end

  def save_selected_receivers
    return if selected_receiver_uids.blank?

    memo_users.destroy_all
    selected_receiver_uids.each do |uid|
      memo_users.create(class_id: 1, uid: uid)
    end
  end
end
