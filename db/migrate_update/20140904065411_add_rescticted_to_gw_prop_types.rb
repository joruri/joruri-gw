class AddResctictedToGwPropTypes < ActiveRecord::Migration
  def change
    add_column :gw_prop_types , :restricted, :integer
    add_column :gw_prop_types , :user_str ,  :text
    Gw::PropType.update_all(:restricted=>0)
  end
end
