namespace :joruri do
  namespace :gwbbs do
    desc '期限切れで削除期間が過ぎた掲示板を削除します'
    task :delete_expired => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwbbs::Script::Task.delete
    end

    desc '不要となった掲示板のデータを削除します'
    task :delete_preparation => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwbbs::Script::Task.preparation_delete
    end
  end
end
