# -*- encoding: utf-8 -*-
class Gwboard::Admin::AjaxgroupsController < ApplicationController
  include System::Controller::Scaffold

  def getajax
    gid = params[:s_genre].to_i
    if gid == '0'
      @item = [["0", "0", "制限なし"]] if params[:msg].blank?
      @item = [["0", "0", "全ての所属"]] unless params[:msg].blank?
    else
      current_time = Time.now
      group_cond    = "state ='enabled'"
      group_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
      group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at > '#{current_time.strftime("%Y-%m-%d 23:59:59")}' ) "

      if params[:pattern] == '1'
        cond = "#{group_cond} and system_groups.parent_id = #{gid}"
      else
        cond = "(#{group_cond} and system_groups.id = #{gid}) or (#{group_cond} and system_groups.parent_id = #{gid})"
      end
      @item = System::Group.find(:all, :conditions => cond, :order => "level_no, code").collect{|x| [x.code, x.id, Gw.trim(x.name)]}
    end
    _show @item
  end

end
