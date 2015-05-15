namespace :joruri do
  namespace :gwworkflow do
    desc '期限切れで削除期間が過ぎた稟議書を削除します'
    task :delete_expired => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwworkflow::Script::Task.delete
    end

    desc '不要となった稟議書のデータを削除します'
    task :delete_preparation => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwworkflow::Script::Task.preparation_delete
    end
  end
end
