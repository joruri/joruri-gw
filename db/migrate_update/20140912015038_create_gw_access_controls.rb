class CreateGwAccessControls < ActiveRecord::Migration
  def change
    create_table :gw_access_controls do |t|
      t.string  :state
      t.integer :user_id
      t.text    :path
      t.integer :priority
      t.timestamps
    end
    add_index :gw_access_controls, [:state, :user_id]
  end
end
