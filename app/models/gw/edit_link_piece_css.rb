# encoding: utf-8
class Gw::EditLinkPieceCss < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of     :css_name, :css_class

  has_many :css_piece, :class_name => 'Gw::EditLinkPiece' , :foreign_key => :block_css_id
  has_many :icon_piece, :class_name => 'Gw::EditLinkPiece' , :foreign_key => :block_icon_id

  def self.selectbox_id_list_css

    items = self.find(:all, :order=>"css_sort_no", :conditions=>"state != 'deleted' and css_type = 1")

    list = [['', '']]
    items.each do |item|
      list << [item.css_name + "(#{item.css_class})" , item.id]
    end

    return list
  end

  def self.selectbox_id_list_cssicon

    items = self.find(:all, :order=>"css_sort_no", :conditions=>"state != 'deleted' and css_type = 2")

    list = [['', '']]
    items.each do |item|
      list << [item.css_name + "(#{item.css_class})" , item.id]
    end

    return list
  end

  def self.state_select
    status = [['有効','enabled'],['無効','disabled']]
    return status
  end

  def self.state_show(state)
    status = [['deleted','削除済'],['disabled','無効'],['enabled','有効']]
    show_str = status.assoc(state)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.css_type_select
    status = [['デザイン用', 1],['アイコン用', 2]]
    return status
  end

  def self.css_type_show(css_type)
    status = [[1,'デザイン用'],[2,'アイコン用']]
    show_str = status.assoc(css_type)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end
end
