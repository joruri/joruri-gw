# -*- encoding: utf-8 -*-
class Gwmonitor::Admin::Menus::FileExportsController < Gw::Controller::Admin::Base

  include System::Controller::Scaffold
  include Gwmonitor::Model::Database
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def pre_dispatch
    Page.title = "照会・回答システム"
    @title_id = params[:title_id]    
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]

    @title = Gwmonitor::Control.find_by_id(@title_id)
    return http_error(404) unless @title
  end

  def is_admin
    system_admin_flags
    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Site.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Site.user_group.code  if @title.admin_setting == 1
    return ret
  end

  def index
    return authentication_error(403) unless is_admin
    params[:nkf] = 'sjis'
  end

  def export_file
    return authentication_error(403) unless is_admin
    target_folder = "#{Rails.root}/tmp/gwmonitor/#{sprintf('%06d',@title.id)}/"
    f_name = "gwmonitor#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"
    target_zip_file = "#{Rails.root}/tmp/gwmonitor/#{f_name}"

    dirlist = Dir::glob(target_folder + "**/").sort {
      |a,b| b.split('/').size <=> a.split('/').size
    }
    begin
    dirlist.each {|d|
      Dir::foreach(d) {|f|
      File::delete(d+f) if ! (/\.+$/ =~ f)
      }
      Dir::rmdir(d)
    }
    rescue
    end
    FileUtils.remove_entry(target_zip_file, true)

    FileUtils.mkdir_p(target_folder) unless FileTest.exist?(target_folder)

    doc = Gwmonitor::Doc.new
    doc.and :title_id , @title.id
    doc.and 'sql', "state != 'preparation'"
    doc.order 'section_sort, l2_section_code, section_code'
    docs = doc.find(:all)
    for doci in docs
      file = Gwmonitor::File
      file = file.new
      file.and :title_id, @title.id
      file.and :parent_id, doci.id
      file.order  'id'
      files = file.find(:all)
      i = 0
      for filei in files
        i += 1
        clone_f_name="#{target_folder}#{doci.l2_section_code}_#{doci.section_code}_#{i}_#{filei.filename}"  if doci.send_division == 1
        clone_f_name="#{target_folder}#{doci.l2_section_code}_#{doci.section_code}_#{doci.user_code}_#{i}_#{filei.filename}"  if doci.send_division == 2
        FileUtils.cp(filei.f_name, clone_f_name)
      end
    end

    begin

    if params[:item][:nkf] == 'sjis'
      Gwmonitor::Controller::ZipFileUtils.zip(target_folder,target_zip_file, {:fs_encoding => 'Shift_JIS'})
    else
      Gwmonitor::Controller::ZipFileUtils.zip(target_folder,target_zip_file)
    end
    rescue
    end

    redirect_to "/_admin/gwmonitor/#{@title.id}/export_files?f_name=#{f_name}"
  end


  private
  def invalidtoken
    return http_error(404)
  end
end
