class Gw::Memo < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Concerns::Gw::Memo::Receiver
  include Concerns::Gw::Upload::TmpId

  has_many :memo_users, :foreign_key => :schedule_id, :class_name => 'Gw::MemoUser', :dependent => :destroy
  has_many :files, :foreign_key => :parent_id, :class_name => 'Gw::MemoFile', :dependent => :destroy
  belongs_to :sender, :primary_key => :id, :foreign_key => :uid, :class_name => 'System::User'

  before_create :set_user_data
  after_save :set_parent_id_to_files
  attr_accessor :renew_attach_files

  validates :title, :ed_at, presence: true

  scope :only_finished, -> { where(is_finished: 1) }
  scope :only_unfinished, -> { where(is_finished: 0) }

  scope :with_sender, ->(user = Core.user) { where(class_id: 1, uid: user.id) }
  scope :with_receiver, ->(user = Core.user) { joins(:memo_users).merge(Gw::MemoUser.with_user(user)) }

  scope :search_with_params, ->(params) {
    rel = all
    case params[:s_send_cls]
    when "1" then rel = rel.with_receiver(Core.user)
    when "2" then rel = rel.with_sender(Core.user)
    else rel = rel.with_sender(Core.user)
    end
    case params[:s_finished]
    when "1" then rel = rel.only_unfinished
    when "2" then rel = rel.only_finished
    end
    rel
  }
  scope :index_order_with_params, ->(params) {
    if params[:sort_keys] =~ /\A(.+) (.+)\z/
      if $1 == 'send_cls'
        if params[:s_send_cls] == '1'
          order(uname: $2.to_sym, created_at: :desc)
        else
          eager_load(:memo_users).order(Gw::MemoUser.arel_table[:uname].send($2)).order(created_at: :desc)
        end
      else
        order($1 => $2.to_sym).order(created_at: :desc)
      end
    else
      order(created_at: :desc)
    end
  }

  scope :memos_for_reminder, ->(user, property) {
    read = property.memos['read_memos_display'].to_i
    unread = property.memos['unread_memos_display'].to_i
    if read == 0 && unread == 0
      none
    elsif read == 0
      with_receiver(user).unfinished_memos_for_reminder(unread)
    elsif unread == 0
      with_receiver(user).finished_memos_for_reminder(read)
    else
      with_receiver(user).where([
        finished_memos_for_reminder(read).where_values.reduce(:and),
        unfinished_memos_for_reminder(unread).where_values.reduce(:and)
      ].reduce(:or))
    end
  }
  scope :finished_memos_for_reminder, ->(read_memos_display) {
    where(arel_table[:is_finished].eq(1)).where(arel_table[:created_at].gt(Date.today - read_memos_display + 1))
  }
  scope :unfinished_memos_for_reminder, ->(unread_memos_display) {
    where(arel_table[:is_finished].eq(0)).where(arel_table[:created_at].gt(Date.today - unread_memos_display + 1))
  }

  def set_parent_id_to_files
    return if tmp_id.blank?
    return unless renew_attach_files
    Gw::MemoFile.where(tmp_id: tmp_id).update_all(parent_id: id)
  end

  def is_finished_label
    is_finished == 1 ? '既読' : '未読'
  end

  def is_finished?
    is_finished == 1
  end

  def title_and_sender
    "#{title}　[#{uname} (#{ucode})]"
  end

  def sender_name_and_email
    "#{sender.name} <#{sender.email}>" if sender
  end

  def sender_label
    if self.uid == Core.user.id && memo_users.blank?
      ''
    else
      "#{uname} (#{ucode})=>受信"
    end
  end

  def receiver_label
    if self.uid == Core.user.id
      ('送信=>' + memo_users.map {|mu| mu.display_name_with_mobile_class }.join(',　')).html_safe
    else
      ''
    end
  end

  def editable?
    return true
  end

  def deletable?
    return true
  end

  def send_mail_after_addition(uids = nil)
    return if is_system == 1

    receiver_emails = []
    memo_users.preload(:user_property).each do |mu|
      if p = mu.user_property
        receiver_emails << p.mobiles[:kmail] if p.mobiles[:ktrans].to_s == "1" && Gw.is_valid_email_address?(p.mobiles[:kmail])
      end
    end

    settings = AppConfig.gw.memo_mobile_settings
    sender_email = settings[:admin_email_from].presence || "admin@localhost.localdomain"
    subject = settings[:subject]

    receiver_emails.each do |receiver_email|
      Gw::Mailer.memo_mail(from: sender_email, to: receiver_email, subject: "#{subject}#{uname}", item: self).deliver
    end
  end

  private

  def set_user_data
    self.class_id ||= 1
    if sender
      self.ucode = sender.code
      self.uname = sender.name
    end
  end
end
