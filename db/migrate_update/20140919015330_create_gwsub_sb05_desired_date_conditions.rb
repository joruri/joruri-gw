class CreateGwsubSb05DesiredDateConditions < ActiveRecord::Migration
  def change
    create_table :gwsub_sb05_desired_date_conditions do |t|
      t.integer :media_id
      t.column  :w1, :tinyint
      t.column  :w2, :tinyint
      t.column  :w3, :tinyint
      t.column  :w4, :tinyint
      t.column  :w5, :tinyint
      t.column  :d0, :tinyint
      t.column  :d1, :tinyint
      t.column  :d2, :tinyint
      t.column  :d3, :tinyint
      t.column  :d4, :tinyint
      t.column  :d5, :tinyint
      t.column  :d6, :tinyint
      t.datetime   :st_at
      t.datetime   :ed_at
    end
  end
end
