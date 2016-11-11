module Gw::Model::File::Base
  extend ActiveSupport::Concern

  included do
    attr_accessor :file, :file_data
    attr_accessor :accept_only_image_file, :accept_file_extensions

    before_validation :set_values_from_file
    after_save :upload_internal_file
    after_destroy :remove_internal_file

    validates :file, presence: { message: "を指定してください。" }, on: :create
    validate :validate_file
  end

  def save(args = {})
    super(args)
  rescue => e
    if e.class == Errno::ENAMETOOLONG
      errors.add(:base, "ファイル名が長すぎます。(#{self.original_file_name})")
    else
      errors.add(:base, e.to_s)
    end
    return false
  end

  private

  def public_base_dir
    File.join(Rails.root, 'public')
  end

  def upload_dir
    "/_attaches/#{self.class.to_s.tableize}/"
  end

  def full_file_dir
    File.join(public_base_dir, self.file_directory) if self.file_directory.present?
  end

  def full_file_path
    File.join(public_base_dir, self.file_path) if self.file_path.present?
  end

  def set_values_from_file
    return unless self.file

    self.content_type = self.file.content_type
    self.original_file_name = self.file.original_filename
    self.width = 0
    self.height = 0

    self.file_data = self.file.read

    if self.content_type =~ /^image\//
      begin
        require 'rmagick'
        image = Magick::Image.from_blob(self.file_data).shift
        if image.format =~ /(GIF|JPEG|PNG)/
          self.width = image.columns
          self.height = image.rows
        end
      rescue
        errors.add(:file, 'は画像として認識できませんでした。') if accept_only_image_file
      end
    end
  end

  def validate_file
    return unless self.file

    if accept_only_image_file
      if self.content_type !~ /^image\//
        errors.add(:file, 'は画像データをアップロードしてください。')
      end
    end

    if accept_file_extensions.present?
      ext = File.extname(self.original_file_name)
      if ext.blank? || !ext.in?(accept_file_extensions)
        errors.add(:file, "は#{accept_file_extensions.join(', ')}の拡張子のファイルをアップロードしてください。")
      end
    end
  end

  def upload_internal_file
    return unless self.file_data

    full_file_path_was = full_file_path

    file_directory = File.join(upload_dir, self.id.to_s)
    file_name = "#{self.id}#{File.extname(self.original_file_name)}"
    file_path = File.join(file_directory, file_name)
    self.update_columns(file_directory: file_directory, file_name: file_name, file_path: file_path)

    FileUtils.mkdir_p(full_file_dir) unless FileTest.exist?(full_file_dir)
    FileUtils.remove_entry(full_file_path_was) if full_file_path_was.present? && FileTest.exist?(full_file_path_was)
    File.open(full_file_path, "wb") { |f| f.write(self.file_data) }
  rescue => e
    error_log e
    raise e
  end

  def remove_internal_file
    FileUtils.remove_entry(full_file_dir)
  rescue => e
    error_log e
    raise e
  end
end
