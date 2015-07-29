# encoding: utf-8
class Gw::AdminMode < Gw::UserProperty
  default_scope { where(:class_id => 3, :name => 'portal') }
  scope :portal_mode_type, -> { where(:type_name => 'mode').order('updated_at desc') }
  scope :portal_disaster_bbs_type, -> { where(:type_name => 'disaster_bbs').order('updated_at desc') }

  def portal_mode_options
    [["通常時",2],["災害時",3]]
  end

  def portal_mode_label
    portal_mode_options.rassoc(options.to_i).try(:first)
  end

  def portal_disaster_bbs_options
    Gwbbs::Control.where(:state => 'public').order(:sort_no)
  end

  def portal_disaster_bbs_label
    Gwbbs::Control.where(:id => options.to_i).first.try(:title)
  end

  def self.is_disaster_admin?( uid = Site.user.id )
    System::Model::Role.get(1, uid ,'disaster_admin', 'admin')
  end

  def self.is_disaster_editor?( uid = Site.user.id )
    System::Model::Role.get(1, uid ,'disaster_admin', 'editor')
  end

  def self.portal_mode
    self.portal_mode_type.first || self.new(:class_id => 3, :name => 'portal', :type_name => 'mode', :options => '2')
  end

  def self.portal_disaster_bbs
   self.portal_disaster_bbs_type.first || self.new(:class_id => 3, :name => 'portal', :type_name => 'disaster_bbs', :options => '')
  end
end
