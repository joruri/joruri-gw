class Gw::EditLinkPieceCss < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Cache::EditLinkPiece

  has_many :css_piece, :class_name => 'Gw::EditLinkPiece', :foreign_key => :block_css_id
  has_many :icon_piece, :class_name => 'Gw::EditLinkPiece', :foreign_key => :block_icon_id

  validates :css_name, :css_class, presence: true

  default_scope { where.not(state: 'deleted') }

  def self.state_select
    [['有効','enabled'],['無効','disabled']]
  end

  def self.state_show(state)
    status = state_select + ['削除済','deleted']
    status.rassoc(state).try(:first)
  end

  def self.css_type_select
    [['デザイン用', 1],['アイコン用', 2]]
  end

  def self.css_type_show(css_type)
    css_type_select.rassoc(css_type).try(:first)
  end

  def self.selectbox_id_list_css
    self.where(css_type: 1).order(:css_sort_no).map {|item| ["#{item.css_name}(#{item.css_class})", item.id] }
  end

  def self.selectbox_id_list_cssicon
    self.where(css_type: 2).order(:css_sort_no).map {|item| ["#{item.css_name}(#{item.css_class})", item.id] }
  end
end
