class CreateReminderExternals < ActiveRecord::Migration
  def change
    create_table :gw_reminder_externals do |t|
      t.text     :system
      t.text     :data_id
      t.text     :title
      t.datetime :updated
      t.text     :link
      t.text     :author
      t.text     :contributor
      t.text     :member
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :deleted_at
    end

    create_table :gw_reminder_external_systems do |t|
      t.string   :code
      t.string   :name
      t.string   :user_id
      t.string   :password
      t.string   :sso_user_field
      t.string   :sso_pass_field
      t.string   :css_name
      t.timestamps
    end
  end
end
