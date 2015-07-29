# -*- encoding: utf-8 -*-
class Gw::Admin::PrefDirectorAdminsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def initialize_scaffold
    @public_uri = "/gw/pref_director_admins"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    Page.title = "部課長在庁表示管理"
  end

  def index
    init_params
    return authentication_error(403) unless @u_role == true
    item = Gw::PrefDirector.new
    item.and 'sql', "deleted_at IS NULL"
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys

    if @g_cat == '0'
      @items = item.find(:all, :group => :parent_g_order)
    else
      item.and :parent_g_order, @g_cat.to_i
      @items = item.find(:all)
    end

    _index @items
  end

  def show
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefDirector.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @u_role == true
    @item =Gw::PrefDirector.new({:state => 'off'})
    if @g_cat != '0'
      group = Gw::PrefDirector.find(:first , :conditions=>["parent_g_order = ? AND deleted_at IS NULL",@g_cat ])
      @item.parent_g_order = @g_cat.to_i
      @item.parent_g_name = group.g_name unless group.blank?
    end
  end

  def create
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefDirector.new(params[:item])

    location = "#{@public_uri}?g_cat=#{@item.g_order}"
    options = {
      :success_redirect_uri=>location}
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefDirector.new.find(params[:id])
    @g_cat = @item.parent_g_order
    @parent_gid = @item.parent_gid
    @current_gid = System::Group.find(:first,:conditions=>"parent_id=#{@parent_gid} AND state='enabled'",:order=>'code,sort_no').id
    init_edit
  end

  def get_users
     @users = ::JsonParser.new.parse(params[:item]['schedule_users_json'])
     @users.each_with_index {|user, i|
      if user[0].blank? || user[0]==" "
        num = "0"
      else
        num = user[0]
      end
      @users[i][3] = params["title_#{user[1]}_#{num}"]
      @users[i][4] = params["icon_#{user[1]}_#{num}"]
      @users[i][5] = params["sort_no_#{user[1]}_#{num}"]
      @users[i][6] = params["is_governor_view_#{user[1]}_#{num}"]
     }
     respond_to do |format|
       format.xml { render :layout => false}
     end
  end

  def init_edit
    users = []
    director_users = Gw::PrefDirector.find(:all, :conditions=>["parent_g_order = ? and state != ? AND deleted_at IS NULL",@g_cat,"deleted"])
    director_users.each_with_index do |user, i|
      users.push ["1", user.uid, "#{user.u_name} (#{user.u_code})", user.title, "icon", user.u_order, user.is_governor_view]
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
    @item = Gw::PrefDirector.new.find(params[:id])
    @g_cat = @item.parent_g_order
    @parent_gid = @item.parent_gid
		@current_gid = System::Group.find(:first,:conditions=>"parent_id=#{@parent_gid} AND state='enabled'",:order=>'code,sort_no').id
    init_update

		begin
			b_ret = @item.save_with_rels params, :edit

		rescue
			flash[:notice] = "設定値を確認してください。"
			b_ret = false

		end
	
		if b_ret
      location = @users.size == 0 ? @public_uri : "#{@public_uri}?g_cat=#{@item.parent_g_order}"
      return redirect_to(location)
    else
      render :action => :edit
      return
    end
  end

  def init_update
    users = ::JsonParser.new.parse(params[:item]['schedule_users_json'])
    users.each_with_index {|user, i|
      num = 1
      user[3] = params["title_#{user[1]}_#{num}"]
      user[5] = params["sort_no_#{user[1]}_#{num}"]
      user[6] = params["is_governor_view_#{user[1]}_#{num}"]
    }
    @users_json = users.to_json
    @users = ::JsonParser.new.parse(@users_json)
  end

  def destroy
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefDirector.find(params[:id])
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
    @item = Gw::PrefDirector.new
    unless params[:item].blank?
      params[:item].each{|key,value|
        params[:item][key] = value.to_i
      }
    end

    if @item.errors.size == 0
      unless params[:item].blank?
       params[:item].each{|key,value|
         cgid = key.slice(8, key.length - 7 ) #sort_no_* > *
         item = Gw::PrefDirector.new.find(cgid)
         item.u_order = value
         item.save
       }
     end
     flash_notice '並び順更新', true
     redirect_to '/gw/pref_director_admins?g_cat='+params[:g_cat]
   else
     flash_notice '並び順更新', false
     redirect_to '/gw/pref_director_admins?g_cat='+params[:g_cat]
   end
  end


  def init_params
    @role_developer  = Gw::PrefDirector.is_dev?
    @role_admin      = Gw::PrefDirector.is_admin?
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
      #@l2_current = '01'
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
    @sort_keys = nz(params[:sort_keys], 'parent_g_order, u_order')
  end

  #--------------CSV出力、登録----------------
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
      filename = "bukacho_zaicho_#{par_item[:nkf]}_#{Time.now.strftime('%Y%m%d_%H%M')}.csv"
      if params[:g_cat] == "0"
        cond = ["deleted_at IS NULL"]
        order = "parent_g_order, g_order, u_order"
      else

        cond = ["deleted_at IS NULL AND parent_g_code = ?",params[:g_cat]]
        order = "g_order, u_order"
      end
      items = Gw::PrefDirector.find(:all,:conditions=>cond, :order=> order)
      if items.blank?
      else
        if params[:g_cat] != "0"
          filename = "#{items[0]. parent_g_name}_在庁表示管理_#{par_item[:nkf]}_#{Time.now.strftime('%Y%m%d_%H%M')}.csv"
        end
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
    ret = %Q("並び順","職員番号","氏名","職名","部局","Gwに表示"\n)
    items.each do |u|
      ret += %Q("#{u.u_order}","#{u.u_code}","#{u.u_name}","#{u.title}","#{u.parent_g_name}",)
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
						s_to = Gw::Script::PrefTool.import_csv(file, "gw_pref_directors_csv",params[:g_cat])

					rescue
						s_to = "CSVファイルの読み込みができませんでした。" if s_to.blank?

					end

        end
        flash[:notice]= s_to unless s_to.blank?
        location = @public_uri
        redirect_to location
      end
    else
    end
  end

  def updown
    init_params
    return authentication_error(403) unless @u_role == true

    item = Gw::PrefDirector.find_by_id(params[:id])
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
      item_rep = Gw::PrefDirector.find(:first,:conditions=>cond,:order=>order)
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
      item_rep = Gw::PrefDirector.find(:first,:conditions=>cond,:order=>order)
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

    location = "#{@public_uri}?g_cat=#{item.parent_g_order}"
    redirect_to location
    return
  end

  def g_updown
    init_params
    return authentication_error(403) unless @u_role == true
    location = @public_uri
    get_order = Gw::PrefDirector.find_by_id(params[:gid])

    return redirect_to location if get_order.blank?

    items = Gw::PrefDirector.find(:all,
        :conditions=>["parent_g_order = ?",get_order.parent_g_order])
    return redirect_to location if items.blank?
    updown = params[:order]

    case updown
    when 'up'
      cond  = "state != 'deleted' and parent_g_order < #{get_order.parent_g_order} AND deleted_at IS NULL"
      order = " parent_g_order DESC "
      get_rep_order = Gw::PrefDirector.find(:first,:conditions=>cond,:order=>order,:group=>:parent_g_order)
      return redirect_to location if get_rep_order.blank?
      item_rep  = Gw::PrefDirector.find(:all,
        :conditions=>["parent_g_order = ?",get_rep_order.parent_g_order],:order=>order)
      if item_rep.blank?
      else
        sort_work = get_rep_order.parent_g_order
        item_rep.each do |d|
          d.parent_g_order = get_order.parent_g_order
          d.save
        end
        items.each do |u|
          u.parent_g_order= sort_work
          u.save
        end
        flash[:notice] = "並び順の変更に成功しました。"
      end
    when 'down'
      cond  = "state!='deleted' and parent_g_order > #{get_order.parent_g_order}  AND deleted_at IS NULL"
      order = " g_order ASC "
      get_rep_order = Gw::PrefDirector.find(:first,:conditions=>cond,:order=>order,:group=>:parent_g_order)
      return redirect_to location if get_rep_order.blank?
      item_rep  = Gw::PrefDirector.find(:all,:conditions=>["parent_g_order = ?",get_rep_order.parent_g_order],:order=>order)
      if item_rep.blank?
      else
        sort_work = get_rep_order.parent_g_order
        item_rep.each do |d|
          d.parent_g_order = get_order.parent_g_order
          d.save
        end
        items.each do |u|
          u.parent_g_order= sort_work
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