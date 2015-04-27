namespace :joruri do
  namespace :digitallibrary do
    desc '不要となった電子図書のデータを削除します'
    task :delete_preparation => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Digitallibrary::Script::Task.preparation_delete
    end
  end
end
