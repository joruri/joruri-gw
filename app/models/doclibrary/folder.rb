# -*- encoding: utf-8 -*-
class Doclibrary::Folder < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Cms::Model::Base::Content
  include Doclibrary::Model::Systemname


  acts_as_tree :order=>'sort_no'

  validates_presence_of :state, :name

  before_destroy :delete_acl_records

  after_save :save_acl_records

  attr_accessor :_acl_create_skip

  def delete_acl_records
    Doclibrary::FolderAcl.destroy_all("title_id=#{self.title_id} AND folder_id=#{self.id}")
  end

  def save_acl_records
    return if self._acl_create_skip
    save_reader_groups_json
    save_readers_json
    save_reader_all
  end

  def save_reader_groups_json
    @rec_count = 0
    unless self.reader_groups_json.blank?
      Doclibrary::FolderAcl.destroy_all("title_id=#{self.title_id} AND folder_id=#{self.id}")
      groups = JsonParser.new.parse(self.reader_groups_json)
      groups.each do |group|
        item = Doclibrary::FolderAcl.new
        item.title_id = self.title_id
        item.folder_id = self.id
        item.acl_flag = 1
        item.acl_section_id = group[1]
        item.acl_section_code = group_code(group[1])
        item.acl_section_name = group[2]
        item.save!
        @rec_count += 1
      end
    end
  end

  def save_readers_json
    unless self.readers_json.blank?
      users = JsonParser.new.parse(self.readers_json)
      users.each do |user|
        item = Doclibrary::FolderAcl.new
        item.title_id = self.title_id
        item.folder_id = self.id
        item.acl_flag = 2
        item.acl_user_id = user[1].to_i
        item_user = System::User.find(item.acl_user_id)
        if item_user
          item.acl_user_id = item_user[:id]
          item.acl_user_code = item_user[:code]
        end
        item.acl_user_name = user[2]
        item.save!
        @rec_count += 1
      end
    end
  end

  def save_reader_all
    if @rec_count == 0
      item = Doclibrary::FolderAcl.new
      item.acl_flag = 0
      item.title_id = self.title_id
      item.folder_id = self.id
      item.save!
    else
      item = Doclibrary::FolderAcl.new
      item.acl_flag = 9
      item.title_id = self.title_id
      item.folder_id = self.id
      item.save!
    end
  end

  def group_code(id)
    item = System::Group.find_by_id(id)
    ret = ''
    ret = item.code if item
    return ret
  end

  def status_select
    [['公開','public'], ['非公開','closed']]
  end


  def status_name
    {'public' => '公開', 'closed' => '非公開'}
  end

  def level1
    self.and :level_no, 1
    return self
  end

  def level2
    self.and :level_no, 2
    return self
  end

  def level3
    self.and :level_no, 3
    return self
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'kwd'
        and_keywords v, :name
      end
    end if params.size != 0

    return self
  end

  def link_list_path
    return "#{self.item_home_path}docs?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.id}"
  end

  def item_path
    return "#{self.item_home_path}folders?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def show_path
    return "#{self.item_home_path}folders/#{self.id}?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def edit_path
    return "#{self.item_home_path}folders/#{self.id}/edit?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def delete_path
    return "#{self.item_home_path}folders/#{self.id}?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def update_path
    return "#{self.item_home_path}folders/#{self.id}/update?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def child_count
    file_base  = Doclibrary::Doc.new
    file_cond  = "state!='preparation' and category1_id=#{self.id}"
    file_count = file_base.count(:all,:conditions=>file_cond)

    folder_base = Doclibrary::Folder.new
    folder_cond = "state!='preparation' and parent_id=#{self.id}"
    folder_count  = folder_base.count(:all,:conditions=>folder_cond)

    child_count =file_count + folder_count
    return child_count
  end
  
  def readable_public_children(is_admin = false)
    item = Doclibrary::Folder.new
    item.and 'doclibrary_folders.parent_id', id
    item.and 'doclibrary_folders.title_id', title_id
    item.and 'doclibrary_folders.state', 'public'
    item.and do |c|
      c.or do |c2|
        c2.and 'doclibrary_folder_acls.acl_flag', 0
      end
      c.or do |c2|
        c2.and 'doclibrary_folder_acls.acl_flag', 9
      end if is_admin
      c.or do |c2|
        c2.and 'doclibrary_folder_acls.acl_flag', 1
        c2.and 'doclibrary_folder_acls.acl_section_code', Site.parent_user_groups.map(&:code)
      end
      c.or do |c2|
        c2.and 'doclibrary_folder_acls.acl_flag', 2
        c2.and 'doclibrary_folder_acls.acl_user_code', Core.user.code
      end
    end
    item.join 'INNER JOIN doclibrary_folder_acls on doclibrary_folders.id = doclibrary_folder_acls.folder_id'
    item.order 'doclibrary_folders.sort_no'
    item.find(:all, :select => 'DISTINCT doclibrary_folders.*')
  end
end
