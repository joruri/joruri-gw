module Gwboard::Model::Doc::Recognizer
  extend ActiveSupport::Concern

  included do
    attr_accessor :selected_recognizer_uids
    with_options if: :state_recognize? do |f|
      f.validate :validate_recognizers
      f.after_save :save_recognizers
      f.after_save :add_memo_for_recognizers
    end
  end

  def selected_recognizer_options
    self.selected_recognizer_uids ||= recognizers.map(&:user_id)
    System::User.select(:id, :code, :name).where(id: selected_recognizer_uids)
      .order(:code).map{|u| [u.display_name, u.id] }
  end

  def recognize(user = Core.user)
    recognizers.where(code: user.code).update_all(recognized_at: Time.now)

    if recognizers.all?(&:recognized?)
      self.state = 'recognized'
      self.recognized_at = Time.now
      self.skip_setting_creater_editor = true
      self.save

      if (user = System::User.where(code: self.editor_id).first)
        Gw.add_memo(user.id, "#{control.title}「#{self.title}」について、全ての承認が終了しました。", 
          %(次のボタンから記事を確認し,公開作業を行ってください。<br /><a href="#{publish_path}"><img src="/_common/themes/gw/files/bt_openconfirm.gif" alt="公開処理へ" /></a>), is_system: 1)
      end
    end
  end

  def publish
    self.state = 'public'
    self.published_at = Time.now
    self.skip_setting_creater_editor = true
    self.save
    self
  end

  private

  def recognize_path
    "/#{system_name}/docs/#{self.id}/?title_id=#{self.title_id}&state=RECOGNIZE"
  end

  def publish_path
    "/#{system_name}/docs/#{self.id}/?title_id=#{self.title_id}&state=PUBLISH"
  end

  def validate_recognizers
    self.selected_recognizer_uids = selected_recognizer_uids.reject(&:blank?).map(&:to_i)
    if selected_recognizer_uids.blank?
      errors.add(:recognizers, 'を設定してください。')
    end
  end

  def save_recognizers
    if selected_recognizer_uids.present?
      recognizers.destroy_all
      System::User.where(id: selected_recognizer_uids).each do |user|
        recognizers.create(
          title_id: self.title_id,
          user_id: user.id,
          code: user.code,
          name: "#{user.name}(#{user.code})"
        )
      end
    end
  end

  def add_memo_for_recognizers
    if selected_recognizer_uids.present?
      recognizers.each do |recognizer|
        Gw.add_memo(recognizer.user_id, "#{self.control.title}「#{self.title}」についての承認依頼が届きました。", 
          %(次のボタンから記事を確認し,承認作業を行ってください。<br /><a href="#{recognize_path}"><img src="/_common/themes/gw/files/bt_approvalconfirm.gif" alt="承認処理へ" /></a>), is_system: 1)
      end
    end
  end
end
