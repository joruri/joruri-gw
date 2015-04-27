require 'csv'
class System::Admin::UsersGroupsCsvdatasController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @current_no = 1
    @role_developer  = System::User.is_dev?
    @role_admin      = System::User.is_admin?
    @role_editor     = System::User.is_editor?
    @u_role = @role_developer || @role_admin || @role_editor
    return error_auth unless @u_role

    @css = %w(/layout/admin/style.css)
    @limit = nz(params[:limit],30)

    Page.title = "ユーザー・グループ CSV管理"
  end

  def csv
    @csvdata = System::UsersGroupsCsvdata.where(:data_type => 'group', :level_no => 2).order(:code, :sort_no, :id)
  end

  def csvshow
    @item = System::UsersGroupsCsvdata.find(params[:id])
  end

  def csvup
    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    check = System::UsersGroupsCsvdata.csvup(@item)
    if check[:result]
      flash[:notice] = '正常にインポートされました。'
      return redirect_to url_for(:action => :csvup)
    else
      #flash[:notice] = check[:error_msg]
      if check[:error_kind] == 'csv_error'
        file = Gw::Script::Tool.ary_to_csv(check[:csv_data])
        filename = check[:error_csv_filename]
        send_data @item.encode(file), :type => 'text/csv', :filename => filename
      else
        return redirect_to url_for(:action => :csvup)
      end
    end
  end

  def csvget
    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = CSV.generate(:force_quotes => true) do |csv|
      System::UsersGroupsCsvdata.csvget.each do |x|
        csv << x
      end
    end

    send_data @item.encode(csv), type: 'text/csv', filename: "ユーザー・グループ情報_#{@item.encoding}.csv"
  end

  def csvset
    if params[:item].present? && params[:item][:csv] == 'set'
      _synchro

      if @errors.size > 0
        flash[:notice] = 'Error: <br />' + @errors.join('<br />')
      else
        flash[:notice] = '同期処理が完了しました'
      end
      redirect_to url_for(:action => :csvset)
    else
      @count = System::UsersGroupsCsvdata.count
    end
  end

private

  def _synchro
    @errors  = []
    @groups = System::UsersGroupsCsvdata.where(:data_type => 'group', :level_no => 2).order(:code, :sort_no, :id)

    System::User.update_all("state = 'disabled'")
    System::UsersGroup.where("end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null").update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'")
    System::UsersGroupHistory.where("end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null").update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'")

    System::Group.where("id != 1").update_all("state = 'disabled'")
    System::Group.where("id != 1 and (end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null)").update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'")

    System::GroupHistory.where("id != 1").update_all("state = 'disabled'")
    System::GroupHistory.where("id != 1 and (end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null)").update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'")

    group_sort_no = 0
    group_next_sort_no = Proc.new do
      group_sort_no = group_sort_no + 10
    end

    @groups.each do |d|
      group = System::Group.where(:parent_id => 1, :level_no => 2, :code => d.code).order(:code).first || System::Group.new

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
        c_group = System::Group.where(:parent_id => group.id, :level_no => 3, :code => s.code).order(:code).first || System::Group.new

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

          user = System::User.where(:code => u.code).first || System::User.new

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
          user = System::User.where(:code => u.code).first

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
