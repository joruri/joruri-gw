class Gwboard::Admin::AjaxusersController < ApplicationController
  include System::Controller::Scaffold

  def getajax
    prm = params
    gid = prm[:s_genre].to_i
    item = System::User.new
    item.and "sql", "system_users.state = 'enabled'"
    item.and "sql", "system_users_groups.group_id = #{gid}"
    @items = item.find(:all,:select=>'system_users.*',
      :joins=>['inner join system_users_groups on system_users.id = system_users_groups.user_id'],
      :order=>'system_users.sort_no, system_users.code').collect{|x| [x.code, x.id, "#{Gw.trim(x.name)}(#{x.code})"]}
    _show @items
  end

  def getajax_recognizer
    prm = params
    gid = prm[:s_genre].to_i
    item = System::User.new
    item.and "sql", "system_users.state = 'enabled'"
    item.and "sql", "system_users_groups.group_id = #{gid}"
    item.and "sql", "NOT (system_users.id = #{params[:s_gr1g].to_i})" unless params[:s_gr1g].blank?
    item.and "sql", "NOT (system_users.id = #{params[:s_gr2g].to_i})" unless params[:s_gr2g].blank?
    item.and "sql", "NOT (system_users.id = #{params[:s_gr3g].to_i})" unless params[:s_gr3g].blank?
    item.and "sql", "NOT (system_users.id = #{params[:s_gr4g].to_i})" unless params[:s_gr4g].blank?
    item.and "sql", "NOT (system_users.id = #{params[:s_gr5g].to_i})" unless params[:s_gr5g].blank?
    @items = item.find(:all,:select=>'system_users.id,system_users.code,system_users.name',
      :joins=>['inner join system_users_groups on system_users.id = system_users_groups.user_id'],
      :order=>'system_users.sort_no, system_users.code').collect{|x| [x.id, "#{Gw.trim(x.name)}(#{x.code})"]}
    _show @items
  end
end
