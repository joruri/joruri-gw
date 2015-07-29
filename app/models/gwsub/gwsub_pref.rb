class Gwsub::GwsubPref < ActiveRecord::Base
  # このモデルはテーブルと関連づかない抽象的なクラスと見做すためのフラグ
  self.abstract_class = true
  # database.ymlに定義された名前またはHashパラメータ渡し
#  establish_connection "name_of_gw_database_from_yaml"
  establish_connection :gwsub
end
