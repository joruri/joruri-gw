namespace :joruri do
  namespace :gwmonitor do
    desc '期限切れで削除期間が過ぎた照会・回答を削除します'
    task :delete_expired => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwmonitor::Script::Task.delete
    end

    desc '不要となった照会・回答のデータを削除します'
    task :delete_preparation => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwmonitor::Script::Task.preparation_delete
    end
  end
end
