# -*- encoding: utf-8 -*-
class Gwworkflow::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::ControlCommon
  include Gwboard::Model::AttachFile
  include Gwworkflow::Model::Systemname
  set_table_name 'gw_workflow_controls'

#  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state, :recognize, :title, :sort_no, :commission_limit
  validates_presence_of :upload_graphic_file_size_capacity, :upload_graphic_file_size_max, :upload_document_file_size_max
  after_validation :validate_params
  before_save :set_icon_and_wallpaper_path
  after_save :save_admingrps, :save_editors, :save_readers, :save_readers_add, :save_sueditors, :save_sureaders , :board_css_create

  attr_accessor :_makers
  attr_accessor :_design_publish

  def save_admingrps

    unless self.admingrps_json.blank?
      Gwworkflow::Adm.destroy_all("title_id=#{self.id}")
      groups = JsonParser.new.parse(self.admingrps_json)
      @dsp_admin_name = ''
      groups.each do |group|
        item_grp = Gwworkflow::Adm.new()
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
      args = ["UPDATE gw_workflow_controls SET dsp_admin_name = ? WHERE id =?", @dsp_admin_name, self.id]
      strsql = ActiveRecord::Base.send(:sanitize_sql_array, args)
      connection.execute(strsql)
    end
  end

  def save_adms
    unless self.adms_json.blank?
      users = JsonParser.new.parse(self.adms_json)
      users.each do |user|
        item_adm = Gwworkflow::Adm.new()
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
      Gwworkflow::Role.destroy_all("title_id=#{self.id} and role_code = 'w'")
      groups = JsonParser.new.parse(self.editors_json)
      groups.each do |group|
        unless group[1].blank?
          item_grp = Gwworkflow::Role.new()
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
      Gwworkflow::Role.destroy_all("title_id=#{self.id} and role_code = 'r'")
      groups = JsonParser.new.parse(self.readers_json)
      groups.each do |group|
        unless group[1].blank?
          item_grp = Gwworkflow::Role.new()
          item_grp.title_id = self.id
          item_grp.role_code = 'r'
          item_grp.group_code = group_code(group[1])
          item_grp.group_code = '0' if group[1].to_s == '0'
          item_grp.group_id = group[1]
          item_grp.group_name = group[2]
          item_grp.save!  unless item_grp.group_code.blank?
        end
      end
    end
  end

  def save_readers_add
    unless self.editors_json.blank?

      item = Gwworkflow::Role.find(:all, :conditions => "title_id=#{self.id} and role_code = 'r' and group_code = '0'")
      if item.length == 0

        groups = JsonParser.new.parse(self.editors_json)

        groups.each do |group|
          unless group[1].blank?

            item_grp = Gwworkflow::Role.find(:all, :conditions => "title_id=#{self.id} and role_code = 'r' and group_id = #{group[1]}")
            if item_grp.length == 0

              item_grp = Gwworkflow::Role.new()
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

          item_sue = Gwworkflow::Role.new()
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

          item_sue = Gwworkflow::Role.new()
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
          item_sur = Gwworkflow::Role.new()
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
    errors.add :default_published, "は数値で1以上を入力してください。" if self.default_published.blank?
    errors.add :default_published, "は数値で1以上を入力してください。" if self.default_published == 0
    errors.add :upload_graphic_file_size_capacity, "は数値で1以上を入力してください。" if self.upload_graphic_file_size_capacity.blank?
    errors.add :upload_graphic_file_size_capacity, "は数値で1以上を入力してください。" if self.upload_graphic_file_size_capacity == 0
    errors.add :upload_document_file_size_capacity, "は数値で1以上を入力してください。" if self.upload_document_file_size_capacity.blank?
    errors.add :upload_document_file_size_capacity, "は数値で1以上を入力してください。" if self.upload_document_file_size_capacity == 0
    errors.add :upload_graphic_file_size_max, "は数値で1以上を入力してください。" if self.upload_graphic_file_size_max.blank?
    errors.add :upload_graphic_file_size_max, "は数値で1以上を入力してください。" if self.upload_graphic_file_size_max == 0
    errors.add :upload_document_file_size_max, "は数値で1以上を入力してください。" if self.upload_document_file_size_max.blank?
    errors.add :upload_document_file_size_max, "は数値で1以上を入力してください。" if self.upload_document_file_size_max == 0
    errors.add :doc_body_size_capacity, "は数値で1以上を入力してください。" if self.doc_body_size_capacity.blank?
    errors.add :doc_body_size_capacity, "は数値で1以上を入力してください。" if self.doc_body_size_capacity == 0
  end

  def item_home_path
    return "/gwworkflow/"
  end

  def menus_path
    return self.item_home_path
  end

  def custom_groups_path
    return self.item_home_path + "custom_groups/"
  end

  def docs_path
    return self.item_home_path + "docs/"
  end

  def adm_show_path
    return self.item_home_path + "basics/#{self.id}"
  end

  def delete_nt_path
    return self.item_home_path + "basics/#{self.id}"
  end

  def update_nt_path
    return self.item_home_path + "basics/#{self.id}"
  end

  def design_publish_path
    return self.item_home_path + "basics/#{self.id}/design_publish"
  end

  def set_icon_and_wallpaper_path
    return unless self._makers
  end

  def original_css_file
    return "#{Rails.root}/public/_common/themes/gw/css/option.css"
  end

  def board_css_file_path
    return "#{Rails.root}/public/_attaches/css/#{self.system_name}"
  end

  def board_css_preview_path
    return "#{Rails.root}/public/_attaches/css/preview/#{self.system_name}"
  end

  def board_css_create
  end

  def default_limit_circular
    return [
      ['10行', 10],
      ['20行', 20],
      ['30行', 30],
      ['50行', 50],
      ['100行',100],
      ['150行',150],
      ['200行',200],
      ['250行',250]
    ]
  end

end
