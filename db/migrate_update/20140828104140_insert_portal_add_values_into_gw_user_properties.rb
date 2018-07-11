class InsertPortalAddValuesIntoGwUserProperties < ActiveRecord::Migration
  def change
    Gw::UserProperty.where(:class_id => 3, :uid => 'portal_add', :name => 'portal_disp_limit', :type_name => 'json').first_or_create(:options => '[["3"],["4"],["3"]]')
    Gw::UserProperty.where(:class_id => 3, :uid => 'portal_add', :name => 'portal_disp_option', :type_name => 'json').first_or_create(:options => '[["opened"],["opened"],["opened"]]')
    Gw::UserProperty.where(:class_id => 3, :uid => 'portal_add', :name => 'portal_disp_pattern', :type_name => 'json').first_or_create(:options => '4')
  end
end
