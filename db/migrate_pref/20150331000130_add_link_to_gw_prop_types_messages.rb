class AddLinkToGwPropTypesMessages < ActiveRecord::Migration
  def up
    execute <<-SQL
      update gw_prop_types_messages set body = concat('<p style="text-align: left;"><img src="/_common/themes/gw/files/schedule/menu_tri_05off.gif"><a href="/gwbbs/docs/2/?title_id=2185" target="_blank">テレビ会議室の利用方法</a></p><br />', body) where type_id = 400
    SQL
  end
  def down
  end
end
