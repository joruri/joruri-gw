class Gwsub::Externalmediakind < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  has_many :externalmedias , :primary_key=>:id , :foreign_key => :externalmediakind_id , :class_name=>'Gwsub::Externalmedia' , :dependent=>:nullify

#  before_validation :before_validate_convert_single

  validates_presence_of   :kind,:name,:sort_order
  validates_uniqueness_of :kind

  validates_length_of     :kind         , :maximum => 50  , :too_long => "は、50文字以内で入力してください"
  validates_length_of     :name         , :maximum => 50  , :too_long => "は、50文字以内で入力してください"
  validates_length_of     :sort_order   , :maximum => 5   , :too_long => "は、5文字以内で入力してください"
  # numericality : floar or integer[ regular expression (/\A[+\-]?\d+\Z/)]
  validates_numericality_of   :sort_order                , :message => "は、半角数字で入力してください"

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save    :before_save_set_columns

#  def before_validate_convert_single
#    self.sort_order = Gw.chop_with(self.sort_order,'"')
#    self.sort_order = Gwsub.convert_char_ascii(self.sort_order)
#    self.sort_order_int = self.sort_order.to_i
##    pp [self.sort_order ,self.sort_order_int]
#  end

  def before_save_set_columns
    self.sort_order     = Gwsub.convert_char_ascii(self.sort_order)
    self.sort_order_int = self.sort_order.to_i
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
        search_keyword v, :kind,:name,:sort_order,:sort_order_int
      end
    end if params.size != 0

    return self
  end

  def self.drop_create_table
    _connect = self.connection()
    _drop_query = "DROP TABLE IF EXISTS `gwsub_externalmediakinds` ;"
    _connect.execute(_drop_query)
    _create_query = "CREATE TABLE `gwsub_externalmediakinds` (
      `id`             int(11)  NOT NULL auto_increment,
      `sort_order_int` int(11)  default NULL,
      `sort_order`     text     default NULL,
      `kind`           text     default NULL,
      `name`           text     default NULL,
      `updated_at`     datetime default NULL,
      `updated_user`   text     default NULL,
      `updated_group`  text     default NULL,
      `created_at`     datetime default NULL,
      `created_user`   text     default NULL,
      `created_group`  text     default NULL,
      PRIMARY KEY  (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    _connect.execute(_create_query)
    return
  end

  def home_path
    return '/gwsub/sb13/externalmediakinds/'
  end

  def show_path
    return "#{self.home_path}#{self.id}"
  end

end
