class Gwsub::Sb05User < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  has_many :req_rel ,:foreign_key=>:sb05_users_id ,:class_name=>'Gwsub::Sb05Request'

  validates_presence_of   :telephone                              ,:message=>'を、入力してください。'  ,:if=>Proc.new{|item| item.notes_imported != '1'}
  validates_uniqueness_of :user_id ,:scope=>[:org_code,:org_name] ,:message=>'は、登録済です。'       ,:if=>Proc.new{|item| item.notes_imported != '1'}

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save   :before_save_set_display_name

  def before_save_set_display_name
    if self.notes_imported.blank?
      self.user_display = self.user_name.to_s+'('+self.user_code.to_s+')'
    else
      self.user_display = self.user_name.to_s
    end
    self.org_display  = self.org_code.to_s+self.org_name.to_s
  end
  def before_create_setting_columns
    if self.notes_imported.blank?
      Gwsub.gwsub_set_creators(self)
      Gwsub.gwsub_set_editors(self)
    end
  end
  def before_update_setting_columns
    self.notes_imported =nil
    Gwsub.gwsub_set_editors(self)
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v, :user_code,:user_name,:org_code,:org_name,:telephone
#      when 'user_id'
#        search_id v, :user_id if v.to_i != 0
      when 'org_id'
        search_id v, :org_id if v.to_i != 0
      end
    end if params.size != 0

    return self
  end

  def self.alter_table
    connect = self.connection()
    alter_query1 = "ALTER TABLE `gwsub_sb05_users` CHANGE COLUMN `updated_at` `translate_updated_at` DATETIME DEFAULT NULL;"
    connect.execute(alter_query1)
    alter_query2 = "ALTER TABLE `gwsub_sb05_users` CHANGE COLUMN `notes_updated_at` `updated_at` DATETIME DEFAULT NULL;"
    connect.execute(alter_query2)
    return
  end
end
