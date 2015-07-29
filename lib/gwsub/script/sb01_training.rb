# encoding: utf-8
require 'date'
class Gwsub::Script::Sb01_training
  def self.delete_abandoned_files(hours=24)
		#保存されなかった研修登録でUpされた画像、添付ファイルを削除する
    dump "Gwsub::Script::Sb01_training.delete_abandoned_files 不要な添付ファイルの削除 #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}に作業開始"

		before_when_to_delete = (Time.now - 60 * 60 * hours).strftime("%Y-%m-%d %H:%M:%S");
    dump "Gwsub::Script::Sb01_training.delete_abandoned_files #{before_when_to_delete}より前に作成され破棄されたテンポラリの添付ファイルを削除します。"

		rc = Gwsub::Sb01TrainingFile.get_abandoned_files(before_when_to_delete)
		rc.each do |r|
	    dump "Gwsub::Script::Sb01_training.delete_abandoned_files 不要な添付ファイルの削除 id=#{r.id}, parent_id=#{r.parent_id}"
			r.delete_record
		end

    dump "Gwsub::Script::Sb01_training.delete_abandoned_files 不要な添付ファイルの削除 #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}に作業終了"
  end
end
