class CreateGwsubSb04Settings < ActiveRecord::Migration
  def change
    create_table :gwsub_sb04_settings do |t|
      t.string :name, :limit => 255
      t.string :type_name, :limit => 255
      t.text :data
      t.text :updated_user
      t.text :updated_group
      t.timestamps
    end
    execute <<-SQL
      INSERT INTO `gwsub_sb04_settings` (`name`, `type_name`, `data`, `created_at`, `updated_at`, `updated_user`, `updated_group`) VALUES
        ('network_telephone_url', 'url', '', now(), now(), 'システム', 'システム');
    SQL
  end
end
