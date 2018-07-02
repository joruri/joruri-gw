class Gwboard::Admin::AttachmentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout 'admin/gwboard_base'

  def pre_dispatch
    return http_error(404) if params[:system].blank?

    @title = Gwboard.control_model(params[:system]).find(params[:title_id])
  end

  def index
    @items = @title.files.where(parent_id: params[:parent_id]).order(:id)
  end

  def create
    @item = @title.files.build(
      file: params[:item].try('[]', :upload),
      memo: params[:item].try('[]', :memo),
      parent_id: params[:parent_id],
      content_id: @title.upload_system,
      db_file_id: 0
    )

    if @item.save
      redirect_to gwboard_attachments_path(parent_id: params[:parent_id], system: params[:system], title_id: params[:title_id], wiki: params[:wiki])
    else
      index
      render :index
    end
  end

  def destroy
    @item = @title.files.find(params[:id])
    @item.destroy

    redirect_to gwboard_attachments_path(parent_id: params[:parent_id], system: params[:system], title_id: params[:title_id], wiki: params[:wiki])
  end

  def download
    return error_auth unless @title.is_readable?

    params[:id] = "#{params[:u_code]}#{params[:d_code]}"

    @item = load_file(@title, params[:id])
    return http_error(404) unless @item

    check_id = file_check_id(@item, params[:id])
    return http_error(404) if params[:name] != sprintf('%08d', Util::CheckDigit.check(check_id))

    if @item.is_image
      send_data File.binread(@item.f_name), filename: @item.filename, type: @item.content_type, disposition: 'inline'
    else
      send_data File.binread(@item.f_name), filename: @item.filename, type: @item.content_type
    end
  rescue => e
    error_log e
    return http_error(404)
  end

  def update_file_memo
    @file = @title.files.find(params[:id])
    @file.memo  = params[:file]['memo']
    @file.save

    ret = ''
    ret += "&state=#{params[:state]}" unless params[:state].blank?
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    ret += "&grp=#{params[:grp]}" unless params[:grp].blank?
    ret += "&gcd=#{params[:gcd]}" unless params[:gcd].blank?
    ret += "&page=#{params[:page]}" unless params[:page].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    ret += "&kwd=#{params[:kwd]}" unless params[:kwd].blank?

    if params[:system].to_s == 'doclibrary'
      if @title.form_name == 'form002'
        parent  = Doclibrary::Doc.where(id: params[:parent_id]).first
        parent_show_path  = "/doclibrary/docs/#{parent.id}?system=#{params[:system]}&title_id=#{params[:title_id]}"+ret
      else
        parent_show_path  = "/doclibrary/docs/#{@file.parent_id}?system=#{params[:system]}&title_id=#{params[:title_id]}"+ret
      end
      redirect_to parent_show_path
      return
    end
    if params[:system].to_s == 'digitallibrary'
      parent_show_path  = "/digitallibrary/docs/#{@file.parent_id}?system=#{params[:system]}&title_id=#{params[:title_id]}"+ret
      redirect_to parent_show_path
      return
    end
    if params[:system].to_s == 'gwbbs'
      parent_show_path  = "/gwbbs/docs/#{@file.parent_id}?title_id=#{params[:title_id]}"+ret
      redirect_to parent_show_path
      return
    end

    redirect_to gwboard_attachments_path(params[:parent_id]) + "?system=#{params[:system]}&title_id=#{params[:title_id]}"
  end

private

  def load_file(title, id)
    item =
      if params[:system] == 'gwmonitor_base'
        title.base_files.find_by(id: id)
      else
        title.files.find_by(id: id)
      end
    item ||= title.files.find_by(serial_no: id, migrated: 1) if migrated_system?(params[:system])
    item
  end

  def file_check_id(item, id)
    if migrated_file_request?(item, id)
      item.doc.serial_no
    else
      item.parent_id
    end
  end

  def migrated_system?(system)
    system.in?(['gwbbs', 'gwfaq', 'gwqa', 'doclibrary', 'digitallibrary'])
  end

  def migrated_file_request?(item, id)
    item.has_attribute?(:serial_no) && item.serial_no == id.to_i
  end
end
