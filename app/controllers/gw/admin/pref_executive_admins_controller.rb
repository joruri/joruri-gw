# -*- encoding: utf-8 -*-
class Gw::Admin::PrefExecutiveAdminsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def initialize_scaffold
    @public_uri = "/gw/pref_executive_admins"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    Page.title = "全庁幹部在庁表示管理"
  end

  def index
    init_params
    return authentication_error(403) unless @u_role == true
    item = Gw::PrefExecutive.new #.readable

    item.and 'sql', "deleted_at IS NULL"
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)

    _index @items
  end

  def show
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefExecutive.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @u_role == true
    @item =Gw::PrefExecutive.new({:state => 'off'})
    if @g_cat != '0'
      group = Gw::PrefExecutive.find(:first , :conditions=>["g_order = ? AND deleted_at IS NULL",@g_cat ])
      @item.g_order = @g_cat.to_i
      @item.g_name = group.g_name unless group.blank?
    end
  end

  def create
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefExecutive.new
    if @item.save_with_rels params, :create
      location = "#{@public_uri}?g_cat=#{@item.g_order}"
      return redirect_to(location)
    else
      render :action => :new
      return
    end

  end

  def edit
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefExecutive.new.find(params[:id])
    init_edit
  end

  def get_users
     @users = ::JsonParser.new.parse(params[:item]['schedule_users_json'])
     @users.each_with_index {|user, i|
      if user[0].blank? || user[0] == " "
        num = "0"
      else
        num = user[0]
      end
      @users[i][3] = params["title_#{user[1]}_#{num}"]
      @users[i][4] = params["icon_#{user[1]}_#{num}"]
      @users[i][5] = params["sort_no_#{user[1]}_#{num}"]
      @users[i][6] = params["is_governor_view_#{user[1]}_#{num}"]
      @users[i][7] = params["is_other_view_#{user[1]}_#{num}"]
     }
     respond_to do |format|
       format.xml { render :layout => false}
     end
  end

  def init_edit
    users = []
    executive_users = Gw::PrefExecutive.find(:all, :conditions=>["state != ? AND deleted_at IS NULL","deleted"])
    executive_users.each_with_index do |user, i|
      users.push [i, user.uid, user.u_name, user.title, "icon", user.u_order, user.is_governor_view, user.is_other_view]
    end
    users = users.sort{|a,b|
      a[5] <=> b[5]
    }
    @users_json = users.to_json
    @users = ::JsonParser.new.parse(@users_json)
  end

  def update
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefExecutive.new.find(params[:id])

		begin
			b_ret = @item.save_with_rels params, :edit

		rescue
			flash[:notice] = "設定値を確認してください。"
			b_ret = false

		end

    if b_ret
      location = "#{@public_uri}?g_cat=#{@item.g_order}"
      return redirect_to(location)
    else
      init_edit
      render :action => :edit
      return
    end
  end

  def destroy
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefExecutive.find(params[:id])
    @item.state = 'disabled'
    @item.deleted_at = Time.now
    @item.deleted_user = Site.user.name
    @item.deleted_group = Site.user_group.name

    location = @public_uri
    options = {
      :success_redirect_uri=>location}
    _update(@item,options)
  end

  def sort_update
    @item = Gw::PrefExecutive.new
    unless params[:item].blank?
      params[:item].each{|key,value|
        if /^[0-9]+$/ =~ value
        else
					#数値が入っていないときは０で補う
          params[:item][key] = 0
        end
      }
    end

    if @item.errors.size == 0
      unless params[:item].blank?
       params[:item].each{|key,value|
         cgid = key.slice(8, key.length - 7 ) #sort_no_* > *
         item = Gw::PrefExecutive.new.find(cgid)
         item.u_order = value
         item.save
       }
     end
			#GUIに結果が現れる正常系の結果なので表示しない
			#flash_notice '並び順更新に成功しました。', true
     redirect_to '/gw/pref_executive_admins'
   else
     flash_notice '並び順更新に失敗しました。', true
     redirect_to '/gw/pref_executive_admins'
   end
  end

  def init_params
    @role_developer  = Gw::PrefExecutive.is_dev?
    @role_admin      = Gw::PrefExecutive.is_admin?
    @u_role = @role_developer || @role_admin

    @g_cat = nz(params[:g_cat],'0')

    @l1_current = '02'

    case params[:action]
    when 'index'
      @l2_current = '01'
    when 'new'
      @l2_current = '02'
    when 'csvput'
      @l2_current = '03'
    when 'csvup'
      @l2_current = '04'
    else
      @l2_current = '01'
    end

    @limits = nz(params[:limit],30)

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/admin.css)

  end

  def search_condition
    params[:limit] = nz(params[:limit], @limits)

    qsa = [ 'limit','s_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'u_order')
  end

  def csvput
    init_params
    return if params[:item].nil?
    par_item = params[:item]
    nkf_options = case par_item[:nkf]
        when 'utf8'
          '-w'
        when 'sjis'
          '-s'
        end
    case par_item[:csv]
    when 'put'
      filename = "kanbu_zaicho_#{par_item[:nkf]}_#{Time.now.strftime('%Y%m%d_%H%M')}.csv"
        items = Gw::PrefExecutive.find(:all,:conditions=>["deleted_at IS NULL"], :order=> "u_order")
      if items.blank?
      else
        file = csv_output(items)
        send_data(NKF::nkf(nkf_options,file), :type => 'text/csv', :filename => filename)
        return
      end
    else
      location = @public_uri
      redirect_to location
    end
  end

  def csv_output(items)
    ret = %Q("並び順","職員番号","氏名","職名","Gwに表示","AIRに表示"\n)
    items.each do |u|
      ret += %Q("#{u.u_order}","#{u.u_code}","#{u.u_name}","#{u.title}",)
      if u.is_other_view == 1
        ret += %Q("表示",)
      else
        ret += %Q("",)
      end
      if u.is_governor_view == 1
        ret += %Q("表示")
      else
        ret += %Q("")
      end
      ret += "\n"
    end
    return ret
  end

  def csvup
    init_params
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
					
					begin
						s_to = Gw::Script::PrefTool.import_csv(file, "gw_pref_executive_csv")

					rescue
						flash[:notice] = "CSVファイルの読み込みができませんでした。"

					end

        end
        location = @public_uri
        redirect_to location
      end
    else
    end
  end

  def updown
    init_params
    return authentication_error(403) unless @u_role == true

    item = Gw::PrefExecutive.find_by_id(params[:id])
    if item.blank?
      location = @public_uri
      redirect_to location
      return
    end

    updown = params[:order]

    case updown
    when 'up'
      cond  = "state != 'deleted' and u_order < #{item.u_order} and g_order = #{item.g_order} AND deleted_at IS NULL"
      order = " u_order DESC "
      item_rep = Gw::PrefExecutive.find(:first,:conditions=>cond,:order=>order)
      if item_rep.blank?
      else
        sort_work = item_rep.u_order
        item_rep.u_order = item.u_order
        item.u_order= sort_work
        item.save
        item_rep.save
        flash[:notice] = "並び順の変更に成功しました。"
      end
    when 'down'
      cond  = "state!='deleted' and u_order > #{item.u_order} and g_order = #{item.g_order} AND deleted_at IS NULL"
      order = " u_order ASC "
      item_rep = Gw::PrefExecutive.find(:first,:conditions=>cond,:order=>order)
      if item_rep.blank?
      else
        sort_work = item_rep.u_order
        item_rep.u_order = item.u_order
        item.u_order = sort_work
        item.save
        item_rep.save
        flash[:notice] = "並び順の変更に成功しました。"
      end
    else
    end

    location = "#{@public_uri}?g_cat=#{item.g_order}"
    redirect_to location
    return
  end

  def g_updown
    init_params
    return authentication_error(403) unless @u_role == true
    location = Gw.chop_with(Site.current_node.public_uri,'/')
    get_order = Gw::PrefExecutive.find_by_id(params[:gid])

    return redirect_to location if get_order.blank?

    items = Gw::PrefExecutive.find(:all,
        :conditions=>["g_order = ?",get_order.g_order])
    return redirect_to location if items.blank?
    updown = params[:order]

    case updown
    when 'up'
      cond  = "state != 'deleted' and g_order < #{get_order.g_order} AND deleted_at IS NULL"
      order = " g_order DESC "
      get_rep_order = Gw::PrefExecutive.find(:first,:conditions=>cond,:order=>order,:group=>:g_order)
      return redirect_to location if get_rep_order.blank?
      item_rep  = Gw::PrefExecutive.find(:all,
        :conditions=>["g_order = ?",get_rep_order.g_order],:order=>order)
      if item_rep.blank?
      else
        sort_work = get_rep_order.g_order
        item_rep.each do |d|
          d.g_order = get_order.g_order
          d.save
        end
        items.each do |u|
          u.g_order= sort_work
          u.save
        end
        flash[:notice] = "並び順の変更に成功しました。"
      end
    when 'down'
      cond  = "state!='deleted' and g_order > #{get_order.g_order}  AND deleted_at IS NULL"
      order = " g_order ASC "
      get_rep_order = Gw::PrefExecutive.find(:first,:conditions=>cond,:order=>order,:group=>:g_order)
      return redirect_to location if get_rep_order.blank?
      item_rep  = Gw::PrefExecutive.find(:all,
        :conditions=>["g_order = ?",get_rep_order.g_order],:order=>order)
      if item_rep.blank?
      else
        sort_work = get_rep_order.u_order
        sort_work = get_rep_order.g_order
        item_rep.each do |d|
          d.g_order = get_order.g_order
          d.save
        end
        items.each do |u|
          u.g_order= sort_work
          u.save
        end
        flash[:notice] = "並び順の変更に成功しました。"
      end
    else
    end

    location = @public_uri
    redirect_to location
    return
  end

end
