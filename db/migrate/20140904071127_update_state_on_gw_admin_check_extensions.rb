class UpdateStateOnGwAdminCheckExtensions < ActiveRecord::Migration
  def change
    Gw::AdminCheckExtension.update_all(:state => 'disabled')
  end
end
