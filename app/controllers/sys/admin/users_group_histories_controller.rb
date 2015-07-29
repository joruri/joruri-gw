# encoding: utf-8
class System::Admin::UsersGroupHistoriesController < Sys::Controller::Admin::Base
  include System::Controller::Scaffold
  include Sys::Controller::Scaffold::Base
  layout  'admin/sys'

  def pre_dispatch
    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = System::Group.new.find(id)
    params[:limit] = nz(params[:limit],30)

  end

  def index
    item = System::UsersGroupHistory.new #.readable
    item.group_id = @parent.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], '(user_id + 0)'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = System::UsersGroupHistory.new.find(params[:id])

    _show @item
  end

  def new
    @action='new'
    @item = System::UsersGroupHistory.new({
        :job_order=>0
    })
    @group_id  = nz(params[:group_id],@parent_id)
    @user_id    = nz(params[:user_id],Site.user.id)
  end

  def create

    @item = System::UsersGroupHistory.new(params[:item])
    _create @item
  end

  def edit
    @action='edit'
    @item = System::UsersGroupHistory.new.find(params[:id])
    @group_id  = nz(params[:group_id],@item.group_id)
    @user_id    = nz(params[:user_id],@item.user_id)
  end

  def update
    @item = System::UsersGroupHistory.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item

end

  def users_group_update(params)
    item = System::UsersGroupHistory.find(params[:id])
    item.user_id    = params[:item]['user_id']
    item.group_id   = params[:item]['group_id']
    item.job_order  = params[:item]['job_order']

    @flg_e = false unless item.save
    return
  end

  def destroy

    @item = System::UsersGroupHistory.new.find(params[:id])
    _destroy @item
  end

  def item_to_xml(item, options = {})
    options[:include] = [:user]
    xml = ''; xml << item.to_xml(options) do |n|
      #n << item.relation.to_xml(:root => 'relations', :skip_instruct => true, :include => [:user]) if item.relation
    end
    return xml
  end

  def csvput

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
      filename = "system_users_group_histories_#{par_item[:nkf]}.csv"
      items = System::UsersGroupHistory.find(:all)
      if items.blank?
      else
        file = Gw::Script::Tool.ar_to_csv(items)
        send_download "#{filename}", NKF::nkf(nkf_options,file)
      end
    else
    end
  end

  def csvup
    return if params[:item].nil?
    par_item = params[:item]
    case par_item[:csv]
    when 'up'
      raise ArgumentError, '入力指定が異常です。' if par_item.nil? || par_item[:nkf].nil? || par_item[par_item[:nkf]].nil?
      upload_data = par_item[par_item[:nkf]]
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
        System::UsersGroupHistory.truncate_table
        s_to = Gw::Script::Tool.import_csv(file, "system_users_group_histories")
      end

      redirect_to system_users_group_histories_path
    else
    end
  end
end
