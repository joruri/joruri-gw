module Gwboard::Model::Doc::Base
  extend ActiveSupport::Concern

  included do
    attr_accessor :skip_updating_updated_at

    with_options unless: :state_preparation? do |f|
      f.before_save :set_attachmentfile_count
      f.after_save :update_docslast_updated_at
    end
    scope :without_preparation, -> { where.not(state: 'preparation') }
    scope :latest_updated_since, ->(time = Date.today) {
      where(arel_table[:latest_updated_at].gteq(time))
    }
    scope :with_notification_enabled, ->(user = Core.user) { 
      joins(:control).where(control_klass.arel_table[:notification].eq(1))
    }
  end

  def stata_options
    [['下書き','draft'],['承認待ち','recognize'],['承認済み','recognized'],['公開','public']]
  end

  def state_preparation?
    state == 'preparation'
  end

  def state_draft?
    state == 'draft'
  end

  def state_recognize?
    state == 'recognize'
  end

  def state_recognized?
    state == 'recognized'
  end

  def state_public?
    state == 'public'
  end

  def category_use?
    category_use == 1
  end

  def compress_files(options = {encoding: 'Shift_JIS'})
    file_options = files.map {|f| {filename: "#{f.id}_#{f.filename}", filepath: f.f_name} }
    Gw.compress_files(file_options, options)
  end

  def save(args = {})
    if self.skip_updating_updated_at == "1"
      flags = disable_record_timestamps
    end
    ret = super
  ensure
    if self.skip_updating_updated_at == "1"
      revert_record_timestamps(flags)
    end
    ret
  end

  module ClassMethods
    def control_klass
      reflect_on_association(:control).klass
    end

    def role_klass
      reflect_on_association(:roles).klass
    end

    def recognizer_klass
      reflect_on_association(:recognizers).klass
    end

    def folder_klass
      reflect_on_association(:folder).klass
    end

    def folder_acl_klass
      reflect_on_association(:folder_acls).klass
    end
  end

  private

  def disable_record_timestamps
    flags = [self.class.record_timestamps, control.class.record_timestamps]
    self.class.record_timestamps = false
    control.class.record_timestamps = false
    flags
  end

  def revert_record_timestamps(flags)
    self.class.record_timestamps = flags[0] unless flags[0].nil?
    control.class.record_timestamps = flag[1] unless flags[1].nil?
  end

  def set_attachmentfile_count
    self.attachmentfile = files.count
  end

  def update_docslast_updated_at
    if self.state == 'public' && self.latest_updated_at_changed?
      control.update_columns(docslast_updated_at: Time.now)
    end
  end
end
