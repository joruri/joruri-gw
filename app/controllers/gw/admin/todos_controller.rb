# encoding: utf-8
class Gw::Admin::TodosController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/todo"

  def initialize_scaffold
    @s_finished = params[:s_finished] || '1'
    Page.title = "ToDo"
    @redirect_uri = gw_todos_path({:s_finished=>@s_finished})
    @css = %w(/_common/themes/gw/css/todo.css)
    params[:limit] = 10 if request.mobile?
  end

  def index
    item = Gw::Todo.new
    item.page  params[:page], params[:limit]
    cond = Gw::Todo.cond
    cond += case params[:s_finished]
    when "2" # 既読
      ' and coalesce(is_finished, 0) = 1'
    when "3" # 両方
      ''
    else # 未読
      ' and coalesce(is_finished, 0) != 1'
    end
    qsa = %w(s_finished)
    @qs = qsa.delete_if{|x| params[x] || '' ==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
    @sort_keys = CGI.unescape(params[:sort_keys] || '')
    sk = @sort_keys
    sort_title_flg = false
    if /^_title (.+)$/ =~ sk
      sort_title_flg = true
      sort_title_order = $1
      sk = ''
    end
    order = Gw.join([sk, 'is_finished', "#{Gw.order_last_null :ed_at}"], ',')
    @items = item.find(:all, :conditions => cond, :order => order)
    @items.sort!{|a,b| sort_title_order == 'asc' ? (a._title <=> b._title) : (b._title <=> a._title)} if sort_title_flg
  end

  def show
    item = Gw::Todo.new
    @item = item.find(params[:id])
  end

  def new
    @item = Gw::Todo.new({})
  end

  def quote
    @item = Gw::Todo.new.find(params[:id])
  end

  def create
    params[:item] = mobile_params(params[:item]) if request.mobile?
    item = params[:item]
    @item = Gw::Todo.new(item)
    @item.class_id = 1
    @item.uid = Core.user.id
    @item.ed_at = params[:item][:ed_at]
    #begin
    #  @item.ed_at = Gw.date_common(Gw.get_parsed_date(params[:item][:ed_at]))
    #rescue
    #end
    _create @item, :success_redirect_uri => '/gw/todos/[[id]]', :notice => 'ToDoの登録に成功しました'
  end

  def update
    @item = Gw::Todo.find(params[:id])
    params[:item] = mobile_params(params[:item]) if request.mobile?
    item = params[:item]
    item[:class_id] = 1
    item[:uid] = Core.user.id
    begin
      item[:ed_at] = Gw.date_common(Gw.get_parsed_date(params[:item][:ed_at]))
    rescue
    end
    @item.attributes = item
    _update @item, :success_redirect_uri => '/gw/todos/[[id]]', :notice => "ToDoの更新に成功しました"
  end

  def destroy
    @item = Gw::Todo.find(params[:id])
    @item.destroy
    return redirect_to @redirect_uri
  end

  def setting
    #
  end

  def finish
    @item = Gw::Todo.find(params[:id])
    item = {}
    item[:class_id] = 1
    item[:uid] = Core.user.id
    act = true
    act = false if @item.is_finished  == 1 unless @item.is_finished.blank?
    item[:is_finished] = act ? 1 : nil
    @item.attributes = item
    _update @item, :success_redirect_uri => @redirect_uri, :notice => "ToDoを#{act ? '完了する' : '未完了に戻す'}処理に成功しました"
  end

  def confirm
    item = Gw::Todo.new
    @item = item.find(params[:id])
  end

  def delete
    @item = Gw::Todo.find(params[:id])
    _destroy(@item,:success_redirect_uri=>@redirect_uri)
  end

  def mobile_params(params)
    ed_at_str = %Q(#{params['ed_at(1i)']}-#{params['ed_at(2i)']}-#{params['ed_at(3i)']})
    params.delete "ed_at(1i)"
    params.delete "ed_at(2i)"
    params.delete "ed_at(3i)"
    params[:ed_at]= ed_at_str
    return params
  end





  # 自分以外のTODOを見られないようにする
  def auth_cndt(item_id)
    if item_id
      item = Gw::Todo.find(item_id)
      return (Site.user.id != item[:uid])
    end
    return true
  end
  alias authcheck_show show
  def show
    return authentication_error(403) if auth_cndt(params[:id])
    authcheck_show
  end
  alias authcheck_delete delete
  def delete
    return authentication_error(403) if auth_cndt(params[:id])
    authcheck_delete
  end
  alias authcheck_update update
  def update
    return authentication_error(403) if auth_cndt(params[:id])
    authcheck_update
  end
  alias authcheck_destroy destroy
  def destroy
    return authentication_error(403) if auth_cndt(params[:id])
    authcheck_destroy
  end

end


