class Gwboard::Admin::ReceiptsController < ApplicationController
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias

  def initialize_scaffold
    return http_error(404) if params[:system].blank?

    item = gwboard_control
    @title = item.find_by_id(params[:title_id])
    return http_error(404) unless @title
  end

  def download_object
    mode = 0

    if params[:system] == 'gwbbs'
      mode = 2 if @title.upload_system == 2
    end

    if params[:system] == 'gwfaq'
      mode = 2 if @title.upload_system == 2
    end

    item = gwboard_file
    item = item.find_by_id(params[:id])

    chk = true
    if chk
      admin_flags
      get_readable_flag unless @is_readable
      return authentication_error(403) unless @is_readable
    end
    #IE判定
    user_agent = request.headers['HTTP_USER_AGENT']
    chk = user_agent.index("MSIE")
    chk = user_agent.index("Trident") if chk.blank?
    if chk.blank?
      item_filename = item.filename
    else
      item_filename = item.filename.tosjis
    end

    if mode == 0
      object = gwboard_db_file
      object = object.find(item.db_file_id)
      send_data(object.data, :filename => item_filename, :type => item.content_type)
      gwboard_db_file_close
    end

    if mode == 2
      f = open(item.f_name)
      if item.is_image
        send_data(f.read, :filename => item_filename, :type => item.content_type, :disposition=>'inline')
      else
        send_data(f.read, :filename => item_filename, :type => item.content_type)
      end
      f.close
    end

    gwboard_file_close
  end

end
