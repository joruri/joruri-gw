class Gwsub::Externalusb < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :group , :foreign_key => :section_id  ,:class_name=>'Gwsub::Sb12Group'
  belongs_to :capacityunitset   , :foreign_key => :capacityunit_id      ,:class_name=>'Gwsub::Capacityunitset'
  belongs_to :externalmediakind , :foreign_key => :externalmediakind_id ,:class_name=>'Gwsub::Externalmediakind'

  before_validation :before_validates_registedno_upcase
  after_validation :validate_section_id #registednoが必須で無くなったので、ここでチェックしている

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  before_save :set_section_name, :set_user_name
  after_save :group_update

  validates :registed_at, :equipmentname, :externalmediakind_id, :section_id, presence: true
  validates :equipmentname, length: {maximum: 80, too_long: 'は、80文字以内で入力してください。'}
  validates :remarks, length: {maximum: 50, too_long: 'は、50文字以内で入力してください。'}, allow_nil: true

  validates :capacity, format: {with: /\A[0-9]{1,4}\z/, message: "は、半角数字4桁以内で入力してください。"}, if: lambda {|x| x.capacity.present?}
  validates :capacity, format: {with: /\A[^0]+[0-9]+\z/, message: "は、前0なしで入力してください。"}, if: lambda {|x| x.capacity.present?}

  validates :registedno, length: {maximum: 20, too_long: 'は、20文字以内で入力してください。'}, if: lambda {|x| x.registedno.present?}
  validates :registedno, format: {with: /\A[0-9a-zA-Z-]+\z/, message: "は、半角英数字で入力してください。"}, if: lambda {|x| x.registedno.present?}
  validates :new_registedno, presence: true, if: lambda {|x| !x._is_new}
  validates :new_registedno, numericality: {only_integer: true, greater_than_or_equal_to: 0}, allow_nil: true

  attr_accessor :_is_new

  def self.categories_search
#    { 'exist'   =>  '分類１' , 'exist2'   =>  '分類２' , 'exist3'   =>  '分類３' , 'none' => '未設定' }
    [ ['すべて',0],['分類１',1],['分類２',2],['分類３',3],['未設定',999] ]
  end
  def categories_status
#    { 'exist'   =>  '分類１' , 'exist2'   =>  '分類２' , 'exist3'   =>  '分類３' , 'none' => '未設定' }
    { 1  =>  '分類１' , 2 =>  '分類２' , 3  =>  '分類３' , 999 => '未設定' }
  end
  def categories_status_show
#    { 'exist'   =>  '分類１' , 'exist2'   =>  '分類２' , 'exist3'   =>  '分類３' , 'none' => '未設定' }
    { 1  =>  '分類１' , 2 =>  '分類２' , 3  =>  '分類３' , 999 => '' }
  end
  def sendstate_status
    { 'none' => '未'  , 'complete'   =>  '済'}
  end

  def self.is_dev?(user = Core.user)
    user.has_role?('_developer/admin')
  end

  def self.is_sysadmin?(user = Core.user)
    user.has_role?('_admin/admin')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('sb12/admin')
  end

  def validate_section_id
    item = Gwsub::Externalusb.find_by(new_registedno: self.new_registedno)
    unless item.blank?
      if self._is_new
        errors.add :new_registedno, "は、重複したため新番号を設定しました。再度保存を行ってください。"
        new_registedno_setting
      else
        errors.add :new_registedno, "は、既に存在します。" unless item.id == self.id
      end
    end
  end

  def before_validates_registedno_upcase
    self.registedno = self.registedno.to_s.upcase
  end

  def before_validates_registed_seq_single
    self.registed_seq = Gwsub.convert_char_ascii(self.registed_seq).to_s
  end
  def before_validates_registedno_concat
    _externalkind = Gwsub::Externalmediakind(self.externalmediakind_id)
    self.registedno = self.section_code&_externalkind.name&self.registed_seq
  end

  def before_create_setting_columns
    return unless self._is_new  #Gwsub::Public::Sb12::ExternalusbsController で new,createの時のみ true セット
    #なのでcsvによるレコード追加ではスルーされる

    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
    new_registedno_setting
  end
  def before_update_setting_columns
      Gwsub.gwsub_set_editors(self)
  end

  #名称の部分をセット
  def set_section_name
    item = System::Group.find_by_id(self.section_id)
    #self.section_code = ''
    #self.section_name = ''
    return if item.blank?
    self.section_code = item.code
    self.section_name = "#{item.code}#{item.name}"
  end
  def set_user_name
    item = System::User.find_by_id(self.user_id)
    #self.user = ''
    return if item.blank?
    self.user = item.name
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 'scn'
#        pp ["scn",v]
#        search_keyword v, :section_name
        search_id v.to_i, :section_id unless v.to_i==0
      when 'cat'
        search_id v.to_i, :categories unless v.to_i==0
      when 's_keyword'
        case v
        when '済'
          v = 'complete'
        when '未','無'
          v = 'none'
#        when '有'
#          v = 'exist'
        end
        search_keyword2 v, :new_registedno,:registedno,:equipmentname,:sendstate,:user,:remarks
      end
    end if params.size != 0

    return self
  end

  def search_cond(words, columns)
    condition = Condition.new
    words.each do |word|
      next if word.length == 0
      cond = Condition.new
      columns.each_with_index do |col,idx|
        if Gw.int?(word) && col == :id
          cond.or "gwsub_externalusbs.#{col.to_s}", '=', "#{word.to_i}"
        else
          cond.or "gwsub_externalusbs.#{col.to_s}", 'like', "%#{word}%"
        end
      end
      condition.or cond
    end
    return condition
  end

  def search_keyword2(v, *cols)
    words = v.split(/[ 　]+/)
    if words.length != 0
      self.and search_cond(words, cols)
    end
  end

  def self.drop_create_table
    _connect = self.connection()
    _drop_query = "DROP TABLE IF EXISTS `gwsub_externalusbs` ;"
    _connect.execute(_drop_query)
    _create_query = "CREATE TABLE `gwsub_externalusbs` (
      `id`                     int(11) NOT NULL auto_increment,
      `registedno`             text default NULL,
      `externalmediakind_id`   int(11) default NULL,
      `registed_at`            datetime default NULL,
      `equipmentname`          text default NULL,
      `capacity`               text default NULL,
      `capacityunit_id`        int(11) default NULL,
      `sendstate`              text default NULL,
      `user`                   text default NULL,
      `categories`             text default NULL,
      `ending_at`              datetime default NULL,
      `remarks`                text default NULL,
      `last_updated_at`        datetime default NULL,
      `updated_at`             datetime default NULL,
      `updated_user`           text default NULL,
      `updated_group`          text default NULL,
      `created_at`             datetime default NULL,
      `created_user`           text default NULL,
      `created_group`          text default NULL,
      PRIMARY KEY  (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    _connect.execute(_create_query)
    return
  end

  def home_path
    return '/gwsub/sb12/externalusbs/'
  end

  def show_path
    return "#{self.home_path}#{self.id}"
  end

  def group_update
    sql = 'SELECT section_id FROM gwsub_externalusbs GROUP BY section_id;'
    items = Gwsub::Externalusb.find_by_sql(sql)
    for item in items
      unless item.section_id.blank?
        grp_id = item.section_id
        grp = System::Group.find_by(id: grp_id)
        code = ''
        name = ''
        sort_no = 0
        if grp.blank?
          state = 'disabled'
        else
          state = grp.state
          code = grp.code unless grp.code.blank?
          name = grp.name unless grp.name.blank?
          sort_no = grp.sort_no unless grp.sort_no.blank?
        end
        latest_updated_at = Time.now
        #
        sb12 = Gwsub::Sb12Group.find_by(id: grp_id)
        if sb12.blank?
          sb12 = Gwsub::Sb12Group.new
          sb12.id = grp_id
        end
        sb12.state = state
        sb12.code = code
        sb12.name = name
        sb12.sort_no = sort_no
        sb12.latest_updated_at = latest_updated_at
        sb12.save
      end
    end
  end

  def new_registedno_setting
    return unless self._is_new

    maxnum =  Gwsub::Externalusb.maximum('new_registedno')
    maxnum = 0 if maxnum.blank?
    maxnum += 1
    self.new_registedno = maxnum
  end

end
