# -*- encoding: utf-8 -*-
class Digitallibrary::Doc < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Cms::Model::Base::Content
  include Gwboard::Model::Recognition
  include Digitallibrary::Model::Systemname
  include System::Model::Base::Status

  acts_as_tree :order=>'display_order, sort_no'

  belongs_to :content,:foreign_key => :content_id,:class_name => 'Cms::Content'
  belongs_to :control,:foreign_key => :title_id, :class_name => 'Digitallibrary::Control'

  validates_presence_of :state
  after_validation :validate_title, :parent_change_check
  before_destroy :notification_destroy
  after_save :check_digit, :title_update_save, :notification_update

  attr_accessor :_notification
  attr_accessor :_bbs_title_name
  attr_accessor :_note_section
  attr_accessor :_doc_update

  def validate_title
    if self.title.blank?
      errors.add :title, "を入力してください。"
    end unless self.state == 'preparation'
  end

  def get_section_name(section_code=nil)
    return nil if section_code.blank?
    group = System::Group.new
    g_cond  = "code='#{section_code}' AND state = 'enabled'"
    g_order = "code"
    group_f = group.find(:first,:conditions=>g_cond,:order=>g_order)
    return nil if group_f.blank?
    return group_f.name
  end

  def parent_change_check
    unless self.parent_id  == self.chg_parent_id
      errors.add :seq_no, "階層が変更になる時は、先頭・最後尾のいずれかを選択してください" unless self.seq_no == -1 unless self.seq_no == 999999999.0
    end unless self.state == 'preparation'
  end

  def no_recog_states
    {'draft' => '下書き保存', 'recognized' => '公開待ち'}
  end

  def recog_states
    {'draft' => '下書き保存', 'recognize' => '承認待ち', 'recognized' => '公開待ち'}
  end

  def ststus_name
    str = ''
    str = '下書き' if self.state == 'draft'
    str = '承認待ち' if self.state == 'recognize'
    str = '公開待ち' if self.state == 'recognized'
    str = '公開中' if self.state == 'public'
    return str
  end

  def public_path
    if name =~ /^[0-9]{8}$/
      _name = name
    else
      _name = File.join(name[0..0], name[0..1], name[0..2], name)
    end
    Site.public_path + content.public_uri + _name + '/index.html'
  end

  def public_uri
    content.public_uri + name + '/'
  end

  def check_digit
    return true if name.to_s != ''
    return true if @check_digit == true

    @check_digit = true

    self.name = Util::CheckDigit.check(format('%07d', id))
    save
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'kwd'
        and_keywords v, :title, :body
      end
    end if params.size != 0

    return self
  end

  def notification_delete_old_records
    Gwboard::Synthesis.destroy_all(["latest_updated_at < ?", 5.days.ago])
  end

  def notification_create
    return nil unless self._notification == 1

    notification_delete_old_records
    Gwboard::Synthesis.destroy_all(["latest_updated_at < ?", 5.days.ago])

    Gwboard::Synthesis.create({
      :system_name => self.system_name,
      :state => self.state,
      :title_id => self.title_id,
      :parent_id => self.id,
      :latest_updated_at => self.latest_updated_at ,
      :board_name => self._bbs_title_name,
      :title => self.title,
      :url => self.portal_show_path,
      :editordivision => self._note_section ,
      :editor => self.editor || self.creater
    })
  end

  def notification_update
    return nil unless self._notification == 1

    notification_delete_old_records

    item = Gwboard::Synthesis.new
    item.and :title_id, self.title_id
    item.and :parent_id, self.id
    item.and :system_name , self.system_name
    item = item.find(:first)
    unless item.blank?
      item.system_name = self.system_name
      item.state = self.state
      item.title_id = self.title_id
      item.parent_id = self.id
      item.latest_updated_at = self.latest_updated_at
      item.board_name = self._bbs_title_name
      item.title = self.title
      item.url = self.portal_show_path
      item.editordivision = self._note_section
      item.editor = self.editor || self.creater
      item.save
    else
      notification_create
    end
  end

  def notification_destroy
    return nil unless self._notification == 1

    item = Gwboard::Synthesis.new
    item.and :title_id, self.title_id
    item.and :parent_id, self.id
    item.and :system_name, self.system_name
    item = item.find(:first)
    item.destroy if item
  end

  def item_path
    return "#{Site.current_node.public_uri.chop}?title_id=#{self.title_id}"
  end

  def docs_path
    ret = "#{Site.current_node.public_uri}?title_id=#{self.title_id}&cat=#{self.id.to_s}" if self.parent_id.blank?
    ret = "#{Site.current_node.public_uri}?title_id=#{self.title_id}&cat=#{self.parent_id.to_s}" unless self.parent_id.blank?
    return ret
  end

  def show_path(param_id=nil)
    if param_id.blank?
      return "#{Site.current_node.public_uri}#{self.id}?title_id=#{self.title_id}&cat=#{self.parent_id.to_s}" unless self.parent_id.blank?
      return "#{Site.current_node.public_uri}#{self.id}?title_id=#{self.title_id}&cat=#{self.id.to_s}" if self.parent_id.blank?
    else
      return "#{Site.current_node.public_uri}#{param_id}?title_id=#{self.title_id}&cat=#{param_id}"
    end
  end

  def edit_path
    if self.doc_type == 0
      return "#{item_home_path}folders/#{self.id}/edit?title_id=#{self.title_id}&cat=#{self.parent_id}"
    else
      return "#{item_home_path}docs/#{self.id}/edit?title_id=#{self.title_id}&cat=#{self.parent_id.to_s}" unless self.parent_id.blank?
      return "#{item_home_path}docs/#{self.id}/edit?title_id=#{self.title_id}&cat=#{self.id.to_s}" if self.parent_id.blank?
    end
  end

  def alias_edit_path
    return "#{Site.current_node.public_uri}#{self.doc_alias}/edit?title_id=#{self.title_id}" if self.doc_type == 1
  end

  def link_list_path
    return "#{item_home_path}docs/?title_id=#{self.title_id}&cat=#{self.id}"
  end

  def show_folder_path
    return "#{item_home_path}folders/#{self.id}?title_id=#{self.title_id}&cat=#{self.parent_id}" unless self.doc_type == 1   #見出し
    return ret
  end

  def delete_path
    return "#{Site.current_node.public_uri}#{self.id}/delete?title_id=#{self.title_id}&cat=#{self.parent_id.to_s}" unless self.parent_id.blank?
    return "#{Site.current_node.public_uri}#{self.id}/delete?title_id=#{self.title_id}&cat=#{self.id.to_s}" if self.parent_id.blank?
  end

  def update_path
    return "#{Site.current_node.public_uri}#{self.id}/update?title_id=#{self.title_id}&cat=#{self.parent_id.to_s}" unless self.parent_id.blank?
    return "#{Site.current_node.public_uri}#{self.id}/update?title_id=#{self.title_id}&cat=#{self.id.to_s}" if self.parent_id.blank?
  end

  def adms_edit_path
    return self.item_home_path + "adms/#{self.id}/edit/?title_id=#{self.title_id}"
  end

  def recognize_update_path
    return "#{Site.current_node.public_uri}#{self.id}/recognize_update?title_id=#{self.title_id}"
  end

  def publish_update_path
    return "#{Site.current_node.public_uri}#{self.id}/publish_update?title_id=#{self.title_id}"
  end

  def clone_path
    return "#{Site.current_node.public_uri}#{self.id}/clone/?title_id=#{self.title_id}"
  end

  def adms_clone_path
    return self.item_home_path + "adms/#{self.id}/clone/?title_id=#{self.title_id}"
  end

  def portal_show_path
    return self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}&cat=#{self.id}"
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end


  def title_update_save
    return unless self._doc_update
    if self.state=='public'
      item = Digitallibrary::Control.find(self.title_id)
      item.docslast_updated_at = Time.now
      item.save(:validate=>false)
    end
  end

  def send_reminder
    show_doc_path = "/digitallibrary/docs/#{self.id}?title_id=#{self.title_id}"
    if self.parent_id.blank?
      show_doc_path += "&cat=#{self.id.to_s}"
    else
      show_doc_path += "&cat=#{self.parent_id.to_s}"
    end
    self._recognizers.each do |k, v|
      unless v.blank?
        Gw.add_memo(v.to_s, "#{self.control.title}「#{self.title}」についての承認依頼が届きました。", "次のボタンから記事を確認し,承認作業を行ってください。<br /><a href='#{show_doc_path}&state=RECOGNIZE'><img src='/_common/themes/gw/files/bt_approvalconfirm.gif' alt='承認処理へ' /></a>",{:is_system => 1})
      end
    end if self._recognizers if self.state == 'recognize'
  end

  def _execute_sql(strsql)
    return connection.execute(strsql)
  end
end
