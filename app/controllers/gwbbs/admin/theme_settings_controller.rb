class Gwbbs::Admin::ThemeSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  def pre_dispatch
    @title = nil
    @title = Gwbbs::Theme.where(:id => params[:id]).first unless params[:id].blank?
    params[:tid] = ''
    css_path = ''
    unless @title.blank?
      params[:tid] = @title.board_id
      css_path = "#{@title.board_css_preview_url}/#{@title.board_id}.css"
      item = Gwboard::Theme.where(:id => @title.theme_id).first
      f_path = "#{@title.board_css_preview_path}/#{@title.board_id}.css"
      item.theme_css_create(f_path)
    end
    if css_path.blank?
       @css = ["/_common/themes/gw/css/gwbbs_standard.css", "/_common/themes/gw/css/doc_2column.css"]
    else
      f_path = "#{RAILS_ROOT}/public/#{css_path}"
      if FileTest.exist?(f_path)
        @css = [css_path, "/_common/themes/gw/css/gwbbs_standard.css", "/_common/themes/gw/css/doc_2column.css"]
      else
        @css = ["/_common/themes/gw/css/gwbbs_standard.css", "/_common/themes/gw/css/doc_2column.css"]
      end
    end
  end

  def index
    item = Gwbbs::Theme.new
    @items = item.find(:all)
  end

  def new
    gen_select_data

    @item = Gwbbs::Theme.new({

    })
  end

  def create
    @item = Gwbbs::Theme.new(params[:item])
    parms = @item.state.split(/_/)
    @item.theme_id = parms[1]
    if parms[0] == 'prev'
      @item.state = 'prev'
      @item.content_id = 1
      @item.save
      location = "#{Core.current_node.public_uri}#{@item.id}/edit"
      redirect_to location
    end
    if parms[0] == 'public'
      @item.state = 'public'
      @item.content_id = 7

      item = Gwboard::Theme.where(:id => @item.theme_id).first
      f_path = "#{@item.board_css_file_path}/#{@item.board_id}.css"
      item.theme_css_create(f_path)

      location = Gw.chop_with("#{Core.current_node.public_uri}",'/')
      _create(@item,:success_redirect_uri=>location)
    end

  end

  def show
    @item = Gwbbs::Theme.where(:id => params[:id]).first
  end

  def edit
    @item = Gwbbs::Theme.where(:id => params[:id]).first
    return http_error(404) unless @item
    gen_select_data(@item)

  end

  def update
    @item = Gwbbs::Theme.new.find(params[:id])
    @item.attributes = params[:item]
    parms = @item.state.split(/_/)
    @item.theme_id = parms[1]
    if parms[0] == 'prev'
      @item.state = 'prev'
      @item.content_id = 3
      @item.save
      location = "#{Core.current_node.public_uri}#{@item.id}/edit"
      redirect_to location
    end
    if parms[0] == 'public'
      @item.state = 'public'
      @item.content_id = 7

      item = Gwboard::Theme.where(:id => @item.theme_id).first
      f_path = "#{@item.board_css_file_path}/#{@item.board_id}.css"
      item.theme_css_create(f_path)

      location = Gw.chop_with("#{Core.current_node.public_uri}",'/')
      _update(@item,:success_redirect_uri=>location)
    end

  end

  def destroy

  end

  def sysadm_index

    hide = false
    hide = true if params[:state] == "HIDE"
    item = Gwbbs::Control.new
    item.and :view_hide , 0 if hide
    item.and :view_hide , 1 unless hide
    item.and "sql", "create_section IS NULL" unless params[:state] == "SECTION"
    item.and "sql", "create_section IS NOT NULL" if params[:state] == "SECTION"
    item.page  params[:page], params[:limit]
    @select_bbs = item.find(:all,:order => 'sort_no, id').map{|u| [u.title, u.id]}
  end

  def bbsadm_index
    hide = false
    hide = true if params[:state] == "HIDE"

    sql = Condition.new
    sql.and "gwbbs_controls.state", 'public'
    sql.and "gwbbs_controls.view_hide", 0 if hide
    sql.and "gwbbs_controls.view_hide", 1 unless hide
    sql.and {|d|
      d.or {|d2|
        d2.and "gwbbs_roles.role_code", 'a'
        d2.and "gwbbs_roles.user_code", Core.user.code
      }
      d.or {|d2|
        d2.and "gwbbs_roles.role_code", 'a'
        d2.and "gwbbs_roles.user_id", 'IS', nil
        d2.and "gwbbs_roles.group_code", Core.user_group.code
      }
    }
    join = "INNER JOIN gwbbs_roles ON gwbbs_controls.id = gwbbs_roles.title_id"
    item = Gwbbs::Control.new
    item.page   params[:page], params[:limit]
    @select_bbs = item.find(:all, :joins=>join, :conditions=>sql.where,:order => 'sort_no, id', :group => 'gwbbs_controls.id').map{|u| [u.title, u.id]}
  end

  def gen_select_data(theme=nil)
    if Gwbbs::Control.is_sysadm?
      sysadm_index
    else
      bbsadm_index
    end

    item = Gwboard::Theme.new
    item.and 'id', '!=' , theme.theme_id  unless theme.blank?
    item.and :content_id, '>=' , 3
    item.page params[:page], params[:limit]
    @themes = item.find(:all)
  end

private

  def theme_params
    params.require(:item).permit(:board_id)
  end

end
