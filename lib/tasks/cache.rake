namespace :cache do
  desc 'Clear cache'
  task :clear => :environment do
    Rails.cache.clear
  end
end
