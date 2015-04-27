namespace :joruri do
  namespace :gwcircular do
    desc '期限切れで削除期間が過ぎた回覧板を削除します'
    task :delete_expired => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwcircular::Script::Task.delete
    end

    desc '不要となった回覧板のデータを削除します'
    task :delete_preparation => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwcircular::Script::Task.preparation_delete
    end
  end
end
