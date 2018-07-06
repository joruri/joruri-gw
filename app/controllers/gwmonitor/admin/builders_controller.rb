class Gwmonitor::Admin::BuildersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システム"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]
    page_limit_default_setting
  end

  def index
    @items = Gwmonitor::Control.without_preparation
      .tap {|c| break c.with_admin_role(Core.user) unless Gwmonitor::Control.is_sysadm? }
      .order(expiry_date: :desc, id: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = Gwmonitor::Control.find(params[:id])
    return http_error(404) if @item.state == 'preparation'
    return error_auth unless @item.is_admin?
  end

  def new
    @item = Gwmonitor::Control.create(
      :state => 'preparation',
      :section_code => Core.user_group.code,
      :send_change => '1',  #配信先は所属
      :spec_config => 3,   #他の回答者名を表示する
      :able_date => Time.now.strftime("%Y-%m-%d %H:%M"),
      :expiry_date => 7.days.since.strftime("%Y-%m-%d %H:00"),
      :upload_graphic_file_size_capacity => 100, #初期値900MB
      :upload_graphic_file_size_capacity_unit => 'MB',
      :upload_document_file_size_capacity => 1,  #初期値1G
      :upload_document_file_size_capacity_unit => 'GB',
      :upload_graphic_file_size_max => 50, #初期値5MB
      :upload_document_file_size_max => 500, #初期値300MB
      :upload_graphic_file_size_currently => 0,
      :upload_document_file_size_currently => 0,
      :reminder_start_section => 3, #デフォルト3日
      :reminder_start_personal => 0,
      :default_limit => 100,
      :upload_system => 3,
      :wiki => 0
    )

    @item.state = 'draft'
  end

  def edit
    @item = Gwmonitor::Control.find(params[:id])
    return error_auth unless @item.is_admin?
  end

  def update
    @item = Gwmonitor::Control.find(params[:id])
    #return error_auth unless @item.is_admin?

    @item.attributes = builder_params
    @item.state = 'closed' if @item.state_was == 'closed'
    @item.able_date = Time.now if @item.state_was == 'preparation' || @item.state_was == 'draft'

    #@item.form_id = 1
    @item.upload_system = 3 #
    @item.reminder_start_personal = 0

    unless params[:form_config].blank?
      config_param = params[:form_config]
      config_str = ""
      enable_str = "["
      main_title = "["
      label = "["
      unless config_param[:main_title].blank?
        config_param[:main_title].each_with_index{|sub,idx|
          main_title += %Q("#{config_param[:main_title][idx]}")
          main_title += "," if idx != 1
        }
        main_title += "]"
      end

      unless config_param[:enable].blank?
        config_param[:enable].each_with_index{|e,idx|
          enable_str += %Q("#{config_param[:enable][idx.to_s]}")
          enable_str += "," if idx != 9
        }
        enable_str += "]"
      end

      unless config_param[:label].blank?
        config_param[:label].each_with_index{|sub,idx|
          label += %Q("#{config_param[:label][idx]}")
          label += "," if idx != 9
        }
        label += "]"
      end
      config_str = %Q([#{main_title},#{enable_str},#{label}])
      @item.form_configs = config_str
    end

    _update @item
  end

  def destroy
    @item = Gwmonitor::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _destroy @item
  end

  def closed
    @item = Gwmonitor::Control.find(params[:id])
    return http_error(404) if @item.state == 'preparation'
    return error_auth unless @item.is_admin?

    @item.state = 'closed'
    @item.save

    redirect_to url_for(action: :index)
  end

  def reopen
    @item = Gwmonitor::Control.find(params[:id])
    return http_error(404) if @item.state == 'preparation'
    return error_auth unless @item.is_admin?

    @item.state = 'public'
    @item.save

    redirect_to url_for(action: :index)
  end

private
  def builder_params
    params.require(:item).permit(:title, :wiki, :caption, :wiki_caption,
      :state, :admin_setting, :spec_config, :reminder_start_section,
      :expiry_date, :form_id, :send_change, :custom_groups_json,
      :reader_groups_json, :custom_readers_json, :readers_json,
      :custom_groups => [:gid, :uid => []],
      :reader_groups => [:gid, :uid => []],
      :custom_readers => [:gid, :uid => []],
      :readers => [:gid, :uid => []],
      :main_title => [],
      :label => []).tap do |whitelisted|
        whitelisted[:enable] = params[:item][:enable].permit! if params[:item][:enable]
    end
  end

end
