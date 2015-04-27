class Gw::Property::MemoMobileMail < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  validates :kmail, presence: true, if: "ktrans == '1'"
  validate :validate_email, if: "ktrans == '1'"

  def default_attributes
    { class_id: 1, name: "mobile", type_name: "json" }
  end

  def default_options
    { mobiles: { ktrans: '2', kmail: '' } }
  end

  def mobiles
    options_value['mobiles'] || {}
  end

  def kmail
    mobiles['kmail']
  end

  def ktrans
    mobiles['ktrans']
  end

  def is_email_mobile?
    kmail.present? && ktrans == '1' && Gw::MemoMobile.is_email_mobile?(kmail)
  end

  private

  def validate_email
    errors.add(:kmail, 'は正しいEメールアドレスではありません。') if Gw.is_valid_email_address?(kmail) == 0
  end
end
