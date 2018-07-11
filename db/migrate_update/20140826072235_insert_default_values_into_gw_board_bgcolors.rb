class InsertDefaultValuesIntoGwBoardBgcolors < ActiveRecord::Migration
  def change
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#FFFCF0", :color_code_hex => "#FFFCF0", :color_code_class => "bgColor1", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#FFE580", :color_code_hex => "#FFE580", :color_code_class => "bgColor2", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#C9DCFF", :color_code_hex => "#C9DCFF", :color_code_class => "bgColor3", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#0059FF", :color_code_hex => "#0059FF", :color_code_class => "bgColor4", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#8875C9", :color_code_hex => "#8875C9", :color_code_class => "bgColor5", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#D2FFB2", :color_code_hex => "#D2FFB2", :color_code_class => "bgColor6", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#FFD4EA", :color_code_hex => "#FFD4EA", :color_code_class => "bgColor7", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#FF3333", :color_code_hex => "#FF3333", :color_code_class => "bgColor8", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#FFFFFF", :color_code_hex => "#FFFFFF", :color_code_class => "bgColor9", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#660000", :color_code_hex => "#660000", :color_code_class => "bgColor10", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#222222", :color_code_hex => "#222222", :color_code_class => "bgColor11", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 0, :state => "public", :title => "#C9C9C9", :color_code_hex => "#C9C9C9", :color_code_class => "bgColor12", :pair_font_color => "#000000"

    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#FFFCF0", :color_code_hex => "#FFFCF0", :color_code_class => "bgColor1", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#FFE580", :color_code_hex => "#FFE580", :color_code_class => "bgColor2", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#C9DCFF", :color_code_hex => "#C9DCFF", :color_code_class => "bgColor3", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#0059FF", :color_code_hex => "#0059FF", :color_code_class => "bgColor4", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#8875C9", :color_code_hex => "#8875C9", :color_code_class => "bgColor5", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#D2FFB2", :color_code_hex => "#D2FFB2", :color_code_class => "bgColor6", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#FFD4EA", :color_code_hex => "#FFD4EA", :color_code_class => "bgColor7", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#FF3333", :color_code_hex => "#FF3333", :color_code_class => "bgColor8", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#FFFFFF", :color_code_hex => "#FFFFFF", :color_code_class => "bgColor9", :pair_font_color => "#000000"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#660000", :color_code_hex => "#660000", :color_code_class => "bgColor10", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#000000", :color_code_hex => "#000000", :color_code_class => "bgColor11", :pair_font_color => "#FFFFFF"
    Gwboard::Bgcolor.create :content_id => 1, :state => "public", :title => "#C9C9C9", :color_code_hex => "#C9C9C9", :color_code_class => "bgColor12", :pair_font_color => "#000000"
  end
end
