class Gwworkflow::SettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwworkflow"

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwworkflow::Control.find(params[:title_id])

    Page.title = "ワークフロー 機能設定"
    @css = ["/_common/themes/gw/css/workflow.css"]
  end

  def index
  end

  def notifying
    setting = Gwworkflow::Setting.where(:unid => Core.user.id).first
    @notifying =  setting ? setting.notifying ? 1 : 2 : 2
  end

  def update_notifying
    setting = Gwworkflow::Setting.where(:unid => Core.user.id).first
    setting = Gwworkflow::Setting.new unless setting
    setting.notifying = (params[:notify] == '1')
    setting.unid = Core.user.id

    if setting.invalid?
      render :notifying
    else
      _update(setting, :success_redirect_uri => {:action => :notifying})
    end
  end

  def custom_routes
    @items = Gwworkflow::CustomRoute.where(:owner_uid => Core.user.id).order(:sort_no)
  end

  def custom_routes_sort
    (params[:item]||[]).map{|k,v| [k.match(/[[0-9]+]/)[0] , v] }.map{|k,v| [k.to_i, v.to_i]
    }.select{|k,v| k}.map{|k,v|
      cr = Gwworkflow::CustomRoute.find(k)
      cr.sort_no = v > 9999 ? 9999 : v; cr
    }.each{|cr| raise "W" unless cr.save }
    redirect_to :action => :custom_routes
  end

  def custom_routes_new
    @item = Gwworkflow::CustomRoute.new
    @item.state = 'enabled'
    @item.sort_no = '10'
    @item.owner_uid = Core.user.id
  end

  def custom_routes_create
    @item = Gwworkflow::CustomRoute.new
    @item.state = params[:item][:state]
    @item.sort_no = params[:item][:sort_no]
    @item.name = params[:item][:name]
    @item.owner_uid = Core.user.id
    (params[:committees]||[]).map{|s| s.to_i }.map{|id|
      user = System::User.find(id); [ id, user.name, user.group_name ]
    }.each.with_index{|(id,name,gname),idx|
      step = @item.steps.build :number => idx
      step.committees.build :user_id => id, :user_name => name, :user_gname => gname
    }

    if @item.invalid?
      render :custom_routes_new
    else
      _create(@item, :success_redirect_uri => {:action => :custom_routes})
    end
  end

  def custom_routes_edit
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return error_auth unless @item.owner_uid == Core.user.id

  end
  def custom_routes_update
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return error_auth unless @item.owner_uid == Core.user.id
    @item.state = params[:item][:state]
    @item.sort_no = params[:item][:sort_no]
    @item.name = params[:item][:name]
    @item.owner_uid = Core.user.id
    @item.steps.each{|s|s.destroy}
    (params[:committees]||[]).map{|s| s.to_i }.map{|id|
      user = System::User.find(id); [ id, user.name, user.group_name ]
    }.each.with_index{|(id,name,gname),idx|
      step = @item.steps.build :number => idx
      step.committees.build :user_id => id, :user_name => name, :user_gname => gname
    }

    if @item.invaild?
      render :custom_routes_edit
    else
      _update(@item, :success_redirect_uri => {:action => :custom_routes})
    end
  end

  def custom_routes_destroy
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return error_auth unless @item.owner_uid == Core.user.id
    @item.destroy
    redirect_to :action => :custom_routes
  end
end
