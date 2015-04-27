namespace :joruri do
  namespace :system do
    namespace :session do
      desc '不要となったセッションデータを削除します'
      task :delete_expired => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        System::Script::Session.delete_expired_sessions
      end
    end

    namespace :product_synchro do
      desc '予定されているプロダクト同期を実行します'
      task :run => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        System::Script::ProductSynchroPlan.check
      end
    end
  end
end
