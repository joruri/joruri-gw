# encoding: utf-8
class Sys::Admin::GroupsController < Sys::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  layout  'admin/sys'

  def pre_dispatch
    return redirect_to('/')

    @action = params[:action]
    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = System::Group.find_by_id(id)
    return http_error(404) if @parent.blank?
    Core.title = "JoruriGw admin グループ管理"
    @admin      = System::User.is_admin?
    return authentication_error(403) unless @admin == true
  end
  
  def index
    item = System::Group.new
    item.parent_id = @parent.id
    item.page  params[:page], params[:limit]
    order = "state DESC,sort_no,code"
    @items = item.find(:all,:order=>order)
    _index @items
  end

  def show
    @item = System::Group.new.find(params[:id])
    _show @item
  end

  def new
    @item = System::Group.new({
        :parent_id    =>  @parent.id,
        :state        =>  'enabled',
        :level_no     =>  @parent.level_no.to_i + 1,
        :version_id   =>  @parent.version_id.to_i,
        :start_at     =>  Time.now.strftime("%Y-%m-%d 00:00:00"),
        :sort_no      =>  @parent.sort_no.to_i ,
        :ldap_version =>  nil,
        :ldap         =>  0
    })
  end
  def create
    @item = System::Group.new(params[:item])
    @item.parent_id     = @parent.id
    @item.level_no      = @parent.level_no.to_i + 1
    @item.version_id    = @parent.version_id.to_i
    @item.ldap_version  = nil
    @item.ldap          = 0
    _create @item
  end

  def update
    @item = System::Group.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::Group.new.find(params[:id])
    ug_cond="group_id=#{@item.id}"
    user_count = System::UsersGroup.count(:all,:conditions=>ug_cond)
    if user_count == 0
      @item.state  = 'disabled'
      @item.end_at = Time.now.strftime("%Y-%m-%d 00:00:00")
      _update @item
    else
      flash[:notice] = flash[:notice]||'ユーザーが登録されているため、削除できません。'
      redirect_to :action=>'index'
    end
  end
  
  def item_to_xml(item, options = {})
    options[:include] = [:status]
    xml = ''; xml << item.to_xml(options) do |n|
    end
    return xml
  end

  def csvput
    return if params[:item].nil?
    par_item = params[:item]
    case par_item[:csv]
    when 'put'
      options = {}
      if par_item[:nkf] == 'sjis'
        options[:kcode] = 'sjis'
      end
      filename = "system_groups_#{par_item[:nkf]}.csv"
      g_order="level_no ASC , code ASC "
      items = System::Group.find(:all,:order=>g_order)
      if items.blank?
      else
        file = Gw::Script::Tool.ar_to_csv(items, options)
        send_data(file, :type => 'text/csv', :filename => filename)
      end
    else
    end
  end

  def csvup
    flash[:notice] = nil
    return if params[:item].nil?
    par_item = params[:item]
    case par_item[:csv]
    when 'up'
      if par_item.nil? || par_item[:nkf].nil? || par_item[:file].nil?
        flash[:notice] = 'ファイル名を入力してください'
      else
        upload_data = par_item[:file]
        f = upload_data.read
        nkf_options = case par_item[:nkf]
        when 'utf8'
          '-w -W'
        when 'sjis'
          '-w -S'
        end
        file =  NKF::nkf(nkf_options,f)
        if file.blank?
        else
          System::Group.truncate_table
          s_to = Gw::Script::Tool.import_csv(file, "system_groups")
        end
        redirect_to sys_groups_path
      end
    else
    end
  end
  
end
