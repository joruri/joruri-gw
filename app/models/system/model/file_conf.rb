require 'csv'
class System::Model::FileConf
  include ActiveModel::Model

  attr_accessor :encoding, :file, :file_type
  attr_accessor :filename, :content_type, :file_data
  attr_accessor :extras

  def initialize(attrs = {})
    super
    self.extras ||= {}.with_indifferent_access
    self.file_type ||= 'csv'
  end

  def attributes=(attrs = {})
    if attrs
      attrs.each do |name, value|
        send "#{name}=", value
      end
    end
  end

  def encoding_options
    [['SJIS','sjis'],['UTF8','utf8']]
  end

  def internal_nkf_option
    case encoding
    when 'utf8' then '-w -W'
    when 'sjis' then '-w -S'
    end
  end

  def external_nkf_option
    case encoding
    when 'utf8' then '-w -W'
    when 'sjis' then '-s -W'
    end
  end

  def decoded
    NKF::nkf(internal_nkf_option, file_data)
  end

  def encoded
    NKF::nkf(external_nkf_option, file_data)
  end

  def encode(data)
    self.file_data = data
    encoded
  end

  def valid_file?
    if file.blank?
      errors.add(:file, :blank)
      return false
    end

    self.filename = file.original_filename
    self.content_type = file.content_type

    begin
      self.file_data = file.read
      self.file_data = decoded

      CSV.parse(file_data) if self.file_type == 'csv'
    rescue => e
      errors.add(:file, :invalid_file, msg: e.to_s)
      return false
    end
    true
  end
end
