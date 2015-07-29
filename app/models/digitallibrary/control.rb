# -*- encoding: utf-8 -*-
class Digitallibrary::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::ControlCommon
  include Gwboard::Model::AttachFile
  include Digitallibrary::Model::Systemname
  include System::Model::Base::Status

  has_many :adm, :foreign_key => :title_id, :class_name => 'Digitallibrary::Adm', :dependent => :destroy
  has_many :role, :foreign_key => :title_id, :class_name => 'Digitallibrary::Role', :dependent => :destroy

  validates_presence_of :state, :recognize, :title, :separator_str1, :separator_str2, :category1_name
  after_validation :validate_params
  after_create :create_digitallib_system_database
  after_save :save_admingrps, :save_editors, :save_readers, :save_readers_add, :save_sueditors, :save_sureaders
  attr_accessor :_editing_group

  def validate_params
    errors.add :upload_graphic_file_size_capacity, "は数値を入力してください。" if self.upload_graphic_file_size_capacity.blank?
    errors.add :upload_document_file_size_capacity, "は数値を入力してください。" if self.upload_document_file_size_capacity.blank?
    errors.add :upload_graphic_file_size_max, "は数値を入力してください。" if self.upload_graphic_file_size_max.blank?
    errors.add :upload_document_file_size_max, "は数値を入力してください。" if self.upload_document_file_size_max.blank?

    error_users = validate_users(self.adms_json)
    unless error_users.blank?
      errors.add(:adms_json, "の#{error_users.join(", ")}は無効になっています。削除するか、または有効なユーザーを選択してください。")
    end

    error_users = validate_users(self.sueditors_json)
    unless error_users.blank?
      errors.add(:sueditors_json, "の#{error_users.join(", ")}は無効になっています。削除するか、または有効なユーザーを選択してください。")
    end

    error_users = validate_users(self.sureaders_json)
    unless error_users.blank?
      errors.add(:sureaders_json, "の#{error_users.join(", ")}は無効になっています。削除するか、または有効なユーザーを選択してください。")
    end
  end

  def validate_users(json)
    error_users = []
    fields = JsonParser.new.parse(json)
    fields.each do |field|
      user = System::User.find(field[1])
      if !user || user.state != "enabled"
        error_users << field[2]
      end
    end
    error_users
  end

  def save_admingrps
    unless self.admingrps_json.blank?
      Digitallibrary::Adm.destroy_all("title_id=#{self.id}")
      groups = JsonParser.new.parse(self.admingrps_json)
      @dsp_admin_name = ''
      groups.each do |group|
        item_grp = Digitallibrary::Adm.new()
        item_grp.title_id = self.id
        item_grp.user_id = 0
        item_grp.user_code = nil
        item_grp.group_id = group[1]
        item_grp.group_code = group_code(group[1])
        item_grp.group_name = group[2]
        item_grp.save!
        @dsp_admin_name = group[2] if @dsp_admin_name.blank?
      end
    end
    save_adms
    unless self.dsp_admin_name == @dsp_admin_name
      args = ["UPDATE digitallibrary_controls SET dsp_admin_name = ? WHERE id =?", @dsp_admin_name, self.id]
      strsql = ActiveRecord::Base.send(:sanitize_sql_array, args)
      connection.execute(strsql)
    end
  end

  def save_adms
    unless self.adms_json.blank?
      users = JsonParser.new.parse(self.adms_json)
      users.each do |user|
        item_adm = Digitallibrary::Adm.new()
        item_adm.title_id = self.id
        item_adm.user_id = user[1].to_i
        item_user = System::User.find(item_adm.user_id)
        if item_user
          tg = item_user.groups[0]
          item_adm.user_id = item_user[:id]
          item_adm.user_code = item_user[:code]
          item_adm.group_id = tg[:group_id]
          item_adm.group_code = tg[:code]
          @dsp_admin_name = tg[:name] unless tg[:name].blank? if @dsp_admin_name.blank?
        end
        item_adm.user_name = user[2]
        item_adm.save!
      end
    end
  end

  def save_editors
    unless self.editors_json.blank?
      Digitallibrary::Role.destroy_all("title_id=#{self.id} and role_code = 'w'")
      groups = JsonParser.new.parse(self.editors_json)
      groups.each do |group|
        unless group[1].blank?
          item_grp = Digitallibrary::Role.new()
          item_grp.title_id = self.id
          item_grp.role_code = 'w'
          item_grp.group_code = group_code(group[1])
          item_grp.group_code = '0' if group[1].to_s == '0'
          item_grp.group_id = group[1]
          item_grp.group_name = group[2]
          item_grp.save! unless item_grp.group_code.blank?
        end
      end
    end
  end

  def save_readers
    unless self.readers_json.blank?
      Digitallibrary::Role.destroy_all("title_id=#{self.id} and role_code = 'r'")
      groups = JsonParser.new.parse(self.readers_json)
      groups.each do |group|
        unless group[1].blank?
          item_grp = Digitallibrary::Role.new()
          item_grp.title_id = self.id
          item_grp.role_code = 'r'
          item_grp.group_code = group_code(group[1])
          item_grp.group_code = '0' if group[1].to_s == '0'
          item_grp.group_id = group[1]
          item_grp.group_name = group[2]
          item_grp.save! unless item_grp.group_code.blank?
        end
      end
    end
  end

  def save_readers_add
    unless self.editors_json.blank?
      item = Digitallibrary::Role.find(:all, :conditions => "title_id=#{self.id} and role_code = 'r' and group_code = '0'")
      if item.length == 0
        groups = JsonParser.new.parse(self.editors_json)
        groups.each do |group|
          unless group[1].blank?
            item_grp = Digitallibrary::Role.find(:all, :conditions => "title_id=#{self.id} and role_code = 'r' and group_id = #{group[1]}")
            if item_grp.length == 0
              item_grp = Digitallibrary::Role.new()
              item_grp.title_id = self.id
              item_grp.role_code = 'r'
              item_grp.group_code = group_code(group[1])
              item_grp.group_code = '0' if group[1].to_s == '0'
              item_grp.group_id = group[1]
              item_grp.group_name = group[2]
              item_grp.save! unless item_grp.group_code.blank?
            end
          end
        end
      end
    end
  end

  def save_sueditors
    unless self.sueditors_json.blank?
      suedts = JsonParser.new.parse(self.sueditors_json)
      suedts.each do |suedt|
        unless suedt[1].blank?
          item_sue = Digitallibrary::Role.new()
          item_sue.title_id = self.id
          item_sue.role_code = 'w'
          item_sue.user_id = suedt[1].to_i
          item_user = System::User.find(item_sue.user_id)
          if item_user
            item_sue.user_id = item_user[:id]
            item_sue.user_code = item_user[:code]
          end
          item_sue.user_name = suedt[2]
          item_sue.save!

          item_sue = Digitallibrary::Role.new()
          item_sue.title_id = self.id
          item_sue.role_code = 'r'
          item_sue.user_id = suedt[1].to_i
          item_user = System::User.find(item_sue.user_id)
          if item_user
            item_sue.user_id = item_user[:id]
            item_sue.user_code = item_user[:code]
          end
          item_sue.user_name = suedt[2]
          item_sue.save!
        end
      end
    end
  end

  def save_sureaders
    unless self.sueditors_json.blank?
      surds = JsonParser.new.parse(self.sureaders_json)
      surds.each do |surd|
        unless surd[1].blank?
          item_sur = Digitallibrary::Role.new()
          item_sur.title_id = self.id
          item_sur.role_code = 'r'
          item_sur.user_id = surd[1].to_i
          item_user = System::User.find(item_sur.user_id)
          if item_user
            item_sur.user_id = item_user[:id]
            item_sur.user_code = item_user[:code]
          end
          item_sur.user_name = surd[2]
          item_sur.save!
        end
      end
    end
  end

  def group_code(id)
    item = System::Group.find_by_id(id)
    ret = ''
    ret = item.code if item
    return ret
  end

  def create_digitallib_system_database
    if self.dbname.blank?
      self.dbname = "#{default_database_name}_#{sprintf('%06d', self.id)}"
      self.save
    end
    create_db
    create_table_docs
    docs_add_index
    create_table_db_files
    create_table_files
    #cretae_table_images
    create_table_recognizers

  end

  def default_database_name
    cnn = Digitallibrary::Doc.establish_connection

    cn = cnn.spec.config[:database]
    dbname = ''
    l = 0
    l = cn.length if cn
    unless l == 0
      i = cn.rindex "_", cn.length
      dbname += cn[0,i] + '_dig'
    else
      dbname += "development_jgw_dig"
    end
    return dbname
  end

  def create_db
    strsql = "CREATE DATABASE IF NOT EXISTS `#{self.dbname}`;"
    return connection.execute(strsql)
  end

  def create_table_docs
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`digitallibrary_docs` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`unid` int(11) default NULL,"
    strsql += "`content_id` int(11) default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`state` text,"
    strsql += "`created_at` datetime default NULL,"
    strsql += "`updated_at` datetime default NULL,"
    strsql += "`recognized_at` datetime default NULL,"
    strsql += "`published_at` datetime default NULL,"
    strsql += "`latest_updated_at` datetime default NULL,"
    strsql += "`doc_type` int(11) default NULL,"
    strsql += "`display_order` int(11) default NULL,"
    strsql += "`doc_alias` int(11) default NULL,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`chg_parent_id` int(11) default NULL,"
    strsql += "`sort_no` int(11) default NULL,"
    strsql += "`seq_no` float default NULL,"
    strsql += "`order_no` int(11) default NULL,"
    strsql += "`seq_name` varchar(255) default NULL,"
    strsql += "`level_no` int(11) default NULL,"
    strsql += "`section_code` varchar(255) default NULL,"
    strsql += "`section_name` text,"
    strsql += "`name` text,"
    strsql += "`title` text,"
    strsql += "`body` mediumtext,"
    strsql += "`note` mediumtext,"
    strsql += "`category1_id` int(11) default NULL,"
    strsql += "`category2_id` int(11) default NULL,"
    strsql += "`category3_id` int(11) default NULL,"
    strsql += "`category4_id` int(11) default NULL,"
    strsql += "`keywords` mediumtext,"
    strsql += "`createdate` text,"
    strsql += "`creater_admin` tinyint(1) default NULL,"
    strsql += "`createrdivision_id` varchar(20) default NULL,"
    strsql += "`createrdivision` text,"
    strsql += "`creater_id` varchar(20) default NULL,"
    strsql += "`creater` text,"
    strsql += "`editdate` text,"
    strsql += "`editor_admin` tinyint(1) default NULL,"
    strsql += "`editordivision_id` varchar(20) default NULL,"
    strsql += "`editordivision` text,"
    strsql += "`editor_id` varchar(20) default NULL,"
    strsql += "`editor` text,"
    strsql += "`readers` text,"
    strsql += "`readers_json` text,"
    strsql += "`notes_001` text,"
    strsql += "`attachmentfile` int(11) default NULL,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ") DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end


  def docs_add_index
    strsql =  "ALTER TABLE `#{self.dbname}`.`digitallibrary_docs` ADD INDEX state(state(30));"
    connection.execute(strsql)
    strsql =  "ALTER TABLE `#{self.dbname}`.`digitallibrary_docs` ADD INDEX level_no(level_no, display_order, sort_no, id);"
    connection.execute(strsql)
    strsql =  "ALTER TABLE `#{self.dbname}`.`digitallibrary_docs` ADD INDEX parent_id(parent_id);"
    connection.execute(strsql)
    strsql = "ALTER TABLE `#{self.dbname}`.`digitallibrary_docs` ADD INDEX display_order(display_order,sort_no);"
    return connection.execute(strsql)
  end

  def create_table_db_files
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`digitallibrary_db_files` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`data` longblob,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ") DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def create_table_files
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`digitallibrary_files` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`unid` int(11) default NULL,"
    strsql += "`content_id` int(11) default NULL,"
    strsql += "`state` text,"
    strsql += "`created_at` datetime default NULL,"
    strsql += "`updated_at` datetime default NULL,"
    strsql += "`recognized_at` datetime default NULL,"
    strsql += "`published_at` datetime default NULL,"
    strsql += "`latest_updated_at` datetime default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`content_type` varchar(255) default NULL,"
    strsql += "`filename` text,"
    strsql += "`memo` text,"
    strsql += "`size` int(11) default NULL,"
    strsql += "`width` int(11) default NULL,"
    strsql += "`height` int(11) default NULL,"
    strsql += "`db_file_id` int(11) default NULL,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ")  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def cretae_table_images
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`digitallibrary_images` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`unid` int(11) default NULL,"
    strsql += "`content_id` int(11) default NULL,"
    strsql += "`state` text,"
    strsql += "`created_at` datetime default NULL,"
    strsql += "`updated_at` datetime default NULL,"
    strsql += "`recognized_at` datetime default NULL,"
    strsql += "`published_at` datetime default NULL,"
    strsql += "`latest_updated_at` datetime default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`parent_name` text,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`content_type` varchar(255) default NULL,"
    strsql += "`filename` text,"
    strsql += "`memo` text,"
    strsql += "`size` int(11) default NULL,"
    strsql += "`width` int(11) default NULL,"
    strsql += "`height` int(11) default NULL,"
    strsql += "`db_file_id` int(11) default NULL,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ")  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def create_table_recognizers
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`digitallibrary_recognizers` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`unid` int(11) default NULL,"
    strsql += "`updated_at` datetime default NULL,"
    strsql += "`created_at` datetime default NULL,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`user_id` int(11) default NULL,"
    strsql += "`code` varchar(255) default NULL,"
    strsql += "`name` text,"
    strsql += "`recognized_at` datetime default NULL,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ") DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def set_category_folder_root
    cnn = Digitallibrary::Folder.establish_connection
    cnn.spec.config[:database] = self.dbname
    doc_item = Digitallibrary::Doc.establish_connection(cnn.spec.config)
    folder_item = Digitallibrary::Folder
    folder_item.establish_connection(cnn.spec.config)
    item = folder_item.new
    item.and :title_id, self.id
    item.and :level_no, 1
    folder = item.find(:first)
    unless folder.blank?

      folder_item.update(folder.id,
        :updated_at => Time.now,
        :doc_type => 0,
        :title => self.category1_name
      )
      folder.save!
    else

      folder = folder_item.create!(
        :state => 'public',
        :title_id => self.id,
        :parent_id => nil,
        :doc_type => 0,
        :sort_no => 0,
        :level_no => 1,
        :title => self.category1_name
      )
    end
  end

  def menu_item_path
    return "#{Site.current_node.public_uri.chop}?title_id=#{self.id}"
  end

  def categorys_path
    return "#{self.item_home_path}categories?title_id=#{self.id}"
  end

  def new_uploads_path
    return "#{self.item_home_path}docs/new?title_id=#{self.id}"
  end

  def docs_path
    return "#{self.item_home_path}docs?title_id=#{self.id}"
  end

  def adm_docs_path
    return "#{self.item_home_path}adms?title_id=#{self.id}"
  end



  def sort_name_display_states
    {'0' => '表示する', '1' => '表示しない'}
  end

  def date_index_display_states
    {'0' => '使用する', '1' => '使用しない'}
  end

end