class Doclibrary::GroupFolder < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Gwboard::Model::SerialNo

  acts_as_tree order: { sort_no: :asc }

  belongs_to :control, :foreign_key => :title_id

  after_update :close_state

  validates :state, :name, presence: true

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
        search_keyword v, :name
      end
    end if params.size != 0

    return self
  end

  def item_home_path
    return '/doclibrary/'
  end

  def link_list_path
    return "#{self.item_home_path}group_folders?title_id=#{self.title_id}&state=GROUP&grp=#{self.id}&gcd=#{self.code}"
  end

  def item_path
    return "#{self.item_home_path}group_folders?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

  def show_path
    return "#{self.item_home_path}group_folders/#{self.id}?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

  def edit_path
    return "#{self.item_home_path}group_folders/#{self.id}/edit?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

  def delete_path
    return "#{self.item_home_path}group_folders/#{self.id}?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

  def update_path
    return "#{self.item_home_path}group_folders/#{self.id}?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

  def public_children
    children.where(state: 'public')
  end

  def public_descendants
    public_children.inject([]) {|arr, c| arr << c; arr += c.public_descendants }
  end

  def public_descendant_codes
    public_children.select(:id, :parent_id, :code).inject([]) {|arr, c| arr << c.code; arr += c.public_descendant_codes }
  end

  def close_state_for_descendants
    children.update_all(state: 'closed')
    children.each(&:close_state_for_descendants)
  end

  def self.sync_group_folders(id, mode = 'public')
    control_item = Doclibrary::Control.where(:id => id).first
    return false if control_item.blank?
    mode = 'closed' if mode.blank?

    transaction do
      sync_system_groups(control_item, mode)
      sync_public_docs_count(control_item)
    end
  end

  private

  def close_state
    if !new_record? && state_changed? && state == 'closed'
      close_state_for_descendants
    end
  end

  def self.sync_system_groups(control, mode = 'public')
    control.group_folders.update_all(use_state: 'closed')

    System::Group.where(state: 'enabled').order(:level_no, :sort_no, :id).each do |group|
      use_state = group.ldap == 0 ? 'closed' : mode
      parent_folder = control.group_folders.where(sysgroup_id: group.parent_id).first
      if folder = control.group_folders.where(code: group.code).first
        folder.update_columns(
          :state => 'closed',
          :use_state => use_state,
          :parent_id => parent_folder.try(:id),
          :sort_no => group.sort_no,
          :level_no => group.level_no,
          :name => group.name,
          :sysgroup_id => group.id,
          :sysparent_id => group.parent_id,
          :updated_at => Time.now
        )
      else
        control.group_folders.create(
          :state => 'closed',
          :use_state => use_state,
          :parent_id => parent_folder.try(:id),
          :sort_no => group.sort_no,
          :level_no => group.level_no,
          :code => group.code,
          :name => group.name,
          :sysgroup_id => group.id,
          :sysparent_id => group.parent_id,
          :children_size => 0,
          :total_children_size => 0,
        )
      end
    end
  end

  def self.sync_public_docs_count(control)
    control.group_folders.update_all(state: 'public', children_size: 0, total_children_size: 0)

    control.docs.public_docs.select(:section_code).group(:section_code).count(:id).each do |section_code, count|
      if folder = control.group_folders.find_by(code: section_code)
        folder.update_columns(children_size: count)
        folder.ancestors.each do |ancestor|
          ancestor.update_columns(total_children_size: ancestor.total_children_size + count)
        end
      end
    end

    control.group_folders.where(children_size: 0, total_children_size: 0).update_all(state: 'closed')
    control.group_folders.where(level_no: 1).update_all(state: 'public')
  end
end
