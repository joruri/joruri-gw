# -*- encoding: utf-8 -*-
class Gwcircular::Doc < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Cms::Model::Base::Content
  include Gwboard::Model::Recognition
  include Gwcircular::Model::Systemname

#  belongs_to :status,    :foreign_key => :state,        :class_name => 'Sys::Base::Status'
  has_many :files, :foreign_key => :parent_id, :class_name => 'Gwcircular::File', :dependent => :destroy
  belongs_to :control,   :foreign_key => :title_id,     :class_name => 'Gwcircular::Control'

  validates_presence_of :state, :able_date, :expiry_date
  after_validation :validate_title
  after_save :check_digit, :create_delivery, :update_commission_count, :update_circular_reminder
  after_destroy :commission_delete
  attr_accessor :_inner_process
  attr_accessor :_commission_count
  attr_accessor :_commission_state
  attr_accessor :_commission_limit

  def validate_title
    if self.title.blank?
      errors.add :title, "件名を入力してください。"
      self.state = 'draft' unless self._commission_state == 'public'
    else
      str = self.title.to_s.gsub(/　/, '').strip
      if str.blank?
        errors.add :title, "スペースのみのタイトルは登録できません。"
        self.state = 'draft' unless self._commission_state == 'public'
      end
      unless str.blank?

        s_chk = self.title.gsub(/\r\n|\r|\n/, '')
        self.title = s_chk
        if 140 <= s_chk.split(//).size
          errors.add :title, "件名は140文字以内で記入してください。"
          self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
        end
      end
    end if self.doc_type == 0 unless self.state == 'preparation'

    unless self.body.blank?
      errors.add :body, "返信内容は140文字以内で記入してください。" if 140 <= self.body.split(//).size
    end if self.doc_type == 1

    if self.able_date > self.expiry_date
      errors.add :expiry_date, "を確認してください。（期限日が作成日より前になっています。）"
      self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
    end unless self.able_date.blank? unless self.expiry_date.blank?

    if self.doc_type == 0
      cnt = 0
      a_grp = []
      a_usr = []
      unless self.reader_groups_json.blank?
        objects = JsonParser.new.parse(self.reader_groups_json)
        for object in objects
          a_grp << object[1]
        end
      end
      unless self.readers_json.blank?
        objects = JsonParser.new.parse(self.readers_json)
        for obj in objects
          a_usr << obj[1]
        end
      end
      chk_array = a_grp | a_usr
      cnt = chk_array.count

      if self._commission_limit < cnt
        self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
        errors.add :state, "配信先に#{cnt}人設定されていますが、回覧人数の制限値を越えています。最大#{self._commission_limit}人まで登録可能です。"
      end
    end unless self._commission_limit.blank? unless self.state == 'preparation'
  end

  def update_circular_reminder
    return nil unless self._commission_count
    return nil unless self.doc_type == 1

    Gw::Circular.update_all("state=0", "gid=#{self.id}")
  end

  def create_delivery
    return nil unless self._commission_count

    before_create_delivery
    save_reader_groups_json
    save_readers_json
    after_create_delivery
  end

  def before_create_delivery
    return nil if self.doc_type == 1

    condition = "title_id=#{self.title_id} AND parent_id=#{self.id} AND doc_type=1"
    Gwcircular::Doc.update_all("category4_id = 9", condition)
  end

  def save_reader_groups_json
    return nil if self._inner_process
    return nil if self.doc_type == 1
    unless self.reader_groups_json.blank?
      objects = JsonParser.new.parse(self.reader_groups_json)
      objects.each do |object|
        users = get_user_items(object[1])
        users.each do |user|
          create_delivery_data(user)
        end
      end
    end if self.doc_type == 0
  end

  def save_readers_json
    return nil if self._inner_process
    return nil if self.doc_type == 1
    unless self.readers_json.blank?
      objects = JsonParser.new.parse(self.readers_json)
      objects.each do |object|
        users = get_user_items(object[1])
        users.each do |user|
          create_delivery_data(user)
        end
      end
    end if self.doc_type == 0
  end

  def after_create_delivery
    return nil if self.doc_type == 1

    item = Gwcircular::Doc.new
    item.and :state, '!=','already'
    item.and :title_id,  self.title_id
    item.and :parent_id, self.id
    item.and :doc_type, 1
    item.and :category4_id, 9
    objcts = item.find(:all)
    for object in objcts
      object.state = 'preparation'
      object.save
      Gw::Circular.update_all("state=0", "gid=#{object.id}")
    end

    item = Gwcircular::Doc.new
    item.and :state, 'preparation'
    item.and :title_id,  self.title_id
    item.and :parent_id, self.id
    item.and :doc_type, 1
    item.and :category4_id, 0
    docs = item.find(:all)
    for doc in docs
      doc.state = 'draft'
      doc.save
      str_title = "<a href=''#{doc.show_path}''>#{self.title}</a>"
      Gw::Circular.update_all("state=1,title='#{str_title}',ed_at='#{doc.expiry_date.strftime("%Y-%m-%d %H:%M")}'", "gid=#{doc.id}")
    end
  end

  def update_commission_count
    return nil if self._inner_process
    return nil if self.doc_type == 1 unless self._commission_count
    self.commission_count_update(self.parent_id) if self.doc_type == 1 if self._commission_count
    self.commission_count_update(self.id) if self.doc_type == 0
  end

  def get_custom_group_users(gid)
    item = Gwcircular::CustomGroup.find_by_id(gid)
    ret = ''
    ret = item.readers_json unless item.blank?
    return ret
  end

  def get_group_user_items(gid)
    item = System::User.new
    item.and "sql", "system_users.state = 'enabled'"
#    item.and "sql", "system_users.ldap = 1" unless is_vender_user
    item.and "sql", "system_users_groups.group_id = #{gid}"
    return item.find(:all,:select=>'system_users.id, system_users.code, system_users.name',:joins=>['inner join system_users_groups on system_users.id = system_users_groups.user_id'],:order=>'system_users.code')
  end

  def is_vender_user
    ret = false
    ret = true if Site.user.code.length <= 3
    ret = true if Site.user.code == 'gwbbs'
    return ret
  end

  def get_user_items(uid)
    item = System::User.new
    item.and "sql", "system_users.state = 'enabled'"
#    item.and "sql", "system_users.ldap = 1" unless is_vender_user
    item.and "sql", "system_users_groups.user_id = #{uid}"
    return item.find(:all,:select=>'system_users.id, system_users.code, system_users.name',:joins=>['inner join system_users_groups on system_users.id = system_users_groups.user_id'],:order=>'system_users.code')
  end

  def create_delivery_data(user)
    return nil if user.blank?
    group_code = ''
    group_name = ''
    group_code = user.groups[0].code unless user.groups.blank?
    group_name = user.groups[0].name unless user.groups.blank?

    item = Gwcircular::Doc.new
    item.and :title_id,  self.title_id
    item.and :parent_id, self.id
    item.and :doc_type, 1
    item.and :target_user_code, user.code
    doc = item.find(:first)
    if doc.blank?

      doc_item = Gwcircular::Doc.create({
        :state => 'draft',
        :title_id => self.title_id,
        :parent_id => self.id,
        :doc_type => 1,
        :target_user_id => user.id,
        :target_user_code => user.code,
        :target_user_name => user.name,
        :confirmation => self.confirmation,
        :section_code => group_code,
        :section_name => group_name,
        :latest_updated_at => Time.now,
        :title => self.title,
        :able_date => self.able_date,
        :expiry_date => self.expiry_date ,
        :createdate => self.createdate ,
        :creater_id => self.creater_id ,
        :creater => self.creater ,
        :createrdivision => self.createrdivision ,
        :createrdivision_id => self.createrdivision_id ,
        :category4_id => 0
      })
      unless doc_item.blank?
        doc_item.doc_type = 1
        doc_item.target_user_id = user.id
        doc_item.target_user_code = user.code
        doc_item.target_user_name = user.name
        doc_item.section_code = group_code
        doc_item.section_name = group_name
        doc_item.category4_id = 0
        doc_item.save
      end
    else

      doc.confirmation = self.confirmation
      doc.title = self.title
      doc.able_date = self.able_date
      doc.expiry_date = self.expiry_date
      doc.createdate = self.createdate
      doc.creater_id = self.creater_id
      doc.creater = self.creater
      doc.createrdivision = self.createrdivision
      doc.createrdivision_id = self.createrdivision_id
      doc.category4_id = 0
      doc.save

      if doc.state == 'unread'
        str_title = "<a href=''#{doc.show_path}''>#{self.title}　[#{self.creater}(#{self.creater_id})]</a>"
        Gw::Circular.update_all("state=1,title='#{str_title}',ed_at='#{doc.expiry_date.strftime("%Y-%m-%d %H:%M")}'", "gid=#{doc.id}")
      end
    end
  end

  def publish_delivery_data(parent_id)

    item = Gwcircular::Doc.new
    item.and :title_id,  self.title_id
    item.and :parent_id, parent_id
    item.and :state, 'draft'
    item.and :doc_type, 1
    docs = item.find(:all)
    for doc in docs
      unless doc.category3_id == 1
        Gwboard.add_reminder_circular(doc.target_user_id.to_s, "<a href='#{doc.show_path}'>#{self.title}　[#{self.creater}(#{self.creater_id})]</a>", "次のボタンから記事を確認してください。<br /><a href='#{doc.show_path}'><img src='/_common/themes/gw/files/bt_addanswer.gif' alt='回覧する' /></a>",{:doc_id => doc.id,:parent_id=>doc.parent_id,:ed_at=>doc.expiry_date.strftime("%Y-%m-%d %H:%M")})
        doc.category3_id = 1
      end
      doc.state = 'unread'
      doc.save
    end

    self.commission_count_update(parent_id)
  end

  def commission_count_update(parent_id)

    condition = "state !='preparation' AND title_id=#{self.title_id} AND parent_id=#{parent_id} AND doc_type=1"
    commission_count = Gwcircular::Doc.count(:conditions=>condition)

    condition = "state='draft' AND title_id=#{self.title_id} AND parent_id=#{parent_id} AND doc_type=1"
    draft_count = Gwcircular::Doc.count(:conditions=>condition)

    condition = "state='unread' AND title_id=#{self.title_id} AND parent_id=#{parent_id} AND doc_type=1"
    unread_count = Gwcircular::Doc.count(:conditions=>condition)

    condition = "state='already' AND title_id=#{self.title_id} AND parent_id=#{parent_id} AND doc_type=1"
    already_count = Gwcircular::Doc.count(:conditions=>condition)

    item = Gwcircular::Doc.find_by_id(parent_id)
    return nil if item.blank?
    item.commission_count = commission_count
    item.draft_count = draft_count
    item.unread_count = unread_count
    item.already_count = already_count
    item._inner_process = true
    item.save
  end

  def commission_info
    ret = ''
    ret = "(#{self.already_count}/#{self.commission_count})" unless self.state == 'draft'
    ret += "(未配信#{self.draft_count})" unless self.draft_count == 0
    return ret
  end

  def commission_delete
    return unless self.doc_type == 0

    Gwcircular::Doc.destroy_all("parent_id=#{self.id}")
    Gw::Circular.destroy_all("class_id=#{self.id}")
  end

  def confirmation_name
    return [
      ['簡易回覧：詳細閲覧時自動的に既読にする', 0] ,
      ['通常回覧：閲覧ボタン押下時に既読にする', 1]
    ]
  end

  def status_name
    str = ''
    if self.doc_type == 0
      str = '下書き' if self.state == 'draft'
      str = '配信済み' if self.state == 'public'
      str = '期限終了' if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    end
    if self.doc_type == 1
      str = '非通知' if self.state == 'preparation'
      str = '配信予定' if self.state == 'draft'
      str = '<div align="center"><span class="required">未読</span></div>' if self.state == 'unread'
      str = '<div align="center"><span class="notice">既読</span></div>' if self.state == 'already'
      str = '期限切れ' if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    end
    return str
  end

  def status_name_csv
    str = ''
    if self.doc_type == 0
      str = '下書き' if self.state == 'draft'
      str = '配信済み' if self.state == 'public'
      str = '期限終了' if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    end
    if self.doc_type == 1
      str = '非通知' if self.state == 'preparation'
      str = '配信予定' if self.state == 'draft'
      str = '未読' if self.state == 'unread'
      str = '既読' if self.state == 'already'
      str = '期限切れ' if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    end
    return str
  end

  def already_body
    ret = ''
    ret = self.body if self.state == 'already'
    return ret
  end

  def display_opendocdate
    ret = ''
    ret = self.published_at.to_datetime.strftime('%Y-%m-%d %H:%M') unless self.published_at.blank?
    return ret
  end

  def display_editdate
    ret = ''
    ret = self.editdate.to_datetime.strftime('%Y-%m-%d %H:%M') unless self.editdate.blank?
    return ret
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

  def importance_name
    return self.importance_states[self.importance.to_s]
  end

  def item_home_path
    return "/gwcircular/"
  end
  
  def item_path
    return "#{Site.current_node.public_uri.chop}"
  end

  def show_path
    if self.doc_type == 0
      return "#{self.item_home_path}#{self.id}"
    else
      return "#{self.item_home_path}docs/#{self.id}"
    end
  end

  def edit_path
    return "#{Site.current_node.public_uri}#{self.id}/edit"
  end

  def doc_edit_path
    return "#{self.item_home_path}docs/#{self.id}/edit"
  end

  def doc_state_already_update
    return "#{self.item_home_path}docs/#{self.id}/already_update"
  end

  def clone_path
    return "#{Site.current_node.public_uri}#{self.id}/clone"
  end

  def delete_path
    return "#{Site.current_node.public_uri}#{self.id}"
  end

  def update_path
    return "#{Site.current_node.public_uri}#{self.id}"
  end

  def csv_export_path
    if self.doc_type == 0
      return "#{self.item_home_path}#{self.id}/csv_exports"
    else
      return '#'
    end
  end

  def csv_export_file_path
    if self.doc_type == 0
      return "#{self.item_home_path}#{self.id}/csv_exports/export_csv"
    else
      return '#'
    end
  end

  def file_export_path
    if self.doc_type == 0
      return "#{self.item_home_path}#{self.id}/file_exports"
    else
      return '#'
    end
  end

  def is_date(date_state)
    begin
      date_state.to_time
    rescue
      return false
    end
    return true
  end

  def self.json_array_select_trim(datas)
    return [] if datas.blank?
    datas.each do |data|
      data.delete_at(0)
      data.reverse!
    end
    return datas
  end
end