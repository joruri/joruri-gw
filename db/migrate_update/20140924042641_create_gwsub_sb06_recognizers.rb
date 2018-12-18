class CreateGwsubSb06Recognizers < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_recognizers do |t|
      t.integer :parent_id
      t.integer :user_id
      t.text   :recognized_at
      t.integer :mode
      t.timestamps
    end
  end
end
