class InsertDefaultValuesToGwPropTypes < ActiveRecord::Migration
  def change
    execute <<-SQL
      INSERT INTO `gw_prop_types` (`id`, `state`, `name`, `sort_no`, `restricted`, `user_str`) VALUES
        (100, 'public', '公用車', 100, 0, NULL),
        (200, 'public', '会議室', 200, 0, NULL),
        (300, 'public', '一般備品', 300, 0, NULL),
        (400, 'public', 'テレビ会議室', 400, 1, '拠点');
    SQL
  end
end
