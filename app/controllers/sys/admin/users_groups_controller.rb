# encoding: utf-8
class Sys::Admin::UsersGroupsController < Sys::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  layout  'admin/sys'

  def pre_dispatch
    return redirect_to('/')
    
    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = System::Group.find_by_id(id)
    return http_error(404) if @parent.blank?
    params[:limit] = Gw.nz(params[:limit],30)
    Core.title = "JoruriGw admin ユーザー所属情報管理"
    @admin      = System::User.is_admin?
    return authentication_error(403) unless @admin == true
  end

  def index
    item = System::UsersGroup.new
    item.group_id = @parent.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], "user_code ASC"
    @items = item.find(:all)

    _index @items
  end

  def show
    @item = System::UsersGroup.new.find(params[:id])
    _show @item
  end

  def new
    @item = System::UsersGroup.new({
      :group_id  => @parent.id,
      :job_order => 0,
      :start_at  => Time.now 
    })
  end

  def create
    @item = System::UsersGroup.new(params[:item])
    _create @item
  end

  def edit
    @item = System::UsersGroup.new.find(params[:id])
  end

  def update
    @item = System::UsersGroup.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::UsersGroup.new.find(params[:id])
    _destroy @item
  end

  def item_to_xml(item, options = {})
    options[:include] = [:user]
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
      filename = "system_users_groups_#{par_item[:nkf]}.csv"
      items = System::UsersGroup.find(:all)
      if items.blank?
      else
        file = Gw::Script::Tool.ar_to_csv(items, options)
        send_data(file, :type => 'text/csv', :filename => filename)
      end
    else
    end
  end

  def csvup
    return if params[:item].nil?
    par_item = params[:item]
    case par_item[:csv]
    when 'up'
      raise ArgumentError, '入力指定が異常です。' if par_item.nil? || par_item[:nkf].nil? || par_item[:file].nil?
      upload_data = par_item[:file]
      f = upload_data.read
      nkf_options = case par_item[:nkf]
      when 'utf8'
        '-w -W'
      when 'sjis'
        '-w -S'
      end
      file =  NKF::nkf(nkf_options, f)
      if file.blank?
      else
        System::UsersGroup.truncate_table
        s_to = Gw::Script::Tool.import_csv(file, "system_users_groups")
      end

      redirect_to sys_users_groups_path
    else
    end
  end
end
