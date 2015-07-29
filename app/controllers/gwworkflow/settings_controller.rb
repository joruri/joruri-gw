# encoding:utf-8
class Gwworkflow::SettingsController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize
  layout "admin/template/gwworkflow"

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken


  def pre_dispatch
    params[:title_id] = 1
    @title = Gwworkflow::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    Page.title = "ワークフロー 機能設定"
    @css = ["/_common/themes/gw/css/workflow.css"]
    @js = %w(/_common/js/yui/build/animation/animation-min.js /_common/js/popup_calendar/popup_calendar.js /_common/js/yui/build/calendar/calendar.js /_common/js/dateformat.js)
  end

  def index
    
  end


  def notifying
    setting = Gwworkflow::Setting.where(:unid => Site.user.id).first
    @notifying =  setting ? setting.notifying ? 1 : 2 : 2
  end

  def update_notifying
    setting = Gwworkflow::Setting.where(:unid => Site.user.id).first
    setting = Gwworkflow::Setting.new unless setting
    setting.notifying = (params[:notify] == '1') 
    setting.unid = Site.user.id
    _update(setting, :success_redirect_uri => {:action => :notifying}, :failured_action => :notifying)
  end
  
  def custom_routes
    @items = Gwworkflow::CustomRoute.where(:owner_uid => Site.user.id).sort{|a,b|
      b.sort_no <=> a.sort_no
    }
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
    @item.owner_uid = Site.user.id
  end
  
  def custom_routes_create
    @item = Gwworkflow::CustomRoute.new
    @item.state = params[:item][:state]
    @item.sort_no = params[:item][:sort_no]
    @item.name = params[:item][:name]
    @item.owner_uid = Site.user.id
    (params[:committees]||[]).map{|s| s.to_i }.map{|id|
      user = System::User.find(id); [ id, user.name, user.group_name ]
    }.each.with_index{|(id,name,gname),idx|
      step = @item.steps.build :number => idx
      step.committees.build :user_id => id, :user_name => name, :user_gname => gname
    }
    _create(@item, :success_redirect_uri => {:action => :custom_routes}, :failured_action => :custom_routes_new)
  end
  
  def custom_routes_edit
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless @item.owner_uid == Site.user.id

  end
  def custom_routes_update
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless @item.owner_uid == Site.user.id
    @item.state = params[:item][:state]
    @item.sort_no = params[:item][:sort_no]
    @item.name = params[:item][:name]
    @item.owner_uid = Site.user.id
    @item.steps.each{|s|s.destroy}
    (params[:committees]||[]).map{|s| s.to_i }.map{|id|
      user = System::User.find(id); [ id, user.name, user.group_name ]
    }.each.with_index{|(id,name,gname),idx|
      step = @item.steps.build :number => idx
      step.committees.build :user_id => id, :user_name => name, :user_gname => gname
    }
    _update(@item, :success_redirect_uri => {:action => :custom_routes}, :failured_action => :custom_routes_edit)
  end
  
  def custom_routes_destroy
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless @item.owner_uid == Site.user.id
    @item.destroy
    redirect_to :action => :custom_routes
  end
end
