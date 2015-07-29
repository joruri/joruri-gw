# -*- encoding: utf-8 -*-
class Doclibrary::Doc < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Cms::Model::Base::Content
  include Gwboard::Model::Recognition
  include Doclibrary::Model::Systemname

  belongs_to :content,   :foreign_key => :content_id,   :class_name => 'Cms::Content'
  belongs_to :control,   :foreign_key => :title_id,     :class_name => 'Doclibrary::Control'

  validates_presence_of :state
  after_validation :validate_title, :validate_form002
  before_destroy :notification_destroy
  after_save :check_digit, :send_reminder, :title_update_save, :notification_create, :count_doc_record
  after_destroy :count_doc_delete_record

  attr_accessor :_notification
  attr_accessor :_bbs_title_name
  attr_accessor :_acl_records
  attr_accessor :_note_section

  def validate_title

    if self.title.blank?
      errors.add :title, "文書名を入力してください。" unless self.form_name == 'form002'
      errors.add :title, "件名を入力してください。" if self.form_name == 'form002'
    end unless self.state == 'preparation'

    if self.section_code.blank?
        errors.add :section_code, "を設定してください。"
    end unless self.form_name == 'form002' unless self.state == 'preparation'

    if self.category1_id.blank?
        errors.add :category1_id, "分類フォルダを設定してください。" unless self.form_name == 'form002'
        errors.add :category1_id, "号区分,区分を設定してください。" if self.form_name == 'form002'
    end unless self.state == 'preparation'
  end

  def validate_form002
    if self.form_name == 'form002'
      if self.inpfld_001.blank?
        errors.add :category2_id, "文書を選択してください。"
      end unless self.state == 'preparation'
    end
    if self.form_name == 'form002'
      if self.note.blank?
        errors.add :category2_id, "文書に添付ファイルがありません。文書の内容を確認してください。"
      end unless self.state == 'preparation'
    end
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

  def get_keywords_condition(words, *columns)
    cond = Condition.new
    words.to_s.split(/[ 　]+/).each_with_index do |w, i|
      break if i >= 10
      cond.and do |c|
        columns.each do |col|
          qw = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
          c.or col, 'LIKE', "%#{qw}%"
        end
      end
    end
    return cond
  end

  def notification_delete_old_records
    Gwboard::Synthesis.destroy_all(["latest_updated_at < ?", 5.days.ago])
  end

  def notification_create
    return nil unless self._notification == 1
    Gwboard::Synthesis.destroy_all(["latest_updated_at < ?", 5.days.ago])
    Gwboard::Synthesis.destroy_all("system_name='#{self.system_name}' AND title_id=#{self.title_id} AND parent_id=#{self.id}")

    self._acl_records.each do |acl_item|
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
        :editor => self.editor || self.creater ,
        :acl_flag => acl_item.acl_flag ,
        :acl_section_code => acl_item.acl_section_code ,
        :acl_user_code => acl_item.acl_user_code
      })
    end
  end

  def notification_destroy
    return nil unless self._notification == 1
    Gwboard::Synthesis.destroy_all("system_name='#{self.system_name}' AND title_id=#{self.title_id} AND parent_id=#{self.id}")
  end


  def item_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def docs_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs/#{self.id}?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def show_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    ret = "/doclibrary/docs/#{self.id}/?title_id=#{self.title_id}&gcd=#{self.section_code}" if state == 'GROUP'
    ret = "/doclibrary/docs/#{self.id}/?title_id=#{self.title_id}&cat=#{self.category1_id}&gcd=#{self.section_code}" if state == 'DATE'
    ret = "/doclibrary/docs/#{self.id}/?title_id=#{self.title_id}&cat=#{self.category1_id}" unless state == 'GROUP' unless state == 'DATE'
    return ret
  end

  def edit_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs/#{self.id}/edit?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def delete_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs/#{self.id}/delete?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def update_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs/#{self.id}/update?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def adms_edit_path
    return self.item_home_path + "adms/#{self.id}/edit/?title_id=#{self.title_id}"
  end

  def recognize_update_path
    return "/doclibrary/docs/#{self.id}/recognize_update?title_id=#{self.title_id}"
  end

  def publish_update_path
    return "/doclibrary/docs/#{self.id}/publish_update?title_id=#{self.title_id}"
  end

  def clone_path
    return "/doclibrary/docs/#{self.id}/clone/?title_id=#{self.title_id}"
  end

  def adms_clone_path
    return self.item_home_path + "adms/#{self.id}/clone/?title_id=#{self.title_id}"
  end

  def portal_show_path
    s_cat = ''
    s_cat = "&cat=#{self.category1_id}" unless self.category1_id == 0 unless self.category1_id.blank?
    return self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}#{s_cat}"
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end

  def title_update_save
    if self.state=='public'
      item = Doclibrary::Control.find(self.title_id)
      item.docslast_updated_at = Time.now
      item.save(:validate=>false)
      unless self.category1_id.blank? == 0
        sql = "UPDATE doclibrary_folders SET updated_at = '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}' WHERE id = '#{self.category1_id}'"
        self.connection.execute(sql)
      end unless self.category1_id.blank?
    end
  end

  def count_doc_delete_record
    count_doc_record('DELETE')
  end

  def count_doc_record(state_flag=nil)
    return if self.state == 'preparation'

    sql = "SELECT COUNT(id) FROM doclibrary_docs WHERE state = 'public' AND section_code = '#{self.section_code}'"
    count = Doclibrary::Doc.count_by_sql(sql)
    item = Doclibrary::GroupFolder.find_by_code(self.section_code)
    return if item.blank?
    diff_count = count - item.children_size
    unless diff_count == 0
      item.children_size = count
      item.state = 'public' unless item.children_size == 0
      item.state = 'public' unless item.total_children_size == 0
      item.state = 'closed' if item.total_children_size == 0 if item.children_size == 0
      item.docs_last_updated_at = Time.now if self.state == 'public' unless state_flag == 'DELETE'
      item.save
      return  if item.level_no < 2
      parent_children_size_update(item, diff_count, state_flag)
    else
      s_state = 'public' unless item.children_size == 0
      s_state = 'public' unless item.total_children_size == 0
      s_state = 'closed' if item.total_children_size == 0 if item.children_size == 0
      unless item.state == s_state
        item.state = s_state
        item.docs_last_updated_at = Time.now if self.state == 'public'  unless state_flag == 'DELETE'
        item.save
        return  if item.level_no < 2
        parent_children_size_update(item, diff_count, state_flag)
      else
        if self.state == 'public'
          item.docs_last_updated_at = Time.now
          item.save
          return  if item.level_no < 2
          parent_children_size_update(item, diff_count, state_flag)
        end  unless state_flag == 'DELETE'
      end
    end
  end

  def parent_children_size_update(item, diff_count, state_flag=nil)
    return false if item.level_no < 2
    parent = Doclibrary::GroupFolder.find_by_id(item.parent_id)
    return false if parent.blank?

    parent.total_children_size = parent.total_children_size + diff_count
    parent.state = 'public' unless parent.children_size == 0
    parent.state = 'public' unless parent.total_children_size == 0
    parent.state = 'closed' if parent.total_children_size == 0 if parent.children_size == 0
    parent.docs_last_updated_at = Time.now if self.state == 'public' unless state_flag == 'DELETE'
    parent.save

    parent_children_size_update(parent, diff_count) if 1 < parent.level_no unless parent.parent.blank?
  end

  def update_group_folder_children_size
    Doclibrary::GroupFolder.update_all("children_size = 0, total_children_size = 0")
    sql = "SELECT `section_code`, COUNT(`id`) AS cnt  FROM doclibrary_docs WHERE `state` = 'public' GROUP BY `section_code`"
    items = Doclibrary::Doc.find_by_sql(sql)
    for cnt_item in items
      item = Doclibrary::GroupFolder.find_by_code(cnt_item.section_code)
      item.children_size = cnt_item.cnt unless item.blank?
      item.save unless item.blank?
    end

    item = Doclibrary::GroupFolder.new
    item.and :level_no, '>', 1
    item.order 'level_no DESC'
    items = item.find(:all,:select => 'level_no',:group => 'level_no')
    for up_item in items
      update_total_chilldren_size(up_item.level_no, items[0].level_no)
    end

    sql = "UPDATE doclibrary_group_folders SET state = 'closed' WHERE children_size = 0 AND total_children_size = 0 AND NOT (level_no = 1)"
    self.connection.execute(sql)
    sql = "UPDATE doclibrary_group_folders SET state = 'public' WHERE level_no = 1"
    self.connection.execute(sql)
  end

  def update_total_chilldren_size(level_no, start_level_no)
    item = Doclibrary::GroupFolder.new
    item.and :level_no, level_no
    item.order 'parent_id ,code'
    items = item.find(:all)
    parent_id = 0
    total_children_count = 0
    for up_item in items
      unless parent_id == up_item.parent_id
        item = Doclibrary::GroupFolder.find_by_id(parent_id)
        unless item.blank?
          item.total_children_size = total_children_count
          item.save
        end
        total_children_count = 0
      end unless parent_id == 0
      parent_id = up_item.parent_id
      if level_no == start_level_no
        total_children_count += up_item.children_size
      else
        total_children_count += up_item.children_size
        total_children_count += up_item.total_children_size
      end
    end
    unless parent_id == 0
      item = Doclibrary::GroupFolder.find_by_id(parent_id)
      unless item.blank?
        item.total_children_size = total_children_count
        item.save
      end
    end unless total_children_count == 0
  end

  def send_reminder
    self._recognizers.each do |k, v|
      unless v.blank?
        Gw.add_memo(v.to_s, "#{self.control.title}「#{self.title}」についての承認依頼が届きました。", "次のボタンから記事を確認し,承認作業を行ってください。<br /><a href='/doclibrary/docs/#{self.id}?title_id=#{self.title_id}&state=RECOGNIZE'><img src='/_common/themes/gw/files/bt_approvalconfirm.gif' alt='承認処理へ' /></a>",{:is_system => 1})
      end
    end if self._recognizers if self.state == 'recognize'
  end


  def _execute_sql(strsql)
    return connection.execute(strsql)
  end
end

