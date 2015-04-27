namespace :joruri do
  namespace :gwworkflow do
    desc '期限切れで削除期間が過ぎた稟議書を削除します'
    task :delete_expired => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwworkflow::Script::Task.delete
    end
  end
end
