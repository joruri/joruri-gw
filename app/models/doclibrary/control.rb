# -*- encoding: utf-8 -*-
class Doclibrary::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::ControlCommon
  include Gwboard::Model::AttachFile
  include Doclibrary::Model::Systemname
  include System::Model::Base::Status

  has_many :adm, :foreign_key => :title_id, :class_name => 'Doclibrary::Adm', :dependent => :destroy
  has_many :role, :foreign_key => :title_id, :class_name => 'Doclibrary::Role', :dependent => :destroy

  validates_presence_of :state, :title, :category1_name
  validates_presence_of :upload_graphic_file_size_capacity,:upload_document_file_size_capacity, :upload_graphic_file_size_max,:upload_document_file_size_max
  after_validation :validate_params
  after_create :create_doclib_system_database
  after_save :save_admingrps, :save_editors, :save_readers, :save_readers_add, :save_sueditors, :save_sureaders

  attr_accessor :_editing_group

  def doclib_form_name
    return 'doclibrary/admin/user_forms/' + self.form_name + '/'
  end

  def use_form_name()
    return [
      ['一般書庫', 'form001']
    ]
  end

  def save_admingrps
    unless self.admingrps_json.blank?
      Doclibrary::Adm.destroy_all("title_id=#{self.id}")
      groups = JsonParser.new.parse(self.admingrps_json)
      @dsp_admin_name = ''
      groups.each do |group|
        item_grp = Doclibrary::Adm.new()
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
      args = ["UPDATE doclibrary_controls SET dsp_admin_name = ? WHERE id =?", @dsp_admin_name, self.id]
      strsql = ActiveRecord::Base.send(:sanitize_sql_array, args)
      connection.execute(strsql)
    end
  end

  def save_adms
    unless self.adms_json.blank?
      users = JsonParser.new.parse(self.adms_json)
      users.each do |user|
        item_adm = Doclibrary::Adm.new()
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
      Doclibrary::Role.destroy_all("title_id=#{self.id} and role_code = 'w'")
      groups = JsonParser.new.parse(self.editors_json)
      groups.each do |group|
        unless group[1].blank?
          item_grp = Doclibrary::Role.new()
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
      Doclibrary::Role.destroy_all("title_id=#{self.id} and role_code = 'r'")
      groups = JsonParser.new.parse(self.readers_json)
      groups.each do |group|
        unless group[1].blank?
          item_grp = Doclibrary::Role.new()
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
      item = Doclibrary::Role.find(:all, :conditions => "title_id=#{self.id} and role_code = 'r' and group_code = '0'")
      if item.length == 0
        groups = JsonParser.new.parse(self.editors_json)
        groups.each do |group|
          unless group[1].blank?
            item_grp = Doclibrary::Role.find(:all, :conditions => "title_id=#{self.id} and role_code = 'r' and group_id = #{group[1]}")
            if item_grp.length == 0
              item_grp = Doclibrary::Role.new()
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
          item_sue = Doclibrary::Role.new()
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
          item_sue = Doclibrary::Role.new()
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
          item_sur = Doclibrary::Role.new()
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

  def validate_params
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

  def create_doclib_system_database
    if self.dbname.blank?
      self.dbname = "#{default_database_name}_#{sprintf('%06d', self.id)}"
      self.save
    end
    create_db
    create_table_categories
    create_table_folders
    create_table_group_folders
    group_folders_add_index # index追加
    create_table_docs
    docs_add_index # index追加
    create_table_db_files
    create_table_files
    #cretae_table_images
    create_table_recognizers
    create_table_folder_acls
    folder_add_index # index追加
    folder_acls_add_index # index追加
    create_view_acl_docs
    create_view_acl_files
    create_view_acl_folders
    create_view_acl_doc_counts
    set_category_folder_root
  end

  def default_database_name
    cnn = Doclibrary::Doc.establish_connection
    cn = cnn.spec.config[:database]
    dbname = ''
    l = 0
    l = cn.length if cn
    unless l == 0
      i = cn.rindex "_", cn.length
      dbname += cn[0,i] + '_doc'
    else
      dbname += "dev_jgw_doc"
    end
    return dbname
  end

  def create_db
    strsql = "CREATE DATABASE IF NOT EXISTS `#{self.dbname}`;"
    return connection.execute(strsql)
  end

  def create_table_categories
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`doclibrary_categories` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`unid` int(11) default NULL,"
    strsql += "`content_id` int(11) default NULL,"
    strsql += "`state` text,"
    strsql += "`created_at` datetime default NULL,"
    strsql += "`updated_at` datetime default NULL,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`sort_no` int(11) default NULL,"
    strsql += "`level_no` int(11) default NULL,"
    strsql += "`wareki` text,"
    strsql += "`nen` int(11) default NULL,"
    strsql += "`gatsu` int(11) default NULL,"
    strsql += "`sono` int(11) default NULL,"
    strsql += "`sono2` int(11) default NULL,"
    strsql += "`filename` varchar(255),"
    strsql += "`note_id` varchar(255),"
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
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ")   DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def create_table_folders
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`doclibrary_folders` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`unid` int(11) default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`state` text,"
    strsql += "`created_at` datetime default NULL,"
    strsql += "`updated_at` datetime default NULL,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`sort_no` int(11) default NULL,"
    strsql += "`level_no` int(11) default NULL,"
    strsql += "`children_size` int(11) default NULL,"
    strsql += "`total_children_size` int(11) default NULL,"
    strsql += "`name` text,"
    strsql += "`memo` text,"
    strsql += "`readers` text,"
    strsql += "`readers_json` text,"
    strsql += "`reader_groups` text,"
    strsql += "`reader_groups_json` text,"
    strsql += "`docs_last_updated_at` datetime default NULL,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ")   DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def create_table_group_folders
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`doclibrary_group_folders` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`unid` int(11) default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`state` text,"
    strsql += "`use_state` text,"
    strsql += "`created_at` datetime default NULL,"
    strsql += "`updated_at` datetime default NULL,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`sort_no` int(11) default NULL,"
    strsql += "`level_no` int(11) default NULL,"
    strsql += "`children_size` int(11) default NULL,"
    strsql += "`total_children_size` int(11) default NULL,"
    strsql += "`code` varchar(255) default NULL,"
    strsql += "`name` text,"
    strsql += "`sysgroup_id` int(11) default NULL,"
    strsql += "`sysparent_id` int(11) default NULL,"
    strsql += "`readers` text,"
    strsql += "`readers_json` text,"
    strsql += "`reader_groups` text,"
    strsql += "`reader_groups_json` text,"
    strsql += "`docs_last_updated_at` datetime default NULL,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ")  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def group_folders_add_index
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_group_folders` ADD INDEX ( `code` )"
    return connection.execute(strsql)
  end

  def docs_add_index
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_docs` ADD INDEX title_id(state(50),title_id,category1_id);"
    connection.execute(strsql)
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_docs` ADD INDEX category1_id(category1_id);"
    connection.execute(strsql)
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_docs` ADD INDEX title_id2(title_id);"
    return connection.execute(strsql)
  end

  def folder_add_index
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_folders` ADD INDEX title_id(title_id);"
    connection.execute(strsql)
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_folders` ADD INDEX parent_id(parent_id);"
    connection.execute(strsql)
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_folders` ADD INDEX sort_no(sort_no);"
    return connection.execute(strsql)
  end

  def folder_acls_add_index
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_folder_acls` ADD INDEX title_id(title_id);"
    connection.execute(strsql)
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_folder_acls` ADD INDEX folder_id(folder_id);"
    connection.execute(strsql)
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_folder_acls` ADD INDEX acl_section_code(acl_section_code);"
    connection.execute(strsql)
    strsql = "ALTER TABLE `#{self.dbname}`.`doclibrary_folder_acls` ADD INDEX acl_user_code(acl_user_code);"
    return connection.execute(strsql)
  end

  def create_table_docs
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`doclibrary_docs` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`unid` int(11) default NULL,"
    strsql += "`content_id` int(11) default NULL,"
    strsql += "`state` text,"
    strsql += "`created_at` datetime default NULL,"
    strsql += "`updated_at` datetime default NULL,"
    strsql += "`recognized_at` datetime default NULL,"
    strsql += "`published_at` datetime default NULL,"
    strsql += "`latest_updated_at` datetime default NULL,"
    strsql += "`doc_type` int(11) default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`content_state` text,"
    strsql += "`section_code` varchar(255) default NULL,"
    strsql += "`section_name` text,"
    strsql += "`importance` int(11) default NULL,"
    strsql += "`one_line_note` int(11) default NULL,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`name` text,"
    strsql += "`pname` text,"
    strsql += "`title` text,"
    strsql += "`head` mediumtext,"
    strsql += "`body` mediumtext,"
    strsql += "`note` mediumtext,"
    strsql += "`category_use` int(11) default NULL,"
    strsql += "`category1_id` int(11) default NULL,"
    strsql += "`category2_id` int(11) default NULL,"
    strsql += "`category3_id` int(11) default NULL,"
    strsql += "`category4_id` int(11) default NULL,"
    strsql += "`keywords` text,"
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
    strsql += "`expiry_date` datetime default NULL,"
    strsql += "`attachmentfile` int(11) default NULL,"
    strsql += "`form_name`  varchar(255),"
    strsql += "`inpfld_001` text,"
    strsql += "`inpfld_002` int(11) default NULL,"
    strsql += "`inpfld_003` int(11) default NULL,"
    strsql += "`inpfld_004` int(11) default NULL,"
    strsql += "`inpfld_005` int(11) default NULL,"
    strsql += "`inpfld_006` int(11) default NULL,"
    strsql += "`inpfld_007` text,"
    strsql += "`inpfld_008` text,"
    strsql += "`inpfld_009` text,"
    strsql += "`inpfld_010` text,"
    strsql += "`inpfld_011` text,"
    strsql += "`inpfld_012` text,"
    strsql += "`notes_001` text,"
    strsql += "`notes_002` text,"
    strsql += "`notes_003` text,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ")   DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def create_table_db_files
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`doclibrary_db_files` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`parent_id` int(11) default NULL,"
    strsql += "`data` longblob,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ")   DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def create_table_files
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`doclibrary_files` ("
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
    strsql += ")   DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def cretae_table_images
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`doclibrary_images` ("
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
    strsql += ")   DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def create_table_recognizers
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`doclibrary_recognizers` ("
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
    strsql += ")  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def create_table_folder_acls
    strsql = "CREATE TABLE IF NOT EXISTS `#{self.dbname}`.`doclibrary_folder_acls` ("
    strsql += "`id` int(11) NOT NULL auto_increment,"
    strsql += "`unid` int(11) default NULL,"
    strsql += "`content_id` int(11) default NULL,"
    strsql += "`created_at` datetime default NULL,"
    strsql += "`updated_at` datetime default NULL,"
    strsql += "`folder_id` int(11) default NULL,"
    strsql += "`title_id` int(11) default NULL,"
    strsql += "`acl_flag` int(11) default NULL,"
    strsql += "`acl_section_id` int(11) default NULL,"
    strsql += "`acl_section_code` varchar(255) default NULL,"
    strsql += "`acl_section_name` text,"
    strsql += "`acl_user_id` int(11) default NULL,"
    strsql += "`acl_user_code` varchar(255) default NULL,"
    strsql += "`acl_user_name` text,"
    strsql += "PRIMARY KEY  (`id`)"
    strsql += ") DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
    return connection.execute(strsql)
  end

  def create_view_acl_docs
    strsql = "CREATE VIEW `#{self.dbname}`.`doclibrary_view_acl_docs` AS "
    strsql += "select `#{self.dbname}`.`doclibrary_docs`.`id` AS `id`,`#{self.dbname}`.`doclibrary_folders`.`sort_no` AS `sort_no`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_flag` AS `acl_flag`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_id` AS `acl_section_id`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_code` AS `acl_section_code`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_name` AS `acl_section_name`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_id` AS `acl_user_id`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_code` AS `acl_user_code`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_name` AS `acl_user_name`,`#{self.dbname}`.`doclibrary_folders`.`name` AS `folder_name` from ((`#{self.dbname}`.`doclibrary_docs` join `#{self.dbname}`.`doclibrary_folder_acls` on(((`#{self.dbname}`.`doclibrary_docs`.`title_id` = `#{self.dbname}`.`doclibrary_folder_acls`.`title_id`) and (`#{self.dbname}`.`doclibrary_docs`.`category1_id` = `#{self.dbname}`.`doclibrary_folder_acls`.`folder_id`)))) join `#{self.dbname}`.`doclibrary_folders` on((`#{self.dbname}`.`doclibrary_docs`.`category1_id` = `#{self.dbname}`.`doclibrary_folders`.`id`)));"
    return connection.execute(strsql)
  end

  def create_view_acl_files
    strsql = "CREATE VIEW `#{self.dbname}`.`doclibrary_view_acl_files` AS "
    strsql += "select `#{self.dbname}`.`doclibrary_docs`.`state` AS `docs_state`,`#{self.dbname}`.`doclibrary_files`.`id` AS `id`,`#{self.dbname}`.`doclibrary_files`.`unid` AS `unid`,`#{self.dbname}`.`doclibrary_files`.`content_id` AS `content_id`,`#{self.dbname}`.`doclibrary_files`.`state` AS `state`,`#{self.dbname}`.`doclibrary_files`.`created_at` AS `created_at`,`#{self.dbname}`.`doclibrary_files`.`updated_at` AS `updated_at`,`#{self.dbname}`.`doclibrary_files`.`recognized_at` AS `recognized_at`,`#{self.dbname}`.`doclibrary_files`.`published_at` AS `published_at`,`#{self.dbname}`.`doclibrary_files`.`latest_updated_at` AS `latest_updated_at`,`#{self.dbname}`.`doclibrary_files`.`parent_id` AS `parent_id`,`#{self.dbname}`.`doclibrary_files`.`title_id` AS `title_id`,`#{self.dbname}`.`doclibrary_files`.`content_type` AS `content_type`,`#{self.dbname}`.`doclibrary_files`.`filename` AS `filename`,`#{self.dbname}`.`doclibrary_files`.`memo` AS `memo`,`#{self.dbname}`.`doclibrary_files`.`size` AS `size`,`#{self.dbname}`.`doclibrary_files`.`width` AS `width`,`#{self.dbname}`.`doclibrary_files`.`height` AS `height`,`#{self.dbname}`.`doclibrary_files`.`db_file_id` AS `db_file_id`,`#{self.dbname}`.`doclibrary_docs`.`category1_id` AS `category1_id`,`#{self.dbname}`.`doclibrary_docs`.`section_code` AS `section_code`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_flag` AS `acl_flag`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_id` AS `acl_section_id`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_code` AS `acl_section_code`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_name` AS `acl_section_name`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_id` AS `acl_user_id`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_code` AS `acl_user_code`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_name` AS `acl_user_name` from ((`#{self.dbname}`.`doclibrary_files` join `#{self.dbname}`.`doclibrary_docs` on(((`#{self.dbname}`.`doclibrary_files`.`parent_id` = `#{self.dbname}`.`doclibrary_docs`.`id`) and (`#{self.dbname}`.`doclibrary_files`.`title_id` = `#{self.dbname}`.`doclibrary_docs`.`title_id`)))) join `#{self.dbname}`.`doclibrary_folder_acls` on(((`#{self.dbname}`.`doclibrary_docs`.`category1_id` = `#{self.dbname}`.`doclibrary_folder_acls`.`folder_id`) and (`#{self.dbname}`.`doclibrary_docs`.`title_id` = `#{self.dbname}`.`doclibrary_folder_acls`.`title_id`))));"
    return connection.execute(strsql)
  end

  def create_view_acl_folders
    strsql = "CREATE VIEW `#{self.dbname}`.`doclibrary_view_acl_folders` AS "
    strsql += "select `#{self.dbname}`.`doclibrary_folders`.`id` AS `id`,`#{self.dbname}`.`doclibrary_folders`.`unid` AS `unid`,`#{self.dbname}`.`doclibrary_folders`.`parent_id` AS `parent_id`,`#{self.dbname}`.`doclibrary_folders`.`state` AS `state`,`#{self.dbname}`.`doclibrary_folders`.`created_at` AS `created_at`,`#{self.dbname}`.`doclibrary_folders`.`updated_at` AS `updated_at`,`#{self.dbname}`.`doclibrary_folders`.`title_id` AS `title_id`,`#{self.dbname}`.`doclibrary_folders`.`sort_no` AS `sort_no`,`#{self.dbname}`.`doclibrary_folders`.`level_no` AS `level_no`,`#{self.dbname}`.`doclibrary_folders`.`children_size` AS `children_size`,`#{self.dbname}`.`doclibrary_folders`.`total_children_size` AS `total_children_size`,`#{self.dbname}`.`doclibrary_folders`.`name` AS `name`,`#{self.dbname}`.`doclibrary_folders`.`memo` AS `memo`,`#{self.dbname}`.`doclibrary_folders`.`readers` AS `readers`,`#{self.dbname}`.`doclibrary_folders`.`readers_json` AS `readers_json`,`#{self.dbname}`.`doclibrary_folders`.`reader_groups` AS `reader_groups`,`#{self.dbname}`.`doclibrary_folders`.`reader_groups_json` AS `reader_groups_json`,`#{self.dbname}`.`doclibrary_folders`.`docs_last_updated_at` AS `docs_last_updated_at`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_flag` AS `acl_flag`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_id` AS `acl_section_id`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_code` AS `acl_section_code`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_name` AS `acl_section_name`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_id` AS `acl_user_id`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_code` AS `acl_user_code`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_name` AS `acl_user_name` from (`#{self.dbname}`.`doclibrary_folder_acls` join `#{self.dbname}`.`doclibrary_folders` on(((`#{self.dbname}`.`doclibrary_folder_acls`.`folder_id` = `#{self.dbname}`.`doclibrary_folders`.`id`) and (`#{self.dbname}`.`doclibrary_folder_acls`.`title_id` = `#{self.dbname}`.`doclibrary_folders`.`title_id`))));"
    return connection.execute(strsql)
  end

  def create_view_acl_doc_counts
    strsql = "CREATE VIEW `#{self.dbname}`.`doclibrary_view_acl_doc_counts` AS "
    strsql += "select `#{self.dbname}`.`doclibrary_docs`.`state` AS `state`,`#{self.dbname}`.`doclibrary_docs`.`title_id` AS `title_id`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_flag` AS `acl_flag`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_code` AS `acl_section_code`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_code` AS `acl_user_code`,`#{self.dbname}`.`doclibrary_docs`.`section_code` AS `section_code`,count(`#{self.dbname}`.`doclibrary_docs`.`id`) AS `cnt` from (`#{self.dbname}`.`doclibrary_docs` join `#{self.dbname}`.`doclibrary_folder_acls` on(((`#{self.dbname}`.`doclibrary_docs`.`category1_id` = `#{self.dbname}`.`doclibrary_folder_acls`.`folder_id`) and (`#{self.dbname}`.`doclibrary_docs`.`title_id` = `#{self.dbname}`.`doclibrary_folder_acls`.`title_id`)))) group by `#{self.dbname}`.`doclibrary_docs`.`state`,`#{self.dbname}`.`doclibrary_docs`.`title_id`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_flag`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_section_code`,`#{self.dbname}`.`doclibrary_folder_acls`.`acl_user_code`,`#{self.dbname}`.`doclibrary_docs`.`section_code`;"
    return connection.execute(strsql)
  end

  def set_category_folder_root
    cnn = Doclibrary::Folder.establish_connection
    cnn.spec.config[:database] = self.dbname
    folder_item = Doclibrary::Folder
    folder_item.establish_connection(cnn.spec.config)
    item = folder_item.new
    item.and :title_id, self.id
    item.and :level_no, 1
    folder = item.find(:first)
    unless folder.blank?
      folder_item.update(folder.id,
        :updated_at => Time.now,
        :_acl_create_skip => true ,
        :name => self.category1_name
      )
    else
      folder = folder_item.new(
        :state => 'public',
        :title_id => self.id,
        :parent_id => nil,
        :sort_no => 0,
        :level_no => 1,
        :_acl_create_skip => true ,
        :name => self.category1_name
      )
      folder.save!
      save_reader_all(folder.id)
    end
  end

  def save_reader_all(folder_id)
    cnn = Doclibrary::Folder.establish_connection
    cnn.spec.config[:database] = self.dbname
    item = Doclibrary::FolderAcl
    item.establish_connection(cnn.spec.config)
    item = item.new
    item.acl_flag = 0
    item.title_id = self.id
    item.folder_id = folder_id
    item.save!
  end

  def menu_item_path
    "/doclibrary/doc?title_id=#{self.id}"
  end

  def group_folders_path
    "/doclibrary/" + "group_folders?title_id=#{self.id}"
  end

  def categorys_path
    "/doclibrary/" + "categories?title_id=#{self.id}"
  end

  def new_uploads_path
    "/doclibrary/" + "docs/new?title_id=#{self.id}"
  end

  def docs_path
    "/doclibrary/" + "docs?title_id=#{self.id}"
  end

  def adm_docs_path
    "/doclibrary/" + "adms?title_id=#{self.id}"
  end

  def date_index_display_states
    {'0' => '使用する', '1' => '使用しない'}
  end
end