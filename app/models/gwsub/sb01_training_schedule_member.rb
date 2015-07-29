# -*- encoding: utf-8 -*-
class Gwsub::Sb01TrainingScheduleMember < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :training_rel   ,:foreign_key=>'training_schedule_id'  ,:class_name=>"Gwsub::Sb01TrainingSchedule"
  belongs_to :user_rel1      ,:foreign_key=>'training_user_id'      ,:class_name=>"System::User"
  belongs_to :group_rel1     ,:foreign_key=>'training_group_id'     ,:class_name=>"System::Group"
  belongs_to :user_rel2      ,:foreign_key=>'entry_user_id'         ,:class_name=>"System::User"
  belongs_to :group_rel2     ,:foreign_key=>'entry_group_id'        ,:class_name=>"System::Group"

  validates_presence_of     :training_group_id
  validates_presence_of     :entry_user_id

  validates_presence_of     :training_user_id
  validates_uniqueness_of   :training_user_id ,:scope=>:training_schedule_id  ,:message=>"は、すでに登録済です。"
  #validates_each :training_user_id do |record, attr, value|
  #  record.errors.add attr, 'は、登録済です。' unless Gwsub::Sb01TrainingScheduleProp.count(:all,:conditions=>"member_id=#{value}")==0
  #end
  validates_presence_of     :training_user_tel

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

	#研修を受けるユーザ名
	def training_user_name
		return self.user_rel1.name
	end

	#研修を受けるユーザの所属名
	def training_user_group_name
		return self.group_rel1.name
	end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:updated_user
      end
    end if params.size != 0

    return self
  end

#  def self.drop_create_table
#    connect = self.connection()
#    drop_query = "DROP TABLE IF EXISTS `gwsub_sb01_training_schedule_members` ;"
#    connect.execute(drop_query)
#    create_query = "CREATE TABLE `gwsub_sb01_training_schedule_members` (
#      `id`                    int(11) NOT NULL auto_increment,
#      `training_schedule_id`  int(11) default NULL,
#      `training_user_id`      int(11) default NULL,
#      `training_group_id`     int(11) default NULL,
#      `entry_user_id`         int(11) default NULL,
#      `entry_group_id`        int(11) default NULL,
#      `updated_at`            datetime default NULL,
#      `updated_user`          text default NULL,
#      `updated_group`         text default NULL,
#      `created_at`            datetime default NULL,
#      `created_user`          text default NULL,
#      `created_group`         text default NULL,
#      PRIMARY KEY  (`id`)
#    ) DEFAULT CHARSET=utf8;"
#    connect.execute(create_query)
#    return
#  end
end
