# -*- encoding: utf-8 -*-
class Gwfaq::Doc < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Cms::Model::Base::Content
  include Gwboard::Model::Recognition
  include Gwfaq::Model::Systemname

  belongs_to :content,   :foreign_key => :content_id,   :class_name => 'Cms::Content'
  belongs_to :control,   :foreign_key => :title_id,     :class_name => 'Gwfaq::Control'

  validates_presence_of :state
  after_validation  :validate_title
  before_destroy :notification_destroy
  after_save :check_digit, :send_reminder, :title_update_save, :notification_update

  attr_accessor :_notification
  attr_accessor :_bbs_title_name
  attr_accessor :_note_section

  def validate_title

    if title.blank?
      errors.add :title, "を入力してください。"
    end unless state == 'preparation'

    if category1_id.blank?
        errors.add :category1_id, "を設定してください。"
    end if category_use == 1 unless state == 'preparation'

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
      :editordivision => self._note_section,
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

  def image_edit_path
    return self.item_home_path + "images?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def upload_edit_path
    return self.item_home_path + "uploads?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def item_path
    return "/gwfaq/docs?title_id=#{self.title_id}"
  end

  def show_path
    return "/gwfaq/docs/#{self.id}/?title_id=#{self.title_id}"
  end

  def edit_path
    return "/gwfaq/docs/#{self.id}/edit?title_id=#{self.title_id}"
  end

  def delete_path
    return "/gwfaq/docs/#{self.id}?title_id=#{self.title_id}"
  end

  def update_path
    return "/gwfaq/docs/#{self.id}/update?title_id=#{self.title_id}"
  end

  def recognize_update_path
    return "/gwfaq/docs/#{self.id}/recognize_update?title_id=#{self.title_id}"
  end

  def publish_update_path
    return "/gwfaq/docs/#{self.id}/publish_update?title_id=#{self.title_id}"
  end

  def portal_show_path
    return self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}"
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end

  def send_reminder
    self._recognizers.each do |k, v|
      Gw.add_memo(v.to_s, "FAQ承認依頼[#{self.control.title}]", "<a href='/gwfaq/docs/#{self.id}/?title_id=#{self.title_id}'>記事承認依頼[#{self.title}]</a>")
    end if self._recognizers if self.state == 'recognize'
  end

  def title_update_save
    if self.state=='public'
      item = Gwfaq::Control.find(self.title_id)
      item.docslast_updated_at = Time.now
      item.save(:validate=>false)
    end
  end

  def _execute_sql(strsql)
    return connection.execute(strsql)
  end
end
