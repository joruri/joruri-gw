class Gwbbs::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Operator
  include Gwboard::Model::Control::Base
  include Gwboard::Model::Control::Auth
  include Gwbbs::Model::Systemname
  include System::Model::Base::Status

  #has_many :adm, :foreign_key => :title_id, :dependent => :destroy
  has_many :role, :foreign_key => :title_id, :dependent => :destroy
  has_many :docs, :foreign_key => :title_id, :dependent => :destroy
  has_many :categories, :foreign_key => :title_id, :dependent => :destroy
  has_many :files, :foreign_key => :title_id

  after_validation :set_icon_file_fields
  before_create :set_notes_field_for_form002, :if => "form_name == 'form002'"
  before_create :set_notes_field_for_form003, :if => "form_name == 'form003'"
  before_create :set_notes_field_for_form006, :if => "form_name == 'form006'"
  before_create :set_notes_field_for_form007, :if => "form_name == 'form007'"
  before_save :set_icon_and_wallpaper_path
  after_save :board_css_create

  validates :state, :recognize, :title, :sort_no, presence: true
  validates :categoey_view_line, presence: true
  validates :default_published, :doc_body_size_capacity, :upload_graphic_file_size_capacity, :upload_document_file_size_capacity, :upload_graphic_file_size_max, :upload_document_file_size_max, 
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :monthly_view_line,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  attr_accessor :_makers
  attr_accessor :_design_publish
  attr_accessor :_upload
  attr_accessor :_update

  def display_category1_name
    category1_name.presence || '分類'
  end

  def gwbbs_form_name
    return 'gwbbs/admin/user_forms/' + self.form_name + '/'
  end

  def use_form_name()
    return [
      ['一般掲示板', 'form001'],
      ['自治研修案内', 'form002'],
      ['おくやみ', 'form003'],
      ['環境マネジメント(事務担当)', 'form004'],
      ['個人情報取扱事務登録簿', 'form005'],
      ['農林土木工事文書掲示板', 'form006'],
      ['NN事業要綱等文書掲示板', 'form007'],
      ['ソフトウェア掲示板', 'form008'],
      ['情報システム調査', 'form009']
    ]
  end

  def set_icon_file_fields
    return if nz(self.icon_position, 0).to_i == 0
    if self._upload.blank?
      if self._update != true
        errors.add :_upload, "ファイルを選択してください。"
        return false
      end
    else
      icon = self._upload
      content_type = icon.content_type
      filename = icon.original_filename
      self.icon_filename = filename
      ex = File.extname(filename)
      ex = ex.upcase unless ex.blank?
      if content_type.index("image").blank? || (ex.blank? || [".bmp", ".gif", ".jpeg", ".jpg", ".png"].index(ex))
        errors.add :_upload, "は、画像ファイル以外のファイルは利用できません。BMP,GIF,JPEG,PNG形式が利用可能です。"
        return false
      end
    end
  end

  def categorys_path
    return self.item_home_path + "categories?title_id=#{self.id}"
  end

  def postindices_path
    return self.item_home_path + "postindices?title_id=#{self.id}"
  end

  def new_upload_path
    return self.item_home_path + "uploads/new?title_id=#{self.id}"
  end

  def docs_path
    return self.item_home_path + "docs?title_id=#{self.id}"
  end

  def adm_show_path
    return self.item_home_path + "makers/#{self.id}"
  end

  def design_publish_path
    return self.item_home_path + "makers/#{self.id}/design_publish"
  end

  def void_destroy_path
    return "#{Core.current_node.public_uri}destroy_void_documents?title_id=#{self.id}"
  end

  def set_icon_and_wallpaper_path
    return unless self._makers

    if nz(self.icon_position, 0).to_i == 0
      begin
        item = Gwboard::Image.find(self.icon_id)
      rescue
        item = nil
      end
      self.icon = ''
      self.icon = item.file_path unless item.blank?
    else
      self.icon_file_save
    end

    begin
      item = Gwboard::Image.find(self.wallpaper_id)
    rescue
      item = nil
    end
    self.wallpaper = ''
    self.wallpaper = item.file_path unless item.blank?
  end

  def icon_file_save
    return if nz(self.icon_position, 0).to_i == 0 || (self._update == false && self.id.blank?)

    @icon_file = self._upload
    unless @icon_file.blank?
      self.icon_filename = @icon_file.original_filename
      @icon_file.rewind
      FileUtils.mkdir_p(icon_f_path) unless FileTest.exist?(icon_f_path)
      File.open(icon_f_name, "wb") { |f|
        f.write @icon_file.read
      }

      self.icon = icon_file_path
    end
    self.itemimage_data_save
  end

  def r_magick(file, itemimage = nil)
    itemimage = self.get_itemimage_data if itemimage.blank?
    begin
    require 'RMagick'
    image = Magick::Image.from_blob(file).shift
    if image.format =~ /(BMP|GIF|JPEG|PNG)/
      itemimage.width = image.columns
      itemimage.height = image.rows
    end
    rescue
    end
  end

  def icon_f_path
    return "#{Rails.root}/public/_attaches/gwbbs_icon/#{self.id}"
  end
  def icon_f_name
    return "#{icon_f_path}/#{self.icon_filename}"
  end
  def icon_f_tmp_path
    return "#{Rails.root}/public/_attaches/gwbbs_icon/tmp"
  end
  def icon_f_tmp_name(filename = self.icon_filename)
    return "#{icon_f_tmp_path}/#{filename}"
  end
  def icon_file_path
    return "/_attaches/gwbbs_icon/#{self.id}/#{self.icon_filename}"
  end
  def get_itemimage_data(type_name = "icon")
    item = Gwbbs::Itemimage.new.find(:first, :conditions => "title_id = #{self.id} and type_name = '#{type_name}'")
    if item.blank?
      return nil
    else
      return item
    end
  end

  def itemimage_data_save
    return if nz(self.icon_position, 0).to_i == 0
    return if @icon_file.blank?
    unless self.get_itemimage_data.blank?
      itemimage = self.get_itemimage_data
      itemimage.type_name = "icon"
      itemimage.filename = @icon_file.original_filename
    else
      itemimage = Gwbbs::Itemimage.new
      itemimage.type_name = "icon"
      itemimage.title_id = self.id
      itemimage.filename = @icon_file.original_filename
    end
    #画像ファイルの時は、縦横情報をセットする
    unless @icon_file.content_type.index("image").blank?
      f = open(icon_f_name, "rb")
      self.r_magick(f.read, itemimage)
      f.close
    end
    itemimage.save(:validate => false)
  end

  def original_css_file
    return "#{Rails.root}/public/_common/themes/gw/css/option.css"
  end

  def board_css_file_path
    return "#{Rails.root}/public/_attaches/css/#{self.system_name}"
  end

  def board_css_preview_path
    return "#{Rails.root}/public/_attaches/css/preview/#{self.system_name}"
  end

  def board_css_create
    ret = false
    ret = true if self._makers
    ret = true if self._design_publish
    return nil unless ret
  end

  def public_docs_count
    docs.select(:id).where(state: 'public').where(['? between able_date and expiry_date', Time.now]).count
  end

  def expired_docs_count
    docs.select(:id).where.not(state: 'preparation').where(['expiry_date < ?', Time.now]).count
  end

private

  def set_notes_field_for_form002
    self.notes_field01 = %([["0", "0"],["1", "1"],["2", "2"],["3", "3"],["4", "4"],["5", "5"],["6", "6"],["7", "7"],["8", "8"],["9", "9"]]) if self.notes_field01.blank?
  end

  def set_notes_field_for_form003
    self.notes_field01 = %([["08:00","08:00"],["08:30","08:30"],["09:00","09:00"],["09:30","09:30"],["10:00","10:00"],["10:30","10:30"],["11:00","11:00"],["11:30","11:30"],["12:00","12:00"],["12:30","12:30"],["13:00","13:00"],["13:30","13:30"],["14:00","14:00"],["14:30","14:30"],["15:00","15:00"],["15:30","15:30"],["16:00","16:00"],["16:30","16:30"],["17:00","17:00"],["17:30","17:30"],["18:00","18:00"],["18:30","18:30"],["19:00","19:00"],["19:30","19:30"]]) if self.notes_field01.blank?
    self.notes_field02 = %([["家族","家族"],["職員","職員"]]) if self.notes_field02.blank?
    self.notes_field03 = %([["通夜入力あり","0"],["通夜入力なし","1"]]) if self.notes_field03.blank?
    self.notes_field05 = %([["家族","家族"],["職員","職員"]]) if self.notes_field05.blank?
  end

  def set_notes_field_for_form006
    self.notes_field01 = %([["共通事項","共通事項"],["農業土木","農業土木"],["森林土木","森林土木"]]) if self.notes_field01.blank?
  end

  def set_notes_field_for_form007
    self.notes_field01 = %([["1管理・指導担当","1管理・指導担当"],["2企画・計画担当","2企画・計画担当"],["3農村環境担当","3農村環境担当"],["4水利担当","4水利担当"],["5整備担当","5整備担当"],["6農道担当","6農道担当"],["7防災担当","7防災担当"],["8国営担当","8国営担当"],["9その他","9その他"],["10農村企画担当","10農村企画担当"],["11活性化担当","11活性化担当"],["12鳥獣被害対策担当","12鳥獣被害対策担当"]]) if self.notes_field01.blank?
  end
end
