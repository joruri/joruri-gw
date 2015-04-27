module Gwboard::Model::Folder::Auth
  extend ActiveSupport::Concern

  included do
    after_save :save_folder_acls
    scope :with_readable_acl, ->(control, user = Core.user) {
      if control.is_admin?(user)
        all
      else
        joins(:folder_acls).merge(reflect_on_association(:folder_acls).klass.with_user_or_groups(user))
      end
    }
  end

  def group_folder_acls
    folder_acls.select(&:group_acl?)
  end

  def user_folder_acls
    folder_acls.select(&:user_acl?)
  end

  def reader_groups_json_value
    JSON.parse(self.reader_groups_json)
  end

  def readers_json_value
    JSON.parse(self.readers_json)
  end

  def is_readable?(user = Core.user)
    return @is_readable if defined? @is_readable
    @is_readable = control.is_admin?(user) || folder_acls.with_user_or_groups(user).exists?
  end

  private

  def save_folder_acls
    folder_acls.destroy_all

    reader_groups_json_value.each do |group|
      if (g = System::Group.find_by(id: group[1]))
        folder_acls.create(title_id: self.title_id, acl_flag: 1, acl_section_id: g.id, acl_section_code: g.code, acl_section_name: g.name)
      end
    end
    readers_json_value.each do |user|
      if (u = System::User.find_by(id: user[1]))
        folder_acls.create(title_id: self.title_id, acl_flag: 2, acl_user_id: u.id, acl_user_code: u.code, acl_user_name: u.name_and_code)
      end
    end

    if folder_acls.size == 0
      folder_acls.create(title_id: self.title_id, acl_flag: 0)
    else
      folder_acls.create(title_id: self.title_id, acl_flag: 9)
    end
  end
end
