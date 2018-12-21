class CreateGwPrefSoumuMessages < ActiveRecord::Migration
  def change
    create_table :gw_pref_soumu_messages do |t|
      t.timestamps
      t.text       :body
      t.integer    :sort_no
      t.integer    :state
      t.integer    :tab_keys
    end
  end
end
