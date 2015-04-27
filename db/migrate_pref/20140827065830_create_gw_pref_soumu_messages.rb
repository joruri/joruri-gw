class CreateGwPrefSoumuMessages < ActiveRecord::Migration
  def change
    #create_table :gw_pref_soumu_messages do |t|
    #  t.timestamps
    #  t.text       :body
    #  t.integer    :sort_no
    #  t.integer    :state
    #  t.integer    :tab_keys
    #end
    add_column :gw_pref_soumu_messages, :tab_keys, :integer
  end
end
