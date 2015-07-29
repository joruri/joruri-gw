# -*- encoding: utf-8 -*-
#######################################################################
#年次所属切り替え更新処理
########################################################################

class System::Script::Annual


  def self.system_roles_renew(start_date = nil)
    if start_date.blank?
      return false
    else
      @start_date = start_date
    end
    p "system_roles_renew 開始:#{Time.now}."
    r_groups = Gwboard::RenewalGroup.find(:all, :conditions => ["start_date = ?", @start_date], :order=> 'present_group_id, present_group_code')

    r_groups.each do |r_group|
      ids = Array.new
      update_fields1  = "group_id = #{r_group.incoming_group_id}"
      sql_where1      = "group_id = #{r_group.present_group_id}"
      _ids = System::Role.find(:all, :conditions => sql_where1, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        System::Role.update_all(update_fields1, sql_where1)
        p "system_roles　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end

      ids = Array.new
      update_fields1  = "uid = #{r_group.incoming_group_id}"
      sql_where1      = "uid = #{r_group.present_group_id} and class_id = 2"
      _ids = System::Role.find(:all, :conditions => sql_where1, :select => "id")
      unless _ids.empty?
        _ids.each do |_id|
          ids << _id.id
        end
        ids = ids.uniq
        System::Role.update_all(update_fields1, sql_where1)
        p "system_roles　対象ID：[#{Gw.join(ids, ',')}], 変更対象所属：#{sql_where1}, 更新SQL：#{update_fields1}, #{Time.now}."
      end
    end
    p "system_roles_renew 終了:#{Time.now}."
  end
end
