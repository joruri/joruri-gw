class Gwsub::GwsubPref < ActiveRecord::Base
  # このモデルはテーブルと関連づかない抽象的なクラスと見做すためのフラグ
  self.abstract_class = true
  # database.ymlに定義された名前またはHashパラメータ渡し
end
