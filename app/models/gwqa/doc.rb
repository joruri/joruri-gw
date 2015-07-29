# -*- encoding: utf-8 -*-
class Gwqa::Doc < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Cms::Model::Base::Content
  include Gwqa::Model::Systemname

  belongs_to :content,   :foreign_key => :content_id,   :class_name => 'Cms::Content'
  belongs_to :control,   :foreign_key => :title_id,     :class_name => 'Gwqa::Control'

  validates_presence_of :state
  after_validation  :validate_title
  before_update :set_title
  before_destroy :notification_destroy
  after_update :answer_count_update
  after_save :check_digit, :title_update_save, :notification_update, :answer_date_update
  after_destroy :answer_count_update, :q_delete_draft_answers

  attr_accessor :_notification
  attr_accessor :_bbs_title_name
  attr_accessor :_note_section
  attr_accessor :_no_validation

  def validate_title
    return if self._no_validation
    if title.blank?
      errors.add :title, "を入力してください。"
    end unless state == 'preparation' if doc_type == 0

    if category1_id.blank?
        errors.add :category1_id, "を設定してください。"
    end if category_use == 1 unless state == 'preparation' if doc_type == 0

  end

  def no_recog_states
    {'draft' => '下書き保存', 'recognized' => '公開待ち'}
  end

  def recog_states
    {'draft' => '下書き保存', 'recognize' => '承認待ち', 'public' => '公開保存'}
  end

  def resolved_status
    { 'unresolved' => '未解決'  , 'resolved'   =>  '解決済'}
  end

  def resolved_status_select
    [['未解決','unresolved'],['解決済','resolved']]
  end

  def public_path
    if name =~ /^[0-9]{8}$/
      _name = name
    else
      _name = File.join(name[0..0], name[0..1], name[0..2], name)
    end
    Site.public_path + content.public_uri + _name + '/index.html'
  end

  def parent_path
    if self.doc_type == 1
      _name = pname
    else
      _name = name
    end
    Site.public_path + content.public_uri + _name + '/index.html'
  end

  def public_uri
    content.public_uri + name + '/'
  end

  def check_digit
    if pname.to_s != ''
      return true if name.to_s != ''
    end
    return true if @check_digit == true

    @check_digit = true

    self.name = Util::CheckDigit.check(format('%07d', id))
    self.pname = Util::CheckDigit.check(format('%07d', parent_id))
    save
  end


  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 'cat1'
        self.and :category1_id, v
      when 'cat2'
        self.and :category2_id, v
      when 'cat3'
        self.and :category3_id, v
      when 'kwd'
        and_keywords v, :title, :body
      end
    end if params.size != 0

    return self
  end

  def answer_date_update
    if self.state == 'public'
      item = Gwqa::Doc.new
      item.and :id, self.parent_id
      item.and :title_id, self.title_id
      item = item.find(:first)
      unless item.blank?
        item.latest_answer = self.latest_updated_at unless self.latest_updated_at.blank?
        item.save
      end
    end if self.doc_type == 1
  end

  def notification_delete_old_records
    Gwboard::Synthesis.destroy_all(["latest_updated_at < ?", 5.days.ago])
  end

  def notification_create
    return nil unless self._notification == 1

    notification_delete_old_records
    Gwboard::Synthesis.destroy_all(["latest_updated_at < ?", 5.days.ago])
    doc_id = self.id if self.doc_type == 0
    doc_id = self.parent_id unless self.doc_type == 0
    Gwboard::Synthesis.create({
      :system_name => self.system_name,
      :state => self.state,
      :title_id => self.title_id,
      :parent_id => doc_id,
      :latest_updated_at => self.latest_updated_at ,
      :board_name => self._bbs_title_name,
      :title => self.title,
      :url => self.portal_show_path,
      :editordivision => self._note_section ,
      :editor => self.editor || self.creater
    })
  end

  def notification_update
    return if self._no_validation
    return nil unless self._notification == 1

    notification_delete_old_records

    doc_id = self.id if self.doc_type == 0
    doc_id = self.parent_id unless self.doc_type == 0

    item = Gwboard::Synthesis.new
    item.and :title_id, self.title_id
    item.and :parent_id, doc_id
    item.and :system_name , self.system_name
    item = item.find(:first)
    unless item.blank?
      item.system_name = self.system_name
      item.state = self.state
      item.title_id = self.title_id
      item.parent_id = doc_id
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

    doc_id = self.id if self.doc_type == 0
    doc_id = self.parent_id unless self.doc_type == 0

    item = Gwboard::Synthesis.new
    item.and :title_id, self.title_id
    item.and :parent_id, doc_id
    item.and :system_name, self.system_name
    item = item.find(:first)
    item.destroy if item
  end

  def qa_doc_path
    return item_home_path + 'docs'
  end

  def gwqa_doc_index_path
    return item_home_path + "docs?title_id=#{self.title_id}"
  end

  def gwqa_answer_new_path(title_id, parent_id)
    return item_home_path + "docs/new/?title_id=#{title_id}&p_id=#{parent_id}"
  end

  def gwqa_edit_path
    if self.doc_type == 0
      return item_home_path + "docs/#{self.id}/edit?title_id=#{self.title_id}&p_id=Q"
    else
      return item_home_path + "docs/#{self.id}/edit?title_id=#{self.title_id}&p_id=#{self.parent_id}"
    end
  end

  def close_path
    return "/gwqa/docs/#{self.id}?title_id=#{self.title_id}&do=close"
  end

  def clone_path
    return "/gwqa/docs/#{self.id}?title_id=#{self.title_id}&do=clone"
  end

  def publish_path
    return "/gwqa/docs/#{self.id}?title_id=#{self.title_id}&do=publish"
  end

  def item_path
    return "/gwqa/docs?title_id=#{self.title_id}"
  end

  def docs_path
    if self.doc_type == 0
      str_path = "/gwqa/docs?title_id=#{self.title_id}"
    else
      str_path = "/gwqa/docs/#{self.parent_id}/?title_id=#{self.title_id}"
    end
    return str_path
  end

  def show_path
    if self.doc_type == 0
      str_path = "/gwqa/docs/#{self.id}/?title_id=#{self.title_id}"
    else
      str_path = "/gwqa/docs/#{self.parent_id}/?title_id=#{self.title_id}"
    end
    return str_path
  end

  def edit_path
    str_path =  "/gwqa/docs/#{self.id}/edit?title_id=#{self.title_id}"
    str_path = str_path + "&parent_id=#{self.parent_id}" if self.doc_type == 1
    return str_path
  end

  def delete_path
    str_path = "/gwqa/docs/#{self.id}?title_id=#{self.title_id}"
    return str_path
  end

  def settlement_path
    str_path = ''
    str_path = "/gwqa/docs/#{self.id}/settlement?title_id=#{self.title_id}" if self.doc_type == 0
    return str_path
  end

  def update_path
    str_path = "#{Site.current_node.public_uri}#{self.id}?title_id=#{self.title_id}"
    if self.doc_type==1
      str_path = str_path + "&parent_id=#{self.parent_id}"
    else
      str_path = str_path + "&p_id=Q"
    end
    return str_path
  end

  def portal_show_path
    ret = ''
    if self.doc_type == 0
      ret = self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}"
    else
      ret = self.item_home_path + "docs/#{self.parent_id}/?title_id=#{self.title_id}"
    end
    return ret
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end

  def set_title
    if self.doc_type == 0
      args = ["UPDATE gwqa_docs SET title = ? WHERE doc_type = 1 AND parent_id = ?;", self.title, self.id]
      strsql = ActiveRecord::Base.send(:sanitize_sql_array, args)
      connection.execute(strsql)
    else
      item = Gwqa::Doc.find_by_id(self.parent_id)
      unless item.blank?
        self.title = item.title unless item.title.blank?
      end
    end
  end

  def q_delete_draft_answers
      strsql = "UPDATE gwqa_docs SET state = 'draft' WHERE state = 'public' AND doc_type = 1 AND parent_id = #{self.id};"
      connection.execute(strsql)
  end

  def title_update_save
    if self.state=='public'
      item = Gwqa::Control.find(self.title_id)
      item.docslast_updated_at = Time.now
      item.save(:validate=>false)
    end
  end

  def answer_count_update
    if self.doc_type == 1
      strsql = "SELECT id FROM gwqa_docs WHERE state = 'public' AND doc_type = 1 AND parent_id = #{self.parent_id};"
      item = Gwqa::Doc.find_by_sql(strsql)
      strsql = " UPDATE gwqa_docs SET answer_count = #{item.count} WHERE id = #{self.parent_id};"
      connection.execute(strsql)
    end
  end

  def _execute_sql(strsql)
    return connection.execute(strsql)
  end
end
