class InsertDefautValuesToGwsubSb06Budgets < ActiveRecord::Migration
  def change
    Gwsub::Sb06BudgetRole.where(:code => '1').first_or_create(:name => "システム管理者")
    Gwsub::Sb06BudgetRole.where(:code => '2').first_or_create(:name => "財政課　更新")
    Gwsub::Sb06BudgetRole.where(:code => '3').first_or_create(:name => "財政課　照会")
    Gwsub::Sb06BudgetRole.where(:code => '4').first_or_create(:name => "主管課　更新")
    Gwsub::Sb06BudgetRole.where(:code => '5').first_or_create(:name => "主管課　照会")
    Gwsub::Sb06BudgetRole.where(:code => '6').first_or_create(:name => "原課　更新")
    Gwsub::Sb06BudgetRole.where(:code => '7').first_or_create(:name => "原課　照会")
  end
end
