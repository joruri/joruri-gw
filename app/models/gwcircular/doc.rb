class Gwcircular::Doc < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Doc::Base
  include Gwboard::Model::Doc::Wiki
  include Gwcircular::Model::Doc::Auth
  include Gwcircular::Model::Systemname

  acts_as_tree dependent: :destroy

  attr_accessor :skip_update_commission_count

  has_many :files, :foreign_key => :parent_id, :dependent => :destroy
  has_many :reminders, :foreign_key => :class_id, :class_name => 'Gw::Circular', :dependent => :destroy
  has_many :commission_reminders, :foreign_key => :gid, :class_name => 'Gw::Circular', :dependent => :destroy
  belongs_to :control, :foreign_key => :title_id

  after_create :save_name_with_check_digit
  with_options unless: :state_preparation? do |f|
    f.after_save :update_commission_count, unless: :skip_update_commission_count
    f.with_options if: :doc_type_circular? do |f2|
      f2.after_save :save_commissions
      f2.after_save :publish_commissions, if: :state_public?
    end
    f.with_options if: :doc_type_commission? do |f2|
      f2.after_save :disable_commission_reminders
    end
  end

  with_options unless: :state_preparation? do |f|
    f.validates :state, :able_date, :expiry_date, presence: true
    f.validate :validate_date_order
    f.with_options if: :doc_type_circular? do |f2|
      f2.validates :title, presence: { message: "件名を入力してください。" }, length: { maximum: 140, message: "タイトルは140文字以内で記入してください。" }
      f2.validate :validate_commission_limit
    end
    f.with_options if: :doc_type_commission? do |f2|
      f2.validates :body, length: { maximum: 140, message: "返信内容は140文字以内で記入してください。" }
    end
  end

  scope :circular_docs, -> { where(doc_type: 0) }
  scope :commission_docs, -> { where(doc_type: 1) }
  scope :abled_docs, ->(time = Time.now) { where(arel_table[:able_date].lteq(time)) }
  scope :expired_docs, ->(time = Time.now) { where(arel_table[:expiry_date].lt(time)) }
  scope :with_target_user, ->(user = Core.user) { where(target_user_code: user.code) }

  scope :index_docs_with_params_and_request, ->(params, request) {
    case params[:cond]
    when 'unread'
      commission_docs.abled_docs.with_target_user(Core.user)
        .where(state: request.mobile? ? 'unread' : %w(unread mobile))
    when 'already'
      commission_docs.abled_docs.with_target_user(Core.user)
        .where(state: request.mobile? ? %w(already mobile) : 'already')
    when 'owner'
      circular_docs.abled_docs.with_target_user(Core.user).without_preparation
    when 'void'
      circular_docs.expired_docs.with_target_user(Core.user).without_preparation
    when 'admin'
      circular_docs.abled_docs.without_preparation
    else
      none
    end
  }
  scope :index_order_with_params, ->(params) {
    case params[:cond]
    when 'unread', 'already'
      order(expiry_date: :desc)
    else
      order(latest_updated_at: :desc)
    end
  }

  def doc_type_circular?
    doc_type == 0
  end

  def doc_type_commission?
    doc_type == 1
  end

  def commission_info
    ret = ''
    ret = "(#{self.already_count}/#{self.commission_count})" unless self.state == 'draft'
    ret += "(未配信#{self.draft_count})" unless self.draft_count == 0
    return ret
  end

  def confirmation_name
    return [
      ['簡易回覧：詳細閲覧時自動的に既読にする', 0] ,
      ['通常回覧：閲覧ボタン押下時に既読にする', 1]
    ]
  end

  def state_options
    if self.doc_type_circular?
      [['下書き','draft'],['配信済み','public']]
    else
      [['非通知','preparation'],['配信予定','draft'],['未読','unread'],['携帯で確認','mobile'],['既読','already']]
    end
  end

  def state_label
    if self.doc_type_circular?
      if self.state == 'public' && self.expiry_date.present? && self.expiry_date < Time.now
        '期限終了'
      else
        state_options.rassoc(self.state).try(:first)
      end 
    else
      if self.state == 'public' && self.expiry_date.present? && self.expiry_date < Time.now
        '期限切れ'
      else
        state_options.rassoc(self.state).try(:first)
      end
    end
  end

  def status_name
    if self.doc_type == 0
      state_label
    elsif self.doc_type == 1
      if self.state == 'unread' || self.state == 'mobile'
        %(<div align="center"><span class="required">#{state_label}</span></div>).html_safe
      elsif self.state == 'already'
        %(<div align="center"><span class="notice">#{state_label}</span></div>).html_safe
      else
        state_label
      end
    end
  end

  def status_name_mobile
    if self.doc_type == 0
      state_label
    elsif self.doc_type == 1
      if self.state == 'unread' || self.state == 'mobile'
        %(<span class="required">#{state_label}</span>).html_safe
      elsif self.state == 'already'
        %(<span class="notice">#{state_label}</span>).html_safe
      else
        state_label
      end
    end
  end

  def already_body
    ret = ''
    ret = self.body if self.state == 'already' || self.state == 'mobile'
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
      return "#{self.item_home_path}menus/#{self.id}"
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

  def doc_state_unread_update
    return "#{self.item_home_path}docs/#{self.id}/unread_update"
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
    return "#{self.item_home_path}#{self.id}/file_exports"
  end

  def file_export_file_path
    return "#{self.item_home_path}#{self.id}/file_exports/export_file"
  end

  def self.json_array_select_trim(datas)
    return [] if datas.blank?
    datas.each do |data|
      data.delete_at(0)
      data.reverse!
    end
    return datas
  end

  def set_creater_editor
    case
    when self.doc_type_circular?
      if self.createdate.blank? || !control.is_admin?
        self.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
        self.creater_id = Core.user.code
        self.creater = Core.user.name
        self.createrdivision = Core.user_group.name
        self.createrdivision_id = Core.user_group.code
      end
    when self.doc_type_commission?
      if self.editdate.blank? || !control.is_admin?
        self.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
        self.editor_id = Core.user.code
        self.editor = Core.user.name
        self.editordivision_id = Core.user_group.code
        self.editordivision = Core.user_group.name
      end
    end
  end

  def duplicate
    new_doc = self.class.new
    new_doc.attributes = self.attributes.except(:id)
    new_doc.unid = nil
    new_doc.created_at = nil
    new_doc.updated_at = nil
    new_doc.recognized_at = nil
    new_doc.published_at = nil
    new_doc.state = 'draft'
    new_doc.category4_id = 0
    new_doc.name = nil
    new_doc.latest_updated_at = Core.now
    new_doc.createdate = nil
    new_doc.creater_admin = nil
    new_doc.createrdivision_id = nil
    new_doc.createrdivision = nil
    new_doc.creater_id = nil
    new_doc.creater = nil
    new_doc.editdate = nil
    new_doc.editor_admin = nil
    new_doc.editordivision_id = nil
    new_doc.editordivision = nil
    new_doc.editor_id = nil
    new_doc.editor = nil
    new_doc.able_date = Time.now.strftime("%Y-%m-%d")
    new_doc.expiry_date = control.default_published.months.since.strftime("%Y-%m-%d")
    new_doc.section_code = Core.user_group.code
    new_doc.section_name = Core.user_group.code + Core.user_group.name
    new_doc.creater_admin = true
    new_doc.editor_admin = false

    new_doc.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    new_doc.creater_id = Core.user.code if Core.user.code.present?
    new_doc.creater = Core.user.name if Core.user.name.present?
    new_doc.createrdivision = Core.user_group.name if Core.user_group.name.present?
    new_doc.createrdivision_id = Core.user_group.code if Core.user_group.code.present?
    new_doc.editor_id = Core.user.code if Core.user.code.present?
    new_doc.editordivision_id = Core.user_group.code if Core.user_group.code.present?
    new_doc.creater_admin = control.is_admin?
    new_doc.editor_admin = control.is_admin?

    return nil unless new_doc.save

    files.each do |file|
      new_file = file.class.new
      new_file.attributes = file.attributes.except(:id)
      new_file.file = Sys::Lib::File::NoUploadedFile.new(file.f_name, filename: file.filename, mime_type: file.content_type)
      new_file.parent_id = new_doc.id
      new_file.db_file_id = -1
      new_file.save!

      new_doc.body = new_doc.body.gsub(file.file_uri('gwcircular'), new_file.file_uri('gwcircular'))
    end

    new_doc.update_columns(body: new_doc.body) if new_doc.body_changed?
    new_doc
  end

  def count_commissions
    update_columns(
      commission_count: children.where.not(state: 'preparation').count, 
      draft_count: children.where(state: 'draft').count, 
      unread_count: children.where(state: %w(unread mobile)).count, 
      already_count: children.where(state: 'already').count
    )
  end

  private

  def save_name_with_check_digit
    update_columns(name: Util::CheckDigit.check(format('%07d', self.id))) if self.name.blank?
  end

  def validate_date_order
    if self.able_date && self.expiry_date && self.able_date > self.expiry_date
      errors.add :expiry_date, "を確認してください。（期限日が作成日より前になっています。）"
    end 
  end

  def validate_commission_limit
    return if control.commission_limit.blank?

    users1 = JSON.parse(self.reader_groups_json)
    users2 = JSON.parse(self.readers_json)
    count = (users1 + users2).size
    if control.commission_limit < count
      errors.add :state, "配信先に#{count}人設定されていますが、回覧人数の制限値を越えています。最大#{control.commission_limit}人まで登録可能です。"
    end
  end

  def update_commission_count
    count_commissions if doc_type_circular?
    parent.count_commissions if doc_type_commission? && parent
  end

  def save_commissions
    before_create_commissions
    save_reader_groups_json
    save_readers_json
    after_create_commissions

    count_commissions
  end

  def before_create_commissions
    children.update_all(category4_id: 9)
  end

  def save_reader_groups_json
    return if self.reader_groups_json.blank?

    uids = JSON.parse(self.reader_groups_json).map{|o| o[1]}
    System::User.where(id: uids, state: 'enabled').order(:code).select(:id, :code, :name).all.each do |user|
      create_commission_for(user)
    end
  end

  def save_readers_json
    return if self.readers_json.blank?

    uids = JSON.parse(self.readers_json).map{|o| o[1]}
    System::User.where(id: uids, state: 'enabled').order(:code).select(:id, :code, :name).all.each do |user|
      create_commission_for(user)
    end
  end

  def after_create_commissions
    discard_docs = children.where.not(state: 'already').where(category4_id: 9).all
    discard_docs.each do |doc|
      doc.update_columns(state: 'preparation')
      doc.commission_reminders.update_all(state: 0)
    end
  end

  def create_commission_for(user)
    return nil if user.blank?

    doc = children.where(doc_type: 1, target_user_code: user.code).first ||
          children.build(doc_type: 1, target_user_code: user.code)
    if doc.new_record?
      doc.state = 'draft'
    else
      doc.state = 'draft' if doc.state == 'preparation'
    end
    doc.title_id ||= self.title_id
    doc.target_user_id ||= user.id
    doc.target_user_code ||= user.code
    doc.target_user_name ||= user.name
    doc.section_code ||= user.groups.first.try(:code)
    doc.section_name ||= user.groups.first.try(:name)
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
    doc.skip_update_commission_count = true
    doc.save

    if doc.state == 'unread'
      title = "<a href=''#{doc.show_path}''>#{self.title}　[#{self.creater}(#{self.creater_id})]</a>"
      doc.commission_reminders.update_all(state: 1, title: title, ed_at: doc.expiry_date)
    end
  end

  def publish_commissions
    children.where(state: 'draft').update_all(state: 'unread')

    children.where(state: 'unread', category3_id: nil).each do |doc|
      Gwboard.add_reminder_circular(doc.target_user_id.to_s, 
        "<a href='#{doc.show_path}'>#{self.title}　[#{self.creater}(#{self.creater_id})]</a>", 
        "次のボタンから記事を確認してください。<br /><a href='#{doc.show_path}'><img src='/_common/themes/gw/files/bt_addanswer.gif' alt='回覧する' /></a>",
        {:doc_id => doc.id, :parent_id => doc.parent_id, :ed_at => doc.expiry_date.strftime("%Y-%m-%d %H:%M")})
      doc.update_columns(category3_id: 1)
    end

    count_commissions
  end

  def disable_commission_reminders
    return if self.state == "mobile"
    commission_reminders.update_all(state: 0)
  end
end
