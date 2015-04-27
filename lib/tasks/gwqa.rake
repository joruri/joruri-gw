namespace :joruri do
  namespace :gwqa do
    desc '不要となったQ&Aのデータを削除します'
    task :delete_preparation => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwqa::Script::Task.preparation_delete
    end
  end
end
