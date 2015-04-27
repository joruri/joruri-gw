namespace :joruri do
  namespace :doclibrary do
    desc '不要となった書庫のデータを削除します'
    task :delete_preparation => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      Doclibrary::Script::Task.preparation_delete
    end
  end
end
