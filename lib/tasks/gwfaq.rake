namespace :joruri do
  namespace :gwfaq do
    desc '不要となったFAQのデータを削除します'
    task :delete_preparation => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Gwfaq::Script::Task.preparation_delete
    end
  end
end
