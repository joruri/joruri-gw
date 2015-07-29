# -*- encoding: utf-8 -*-
#######################################################################
#GWテーブル　年次所属切り替え更新処理
########################################################################

class Gw::Script::Annual


  def self.renew(start_date = nil)
    if start_date.blank?
      return false
    else
      @start_date = start_date
    end
    p "GWテーブル年次切替所属情報更新 開始:#{Time.now}."
    gw_prop_other_renew
    p "GWテーブル年次切替所属情報更新 終了:#{Time.now}."
  end

  #一般施設マスタテーブル、および管理マスタ
  def self.gw_prop_other_renew
    p "gw_prop_other_renew 開始:#{Time.now}."
    r_groups = Gwboard::RenewalGroup.find(:all,:conditions=>["start_date = ?", @start_date], :order=> 'present_group_id, present_group_code')

    r_groups.each do |r_group|
      ids = Array.new
      update_fields1  = "gid = #{r_group.incoming_group_id}, gname = '#{r_group.incoming_group_name}'" # 更新SQL
      update_set = [ "gid = ?, gname = ?",r_group.incoming_group_id,r_group.incoming_group_name]
      sql_where1      = "gid = #{r_group.present_group_id}" # 検索SQL
      _ids = Gw::PropOther.find(:all, :conditions => sql_where1, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Gw::PropOther.update_all(update_set, sql_where1)
        p "gw_prop_others　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end

      ids = Array.new
      update_fields1  = "gid = #{r_group.incoming_group_id}"
      sql_where1      = "gid = #{r_group.present_group_id}"
      update_set = [ "gid = ?",r_group.incoming_group_id]
      _ids = Gw::PropOtherRole.find(:all, :conditions => sql_where1, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        Gw::PropOtherRole.update_all(update_set, sql_where1)
        p "gw_prop_other_roles　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end
    end
    p "gw_prop_other_renew 終了:#{Time.now}."
  end


end
