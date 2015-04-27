namespace :joruri do
  namespace :core do
    task :initialize do
      Core.initialize
      if (user = System::User.where(code: 'joruri').first)
        Core.user = user
        Core.user_group = user.groups.first
      else
        Core.user = System::User.new(code: 'joruri', name: 'joruri')
        Core.user_group = System::Group.new(code: 'joruri', name: 'joruri')
      end
    end
  end
end
