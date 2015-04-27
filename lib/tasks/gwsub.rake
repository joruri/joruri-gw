namespace :joruri do
  namespace :gwsub do
    namespace :sb01 do
      desc '不要となった研修申込・受付のテンポラリファイルを削除します。'
      task :delete_abandoned_files => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gwsub::Script::Sb01_training.delete_abandoned_files
      end
    end
  end
end
