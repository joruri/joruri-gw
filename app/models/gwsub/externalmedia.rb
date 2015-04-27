class Gwsub::Externalmedia < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content
  self.table_name = "gwsub_externalmedias"

  belongs_to :group , :foreign_key => :section_id  ,:class_name=>'Gwsub::Sb13Group'
  belongs_to :externalmediakind , :foreign_key => :externalmediakind_id ,:class_name=>'Gwsub::Externalmediakind'

  before_validation :set_externalmediakind_record
  after_validation :validate_section_id #registednoが必須で無くなったので、ここでチェックしている

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  before_save :set_section_name, :set_user_name
  after_save :group_update

  validates :registed_at,:equipmentname,:externalmediakind_id, :section_id, presence: true
  validates :equipmentname, length: {maximum: 50 , too_long: 'は、50文字以内で入力してください。'}, allow_nil: true
  validates :remarks, length: {maximum: 50, too_long: 'は、50文字以内で入力してください。'}, allow_nil: true

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
#    { 'none' => '無'  , 'exist'   =>  '有'}
    { 1  =>  '分類１' , 2 =>  '分類２' , 3  =>  '分類３' , 999 => '未設定' }
  end
  def categories_status_show
#    { 'exist'   =>  '分類１' , 'exist2'   =>  '分類２' , 'exist3'   =>  '分類３' , 'none' => '未設定' }
    { 1  =>  '分類１' , 2 =>  '分類２' , 3  =>  '分類３' , 999 => '' }
  end
  def sendstate_status
    { 'none' => '未送付'  , 'complete'   =>  '送付済'}
  end

  def before_create_setting_columns
    return unless self._is_new  #Gwsub::Public::Sb13::ExternalmediasController で new,createの時のみ true セット
    #なのでcsvによるレコード追加ではスルーされる
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
    new_registedno_setting
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
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
    item = Gwsub::Externalmedia.find_by(new_registedno: self.new_registedno)
    unless item.blank?
      if self._is_new
        errors.add :new_registedno, "は、重複したため新番号を設定しました。再度保存を行ってください。"
        new_registedno_setting
      else
        errors.add :new_registedno, "は、既に存在します。" unless item.id == self.id
      end
    end

    check_externalmediakind_record
  end
  def check_externalmediakind_record
    return if self.externalmediakind_name.blank?  #入力無ければ処理しない
    self.externalmediakind_name = self.externalmediakind_name.upcase
    item = Gwsub::Externalmediakind.find_by_name(self.externalmediakind_name)
    unless item.blank?  #名前の該当あれば既にありますメッセージ
      self.externalmediakind_id = item.id
      self.externalmediakind_name = ''
      errors.add :externalmediakind_name, "に入力された内容は既に登録されていたので置換しました。"
    end
  end

  #名称の部分をセット
  def set_section_name
    item = System::Group.find_by_id(self.section_id)
    return if item.blank?
    self.section_code = item.code
    self.section_name = "#{item.code}#{item.name}"
  end
  def set_user_name
    item = System::User.find_by_id(self.user_id)
    return if item.blank?
    self.user = item.name
  end

  def set_externalmediakind_record
    if self.externalmediakind_name.blank?
      # 追加名称入力なし
      item = Gwsub::Externalmediakind.find_by_id(self.externalmediakind_id)
      if item
        self.equipmentname = item.name
      end
    else
      # 追加名称入力あり
      item = Gwsub::Externalmediakind.find_by_name(self.externalmediakind_name)
      if item.blank?
        item = Gwsub::Externalmediakind.create({
          :sort_order => '0' ,  #varidate対象なので仮設定
          :kind => self.externalmediakind_name ,
          :name => self.externalmediakind_name ,
          :created_at => Time.now ,
          :created_user => Core.user.name ,
          :created_group => Core.user_group.name
        })
        item.sort_order_int = item.id * 10
        item.sort_order = item.sort_order_int
        item.save
      end
      self.externalmediakind_id = item.id
      self.equipmentname = item.name
      self.externalmediakind_name = ''
    end
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 'scn'
#        search_keyword v, :section_name
        search_id v.to_i, :section_id unless v.to_i==0
      when 'cat'
        search_id v.to_i, :categories unless v.to_i==0
      when 's_keyword'
        case v
        when '未','無'
          v = 'none'
#        when '有'
#          v = 'exist'
        end
        search_keyword2 v, :new_registedno,:registed_at,:registedno,:equipmentname,:user,:ending_at,:remarks
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
          cond.or "gwsub_externalmedias.#{col.to_s}", '=', "#{word.to_i}"
        else
          cond.or "gwsub_externalmedias.#{col.to_s}", 'like', "%#{word}%"
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
    _drop_query = "DROP TABLE IF EXISTS `gwsub_externalmedias` ;"
    _connect.execute(_drop_query)
    _create_query = "CREATE TABLE `gwsub_externalmedias` (
      `id`                    int(11) NOT NULL auto_increment,
      `registedno`            text default NULL,
      `section_code`          text default NULL,
      `externalmediakind_id`  int(11) default NULL,
      `registed_seq`          text default NULL,
      `registed_at`           datetime default NULL,
      `equipmentname`         text default NULL,
      `user`                  text default NULL,
      `categories`            text default NULL,
      `ending_at`             datetime default NULL,
      `remarks`               text default NULL,
      `last_updated_at`       datetime default NULL,
      `updated_at`            datetime default NULL,
      `updated_user`          text default NULL,
      `updated_group`         text default NULL,
      `created_at`            datetime default NULL,
      `created_user`          text default NULL,
      `created_group`         text default NULL,
      PRIMARY KEY  (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    _connect.execute(_create_query)
    return
  end

  def home_path
    return '/gwsub/sb13/externalmedias/'
  end

  def show_path
    return "#{self.home_path}#{self.id}"
  end

  def group_update
    sql = 'SELECT section_id FROM gwsub_externalmedias GROUP BY section_id;'
    items = Gwsub::Externalmedia.find_by_sql(sql)
    for item in items
      grp_id = item.section_id
      grp = System::Group.find_by(id: grp_id)
      if grp.blank?
        state = 'disabled'
        code = ''
        name = ''
        sort_no = 0
      else
        state = grp.state
        code = grp.code
        name = grp.name
        sort_no = grp.sort_no
      end
      latest_updated_at = Time.now
      #
      state = 'disabled' if state.blank?
      sb13 = Gwsub::Sb13Group.find_by(id: grp_id)
      if sb13.blank?
        sb13 = Gwsub::Sb13Group.new
        sb13.id = grp_id
      end
      sb13.state = state
      sb13.code = code
      sb13.name = name
      sb13.sort_no = sort_no
      sb13.latest_updated_at = latest_updated_at
      sb13.save
    end
  end

  def new_registedno_setting
    return unless self._is_new

    maxnum = Gwsub::Externalmedia.maximum('new_registedno')
    maxnum = 0 if maxnum.blank?
    maxnum += 1
    self.new_registedno = maxnum
  end

end
