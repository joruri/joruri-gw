# -*- encoding: utf-8 -*-
class Gwboard::Theme < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :icon_pict , :foreign_key => :icon_id  ,:class_name=>'Gwboard::Image'
  belongs_to :wall_pict , :foreign_key => :wallpaper_id  ,:class_name=>'Gwboard::Image'

  after_validation :name_check
  before_save :set_graphic_file_path, :params_update
  after_save :theme_css_create

  def system_name
    return 'themes'
  end

  def bg_select
    {'0' => '背景色を使用する', '1' => '背景画像を使用する'}
  end

  def item_path
    return "/gwboard/theme_registries"
  end
  def show_path
    return "#{item_path}/#{self.id}"
  end
  def edit_path
    return "#{item_path}/#{self.id}/edit"
  end
  def delete_path
    return "#{item_path}#{self.id}"
  end

  def name_check
    return unless self.state == 'public'

    if self.if_name.blank?
      errors.add :if_name, "を入力してください。"
    end
  end

  def is_change?
    return false unless self.content_id == 3

    s1 = "#{self.name}#{self.icon_id}#{self.icon}#{self.bg_setup}#{self.font_color}#{self.wallpaper_id}#{self.wallpaper}#{self.css}"
    s2 = "#{self.if_name}#{self.if_icon_id}#{self.if_icon}#{self.if_bg_setup}#{self.if_font_color}#{self.if_wallpaper_id}#{self.if_wallpaper}#{self.if_css}"
    ret = false
    ret = true unless s1 == s2
    return ret
  end

  def set_graphic_file_path
    if self.if_bg_setup == 0
      self.if_wallpaper_id  = ''
    else
      self.if_css = ''
    end

    self.if_icon = ''
    unless self.if_icon_id.blank?
      item = Gwboard::Image.find_by_id(self.if_icon_id)
      self.if_icon = item.file_path unless item.blank?
    end

    self.if_wallpaper = ''
    unless self.if_wallpaper_id.blank?
      item = Gwboard::Image.find(self.if_wallpaper_id)
      self.if_wallpaper = item.file_path unless item.blank?
    end
  end

  def params_update
    if self.state == 'reset'
      params_reset
      return
    else
      flg = false
      if self.state == 'prev'
        flg = true
      end if self.content_id == 1
      flg = true if self.state == 'public'

      return unless flg

      self.name = self.if_name
      self.icon_id = self.if_icon_id
      self.icon = self.if_icon
      self.bg_setup = self.if_bg_setup
      self.font_color = self.if_font_color
      self.wallpaper_id = self.if_wallpaper_id
      self.wallpaper = self.if_wallpaper
      self.css = self.if_css
    end
  end

  def params_reset
    self.state = 'public'
    self.content_id = 7
    self.if_name = self.name
    self.if_icon_id = self.icon_id
    self.if_icon = self.icon
    self.if_bg_setup = self.bg_setup
    self.if_font_color = self.font_color
    self.if_wallpaper_id = self.wallpaper_id
    self.if_wallpaper = self.wallpaper
    self.if_css = self.css
  end

  def params_check_and_reset
    if self.content_id == 3
      self.state = 'public'
      self.content_id = 7
      self.if_name = self.name
      self.if_icon_id = self.icon_id
      self.if_icon = self.icon
      self.if_bg_setup = self.bg_setup
      self.if_font_color = self.font_color
      self.if_wallpaper_id = self.wallpaper_id
      self.if_wallpaper = self.wallpaper
      self.if_css = self.css
      self.save
    end
  end

  def original_css_file
    return "#{RAILS_ROOT}/public/_common/themes/gw/css/option.css"
  end

  def board_css_file_path
    return "#{RAILS_ROOT}/public/_attaches/css/#{self.system_name}"
  end

  def theme_css_create(css_path=nil)

    tmp = File.read(original_css_file)
    if self.if_bg_setup == 0
      tmp = tmp.gsub(/#FFFCF0/,self.if_css)
      tmp = tmp.gsub(/#000000/,self.if_font_color)
      tmp = tmp.gsub(/_BGIMG_URL_/,'/')
    else
      if self.if_wallpaper.blank?
        tmp = tmp.gsub(/_BGIMG_URL_/,'/')
      else
        tmp = tmp.gsub(/_BGIMG_URL_/,self.if_wallpaper)
      end
      tmp = tmp.gsub(/#000000/,self.if_font_color)
    end
    if self.if_icon.blank?
      tmp = tmp.gsub(/_ICON_URL_/,'/')
    else
      tmp = tmp.gsub(/_ICON_URL_/,self.if_icon)
    end
    if css_path.blank?
      f_path = self.board_css_file_path
      FileUtils.mkdir_p(f_path) unless FileTest.exist?(f_path)
      f_path = "#{f_path}/#{self.id}.css"
    else
      f_path = css_path
    end

    File::delete(f_path)  if FileTest.exist?(f_path)
    File.open(f_path, "w") { |f|
      f.write tmp
    }
  end

end
