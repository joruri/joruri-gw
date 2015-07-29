# -*- encoding: utf-8 -*-
class Gw::Admin::PrefAssemblyMemberAdminsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def initialize_scaffold
    @public_uri = "/gw/pref_assembly_member_admins"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    Page.title = "議員在庁表示管理"
  end

  def index
    init_params
    return authentication_error(403) unless @u_role == true
    item = Gw::PrefAssemblyMember.new #.readable
    item.and 'sql', "deleted_at IS NULL"
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys

    if @g_cat == '0'
      @items = item.find(:all, :group => :g_order)
    else
      item.and :g_order, @g_cat.to_i
      @items = item.find(:all)
    end

    _index @items
  end

  def show
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefAssemblyMember.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @u_role == true
    @item =Gw::PrefAssemblyMember.new({:state => 'off'})
    if @g_cat != '0'
      group = Gw::PrefAssemblyMember.find(:first , :conditions=>["g_order = ? AND deleted_at IS NULL",@g_cat ])
      @item.g_order = @g_cat.to_i
      @item.g_name = group.g_name unless group.blank?
    end
  end

  def create
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefAssemblyMember.new(params[:item])
    location = "#{@public_uri}?g_cat=#{@item.g_order}"
    options = {
      :success_redirect_uri=>location}
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefAssemblyMember.find(params[:id]) #.readable
  end

  def update
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefAssemblyMember.new.find(params[:id])
    @item.attributes = params[:item]
    location = "#{@public_uri}?g_cat=#{@item.g_order}"
    options = {
      :success_redirect_uri=>location
      }
    _update(@item,options)
  end

  def destroy
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gw::PrefAssemblyMember.find(params[:id])
    @item.state = 'disabled'
    @item.deleted_at = Time.now
    @item.deleted_user = Site.user.name
    @item.deleted_group = Site.user_group.name

    location = @pubilc_uri
    options = {
      :success_redirect_uri=>location}
    _update(@item,options)
  end

  def init_params
    @role_developer  = Gw::PrefAssemblyMember.is_dev?
    @role_admin      = Gw::PrefAssemblyMember.is_admin?
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
    @sort_keys = nz(params[:sort_keys], 'g_order, u_order')
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
      filename = "giin_zaicho_#{par_item[:nkf]}.csv"
        items = Gw::PrefAssemblyMember.find(:all,:conditions=>["deleted_at IS NULL"], :order=> "g_order, u_order")
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
    ret = "会派表示順,会派,議員表示順,姓,名,在席情報\n"
    items.each do |u|
      ret.concat("#{u.g_order},#{u.g_name},#{u.u_order},#{u.u_lname},#{u.u_name}")
      ret.concat(",不在") if u.state == "off"
      ret.concat(",在席") if u.state == "on"
      ret.concat("\n")
    end
    return ret
  end

  def csvup
		b_read = false

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
          Gw::PrefAssemblyMember.truncate_table
					begin
						s_to = Gw::Script::Tool.import_csv(file, "gw_pref_assembly_members")
						b_read = true

					rescue
						flash[:notice] = "CSVファイルの読み込みができませんでした。"
						b_read = false
					end

					if b_read == true
						Gw::PrefAssemblyMember.update_all("state='on'" ,"state = '在席'")
						Gw::PrefAssemblyMember.update_all("state='off'", "state != 'on' OR state IS NULL")
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

    item = Gw::PrefAssemblyMember.find_by_id(params[:id])
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
      item_rep = Gw::PrefAssemblyMember.find(:first,:conditions=>cond,:order=>order)
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
      item_rep = Gw::PrefAssemblyMember.find(:first,:conditions=>cond,:order=>order)
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
    location = @public_uri
    get_order = Gw::PrefAssemblyMember.find_by_id(params[:gid])

    return redirect_to location if get_order.blank?

    items = Gw::PrefAssemblyMember.find(:all,
        :conditions=>["g_order = ?",get_order.g_order])
    return redirect_to location if items.blank?
    updown = params[:order]

    case updown
    when 'up'
      cond  = "state != 'deleted' and g_order < #{get_order.g_order} AND deleted_at IS NULL"
      order = " g_order DESC "
      get_rep_order = Gw::PrefAssemblyMember.find(:first,:conditions=>cond,:order=>order,:group=>:g_order)
      return redirect_to location if get_rep_order.blank?
      item_rep  = Gw::PrefAssemblyMember.find(:all,
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
      get_rep_order = Gw::PrefAssemblyMember.find(:first,:conditions=>cond,:order=>order,:group=>:g_order)
      return redirect_to location if get_rep_order.blank?
      item_rep  = Gw::PrefAssemblyMember.find(:all,
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
