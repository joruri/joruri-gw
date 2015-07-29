# encoding: utf-8
class Gw::EditTabPublicRole < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  
  belongs_to :edit_tab, :foreign_key => :edit_tab_id, :class_name => 'Gw::EditTab'
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :uid, :class_name => 'System::Group'

end
