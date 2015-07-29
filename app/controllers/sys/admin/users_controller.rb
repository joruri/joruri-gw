# encoding: utf-8
class Sys::Admin::UsersController < Sys::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  layout  'admin/sys'

  def pre_dispatch
    return redirect_to('/')

    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    Core.title = "JoruriGw admin ユーザー管理"
    @admin      = System::User.is_admin?
    return authentication_error(403) unless @admin == true
  end

  def index
    item = System::User.new
    item.search params

    @limits = Gw.nz(params[:limit], 30)
    item.page   params[:page], @limits

    item.order params[:sort], :code
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = System::User.new.find(params[:id])

    _show @item
  end

  def new
    @top = System::Group.find(:first, :conditions => "level_no=1", :order => 'sort_no')
    @item = System::User.new({
      :state       => 'enabled',
      :ldap        => '0'
    })
    @item.user_groups.build({
      :user_id   => 0,
      :group_id  => @top.id,
      :job_order => 9,
      :start_at  => Time.now
    })
  end

  def create
    @item = System::User.new(params[:item])
    
    if @item.invalid? && @item.user_groups.size == 0
      @top = System::Group.find(:first, :conditions => "level_no=1", :order => 'sort_no')
      @item.user_groups.build({
        :user_id   => 0,
        :group_id  => @top.id,
        :job_order => 9,
        :start_at  => Time.now
      })
    end
    
    _create(@item)
  end

  def edit
    @item = System::User.find_by_id(params[:id])
  end

  def update
    @item = System::User.find_by_id(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    return authentication_error(403) unless @admin == true
    @item = System::User.find_by_id(params[:id])
    @item.state = 'disabled'
    _update @item

  end

  def item_to_xml(item, options = {})
    options[:include] = [:status, :groups]
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
      filename = "system_users_#{par_item[:nkf]}.csv"
      items = System::User.find(:all)
      if items.blank?
      else
        file = Gw::Script::Tool.ar_to_csv(items, options)
        send_data(file, :type => 'text/csv', :filename => filename)
      end
    else
    end
  end

  def csvup
    flash[:notice]=''
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
        file =  NKF::nkf(nkf_options, f)
        if file.blank?
        else

          System::User.truncate_table
          s_to = Gw::Script::Tool.import_csv(file, "system_users")
        end

        redirect_to sys_users_path
      end
    else
    end
  end
end
