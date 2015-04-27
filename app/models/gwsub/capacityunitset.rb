class Gwsub::Capacityunitset < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  has_many  :externalusbs  , :foreign_key => :capacityunit_id    ,:class_name=>'Gwsub::Externalusbs'

#  before_validation :before_validates_name_upcase
#  before_validation :before_validate_convert_single

  validates_presence_of       :code,:name
  validates_uniqueness_of     :code,:name
  validates_length_of         :code,:name       , :maximum=>5      , :too_long=> 'は、5 文字以内で入力してください。'
  # numericality : floar or integer[ regular expression (/\A[+\-]?\d+\Z/)]
  validates_numericality_of   :code                               , :message => "は、半角数字で入力してください"

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save    :before_save_set_columns

#  def before_validate_convert_single
#    self.code = Gw.chop_with(self.code,'"')
#    self.code = Gwsub.convert_char_ascii(self.code)
#    self.code_int = self.code.to_i
##    pp [self.code ,self.code_int]
#  end
#  def before_validates_name_upcase
#    self.name = self.name.to_s.upcase
#  end

  def before_save_set_columns
    self.code     = Gwsub.convert_char_ascii(self.code)
    self.code_int = self.code.to_i
    self.name     = self.name.to_s.upcase
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v, :name,:code
      end
    end if params.size != 0

    return self
  end

  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_capacityunitsets` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_capacityunitsets` (
      `id`            int(11)  NOT NULL auto_increment,
      `code_int`      int(11)  default NULL,
      `code`          text     default NULL,
      `name`          text     default NULL,
      `updated_at`    datetime default NULL,
      `updated_user`  text     default NULL,
      `updated_group` text     default NULL,
      `created_at`    datetime default NULL,
      `created_user`  text     default NULL,
      `created_group` text     default NULL,
      PRIMARY KEY  (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    connect.execute(create_query)
    return
  end

  def home_path
    return '/gwsub/sb12/capacityunitsets/'
  end

  def show_path
    return "#{self.home_path}#{self.id}"
  end

end
