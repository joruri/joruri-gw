namespace :joruri do
  namespace :questionnaire do
    desc '削除期間が過ぎたアンケートを削除します'
    task :delete_expired => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Questionnaire::Script::Task.delete
    end
  end
end
