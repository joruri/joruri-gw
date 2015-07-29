# encoding: utf-8
class System::Admin::UsersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
    return authentication_error(403) unless @u_role

    params[:state] = params[:state].presence || 'enabled'
    
    item = System::User.new
    item.search params
    item.and :ldap, params[:ldap] if params[:ldap] && params[:ldap] != 'all'
    item.and :state, params[:state] if params[:state] && params[:state] != 'all'
    item.page params[:page], nz(params[:limit], 30)
    item.order params[:sort], :code
    @items = item.find(:all)
    
    _index @items
  end

  def show
    init_params
    return authentication_error(403) unless @u_role
    @item = System::User.new.find(params[:id])

  end

  def new
    init_params
    return authentication_error(403) unless @u_role
    top_cond = "level_no=1"
    @top        = System::Group.find(:first,:conditions=>top_cond)
    @group_id = @top.id
    @item = System::User.new({
      :state      =>  'enabled',
      :ldap       =>  '0'
    })
  end

  def create
    init_params
    return authentication_error(403) unless @u_role

    @item = System::User.new(params[:item])
    @item.id = params[:item]['id']

    options={
      :location => system_users_path,
      :params=>params
    }
    ret = @item.save_with_rels(options)

    if ret[0]==true
      flash[:notice] = ret[1] || '登録処理が完了しました。'
      status = params[:_created_status] || :created
      options[:location] ||= url_for(:action => :index)
      respond_to do |format|
        format.html { redirect_to options[:location] }
        format.xml  { render :xml => @item.to_xml(:dasherize => false), :status => status, :location => url_for(:action => :index) }
      end
    else
      flash.now[:notice] = '登録処理に失敗しました。' + ' ' + ret[1]
      respond_to do |format|
        format.html { render :action => :new }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    init_params
    return authentication_error(403) unless @u_role
    @item = System::User.new.find(params[:id])
  end

  def update
    init_params
    return authentication_error(403) unless @u_role

    @item = System::User.new.find(params[:id])
    @item.attributes = params[:item]
    
    location = system_user_path(@item.id)
    options = {
      :success_redirect_uri=>location
      }
    _update(@item, options)
  end

  def destroy
    init_params
    return authentication_error(403) unless @role_admin == true
    @item = System::User.find_by_id(params[:id])
    @item.state = 'disabled'
    _update(@item, {:notice => 'ユーザーを無効状態に更新しました。'})
  end
  
  def csv
    init_params
    return authentication_error(403) unless @role_admin == true

    cond  = "data_type = 'group' and level_no = 2"
    order = "code, sort_no, id"
    @csvdata = System::UsersGroupsCsvdata.find(:all, :order => order, :conditions => cond)
  end

  def csvshow
    init_params
    return authentication_error(403) unless @role_admin == true

    @item = System::UsersGroupsCsvdata.find(params[:id])
  end

  def csvup
    init_params
    return authentication_error(403) unless @role_admin == true

    return if params[:item].nil?
    par_item = params[:item]
    case par_item[:csv]
    when 'up'
      check = System::UsersGroupsCsvdata.csvup(params)
      if check[:result]
        flash[:notice] = '正常にインポートされました。'
        return redirect_to csvup_system_users_path
      else
        flash[:notice] = check[:error_msg]
        if check[:error_kind] == 'csv_error'
          file = Gw::Script::Tool.ary_to_csv(check[:csv_data])
          nkf_options = case par_item[:nkf]
          when 'utf8'
            '-w -W'
          when 'sjis'
            '-s -W'
          end
          filename = check[:error_csv_filename]
          filename = NKF::nkf('-s -W', filename) if @ie
          send_data(NKF::nkf(nkf_options, file), :type => 'text/csv', :filename => filename )
        else
          return redirect_to csvup_system_users_path
        end
      end
    else
    end
  end
  
  def csvget
    init_params
    return authentication_error(403) unless @role_admin == true
    require 'csv'

    return if params[:item].nil?
    par_item = params[:item]
    case par_item[:csv]
    when 'put'
      options = {}
      if par_item[:nkf] == 'sjis'
        options[:kcode] = 'sjis'
      end
      filename = "ユーザー・グループ情報_#{par_item[:nkf]}.csv"
      filename = NKF::nkf('-s -W', filename) if @ie

      csv_string = CSV.generate(:force_quotes => true) do |csv|
        System::UsersGroupsCsvdata.csvget.each do |x|
          csv << x
        end
      end

      csv_string = NKF::nkf('-s', csv_string) if options[:kcode] == 'sjis'
      csv_string = NKF::nkf(options[:nkf], csv_string) unless options[:nkf].nil?
      send_data(csv_string, :type => 'text/csv', :filename => filename)
    else
    end
  end

  def csvset
    init_params
    return authentication_error(403) unless @role_admin == true

    if params[:item].present? && params[:item][:csv] == 'set'
      _synchro

      if @errors.size > 0
        flash[:notice] = 'Error: <br />' + @errors.join('<br />')
      else
        flash[:notice] = '同期処理が完了しました'
      end
      redirect_to csvset_system_users_path
    else
      @count = System::UsersGroupsCsvdata.count
    end

  end
  
  def list
    init_params
    return authentication_error(403) unless @role_admin == true
    Page.title = "ユーザー・グループ 全一覧画面"

    @groups = System::Group.get_level2_groups
  end

  def init_params
		@current_no = 1
    @role_developer  = System::User.is_dev?
    @role_admin      = System::User.is_admin?
    @role_editor     = System::User.is_editor?
    @u_role = @role_developer || @role_admin || @role_editor

    @limit = nz(params[:limit],30)

    search_condition

    @css = %w(/layout/admin/style.css)
    Page.title = "ユーザー・グループ管理"
    if params[:action].index("csv").present?
      Page.title = "ユーザー・グループ CSV管理"
    end
    @ie = Gw.ie?(request)
  end

  def search_condition
    params[:limit]        = nz(params[:limit],@limit)

    qsa = ['limit', 's_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def _synchro
    @errors  = []
    cond  = "data_type = 'group' and level_no = 2"
    order = "code, sort_no, id"
    @groups = System::UsersGroupsCsvdata.new.find(:all, :order => order, :conditions => cond)

    System::User.update_all("state = 'disabled'")
    System::UsersGroup.update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'", "end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null")
    System::UsersGroupHistory.update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'", "end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null")

    System::Group.update_all("state = 'disabled'", "id != 1")
    System::Group.update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'", "id != 1 and (end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null)")

    System::GroupHistory.update_all("state = 'disabled'", "id != 1")
    System::GroupHistory.update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'", "id != 1 and (end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null)")

    group_sort_no = 0
    group_next_sort_no = Proc.new do
      group_sort_no = group_sort_no + 10
    end

    @groups.each do |d|

      cond = "parent_id = 1 and level_no = 2 and code = '#{d.code}' "
      order = "code"
      group = System::Group.find(:first, :conditions => cond, :order => order) || System::Group.new

      group.parent_id    = 1
      group.state        = d.state
      group.created_at ||= Core.now
      group.updated_at   = Core.now
      group.level_no     = 2
      group.version_id   = 0

      group.code         = d.code.to_s
      group.name         = d.name
      group.name_en      = d.name_en
      group.email        = d.email
      group.start_at     = d.start_at
      group.end_at       = d.end_at
      group.sort_no      = group_next_sort_no.call

      group.ldap_version = nil
      group.ldap         = d.ldap


      if group.id
        @errors << "group2-u : #{d.code}-#{d.name}" && next unless group.save
      else
        @errors << "group2-n : #{d.code}-#{d.name}" && next unless group.save
      end

      d.groups.each do |s|

        s_cond = "parent_id = #{group.id} and level_no = 3 and code = '#{s.code}'"
        s_order = "code"
        c_group = System::Group.find(:first, :conditions => s_cond, :order => s_order) || System::Group.new

        c_group.parent_id    = group.id
        c_group.state        = s.state
        c_group.updated_at   = Core.now
        c_group.level_no     = 3
        c_group.version_id   = 0

        c_group.code         = s.code.to_s
        c_group.name         = s.name
        c_group.name_en      = s.name_en
        c_group.email        = s.email
        c_group.start_at     = s.start_at
        c_group.end_at       = s.end_at
        c_group.sort_no      = group_next_sort_no.call

        c_group.ldap_version = nil
        c_group.ldap         = s.ldap

        if c_group.id
          @errors << "group3-u : #{s.code} - #{s.name}" && next unless c_group.save
        else
          @errors << "group3-n : #{s.code} - #{s.name}" && next unless c_group.save
        end

        user_sort_no = 0

        s.users.each do |u|
          user_sort_no = user_sort_no + 10

          cond = "code='#{u.code}'"
          user = System::User.find(:first, :conditions => cond) || System::User.new

          user.state              = u.state
          user.created_at       ||= Core.now
          user.updated_at         = Core.now

          user.code               = u.code
          user.ldap               = u.ldap
          user.ldap_version       = nil
          user.sort_no            = user_sort_no

          user.name               = u.name
          user.name_en            = u.name_en
          user.kana               = u.kana
          user.kana               = u.kana
          user.password           = u.password
          user.mobile_access      = u.mobile_access
          user.mobile_password    = u.mobile_password

          user.email              = u.email
          user.official_position  = u.official_position
          user.assigned_job       = u.assigned_job
          
          user.in_group_id        = c_group.id
          
					#そのユーザの現在の所属と違う部署に変更となった時
					user.user_groups.each do |ug|
						ug.update_attribute(:group_id, c_group.id) if ug.group_id != c_group.id
					end
					
          if user.id
            @errors << "user-u : #{u.code} - #{u.name}" && next unless user.save
          else
            @errors << "user-n : #{u.code} - #{u.name}" && next unless user.save
          end
					#save時にuser_groupsに更新がある場合があるので、読み直し
					user = System::User.find(:first, :conditions => cond)
					
          user_groups = user.user_groups # コールバックでsystem_users_groupsのデータは作成済み
          if user_groups.present?
            user_group = user_groups[0]
            if user_group.present?
              user_group.job_order = u.job_order
              user_group.start_at  = u.start_at
              user_group.end_at    = u.end_at
							user_group.save(:validate => false)
           end
					end
        end ##/users
      end ##/sections
    end ##/departments

    Rails.cache.clear
  end

end
