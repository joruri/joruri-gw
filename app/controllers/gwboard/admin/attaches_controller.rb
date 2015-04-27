class Gwboard::Admin::AttachesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias
  layout 'admin/gwboard_base'

  def pre_dispatch
    return http_error(404) if params[:system].blank?

    @title = gwboard_control.find(params[:title_id])
  end

  def index
    @items = @title.files.where(parent_id: params[:parent_id]).order(id: :asc)
  end

  def create
    @item = @title.files.build(
      file: params[:item].try('[]', :upload),
      memo: params[:item].try('[]', :memo),
      parent_id: params[:parent_id],
      content_id: @title.upload_system
    )

    if @item.save
      redirect_to gwboard_attaches_path(parent_id: params[:parent_id], system: params[:system], title_id: params[:title_id])
    else
      index
      render :index
    end
  end

  def destroy
    @item = gwboard_file.find(params[:id])
    @item.destroy

    redirect_to gwboard_attaches_path(params[:parent_id]) + "?system=#{params[:system]}&title_id=#{params[:title_id]}"
  end

  def update_file_memo
    file = gwboard_file
    @file = file.where(:id => params[:id]).first
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

    case params[:system].to_s
    when 'doclibrary'
      if @title.form_name == 'form002'
        parent  = Doclibrary::Doc.where("id=#{params[:parent_id]}").first
        parent_show_path  = "/doclibrary/docs/#{parent.id}?system=#{params[:system]}&title_id=#{params[:title_id]}#{ret}"
      else
        parent_show_path  = "/doclibrary/docs/#{@file.parent_id}?system=#{params[:system]}&title_id=#{params[:title_id]}#{ret}"
      end
    when 'digitallibrary'
      parent_show_path  = "/digitallibrary/docs/#{@file.parent_id}?system=#{params[:system]}&title_id=#{params[:title_id]}#{ret}"
    when 'gwbbs'
      parent_show_path  = "/gwbbs/docs/#{@file.parent_id}?title_id=#{params[:title_id]}#{ret}"
    else
      parent_show_path = gwboard_attaches_path(params[:parent_id]) + "?system=#{params[:system]}&title_id=#{params[:title_id]}"
    end

    flash[:notice] = "備考を更新しました。"
    return redirect_to parent_show_path
  end
end
