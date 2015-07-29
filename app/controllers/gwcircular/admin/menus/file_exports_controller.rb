class Gwcircular::Admin::Menus::FileExportsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    @parent = Gwcircular::Doc.find_by_id(params[:parent_id])
    return http_error(404) unless @parent
    return http_error(404) unless @parent.doc_type == 0
  end

  def index
    get_role_index
    @is_readable = false unless @parent.target_user_code == Site.user.code unless @is_admin
    return authentication_error(403) unless @is_readable
    Page.title = @title.title
    params[:nkf] = 'sjis'
  end

  def export_file
    target_folder = "#{Rails.root}/tmp/gwcircular/#{sprintf('%06d',@parent.id)}/"
    target_zip_file = "#{Rails.root}/tmp/gwcircular/#{sprintf('%06d',@parent.id)}.zip"

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

    doc = Gwcircular::Doc.new
    doc.and :title_id , @title.id
    doc.and :doc_type , 1
    doc.and :parent_id , @parent.id
    doc.and :state , 'preparation' unless params[:cond].blank?
    doc.and 'sql', "state != 'preparation'" if params[:cond].blank?
    docs = doc.find(:all)
    for doci in docs
      file = Gwcircular::File
      file = file.new
      file.and :title_id, 1
      file.and :parent_id, doci.id
      file.order  'id'
      files = file.find(:all)
      for filei in files
        clone_f_name="#{target_folder}#{doci.editor_id}_#{filei.filename}"
        FileUtils.cp(filei.f_name, clone_f_name)
      end
    end

    begin

    if params[:item][:nkf] == 'sjis'
      Gwcircular::Controller::ZipFileUtils.zip(target_folder,target_zip_file, {:fs_encoding => 'Shift_JIS'})
    else
      Gwcircular::Controller::ZipFileUtils.zip(target_folder,target_zip_file)
    end
    rescue
    end
    dump("target_folder:#{target_folder}, target_zip_file:#{target_zip_file}")
    redirect_to "/_admin/gwcircular/#{@parent.id}/export_files"
  end


  private
  def invalidtoken
    return http_error(404)
  end
end
