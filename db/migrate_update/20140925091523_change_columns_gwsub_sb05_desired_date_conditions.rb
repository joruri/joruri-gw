class ChangeColumnsGwsubSb05DesiredDateConditions < ActiveRecord::Migration
  def change
      change_column(:gwsub_sb05_desired_date_conditions,:w1, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:w2, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:w3, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:w4, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:w5, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:d0, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:d1, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:d2, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:d3, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:d4, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:d5, :boolean, default: false)
      change_column(:gwsub_sb05_desired_date_conditions,:d6, :boolean, default: false)
      add_column :gwsub_sb05_desired_date_conditions, :created_at, :datetime
      add_column :gwsub_sb05_desired_date_conditions, :updated_at, :datetime
  end
end
