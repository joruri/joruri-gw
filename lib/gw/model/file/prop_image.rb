require 'RMagick'
module Gw::Model::File::PropImage
  extend ActiveSupport::Concern

  included do
    attr_accessor :file, :file_data

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
      errors.add(:base, "ファイル名が長すぎます。(#{self.orig_filename})")
    else
      errors.add(:base, e.to_s)
    end
    return false
  end

  def image_size_info
    size = File.stat(full_file_path).size.to_f
    img = Magick::ImageList.new(full_file_path)
    return {size: size, width: img.columns, height: img.rows}
  rescue
    nil
  end

  private

  def public_base_dir
    File.join(Rails.root, 'public')
  end

  def upload_dir
    "/_attaches/#{self.class.to_s.tableize.gsub('/','_').gsub('_images','').pluralize}/#{self.parent_id}/"
  end

  def full_file_path
    File.join(public_base_dir, self.path) if self.path.present?
  end

  def full_file_dir
    File.join(public_base_dir, upload_dir)
  end

  def set_values_from_file
    return unless self.file

    self.content_type = self.file.content_type
    self.orig_filename = self.file.original_filename

    self.file_data = self.file.read
  end

  def validate_file
    return unless self.file

    if self.content_type !~ /^image\//
      errors.add(:file, 'は画像データをアップロードしてください。')
    end
  end

  def upload_internal_file
    return unless self.file_data

    idx = self.class.where(parent_id: self.parent_id).maximum(:idx).to_i + 1 

    file_name = "#{idx}#{File.extname(self.orig_filename)}"
    file_path = File.join(upload_dir, file_name)
    self.update_columns(idx: idx, path: file_path)

    FileUtils.mkdir_p(full_file_dir) unless FileTest.exist?(full_file_dir)
    File.open(full_file_path, "wb") { |f| f.write(self.file_data) }
  rescue => e
    error_log e
    raise e
  end

  def remove_internal_file
    FileUtils.remove_entry(full_file_path)
  rescue => e
    error_log e
    raise e
  end
end
