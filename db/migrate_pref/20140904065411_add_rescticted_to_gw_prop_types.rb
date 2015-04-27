class AddResctictedToGwPropTypes < ActiveRecord::Migration
  def change
    create_table "gw_prop_types" do |t|
      t.string   "state"
      t.string   "name"
      t.integer  "sort_no"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.integer  "restricted"
      t.text     "user_str"
    end
  end
end
