JoruriGw::Application.routes.draw do

  scope '_admin' do
    resources 'gwmonitor' do
      resources :attachments, :controller => 'gwmonitor/admin/attachments'
      resources :base_attachments, :controller => 'gwmonitor/admin/base_attachments'
      resources :export_files, :controller => 'gwmonitor/admin/export_files'
      resources :ajaxgroups, :controller => 'gwmonitor/admin/ajaxgroups' do
        collection do
          get :getajax
        end
      end
    end
  end
    
  namespace :gwmonitor do
    scope :module => :admin do
        resources :docs, :controller => 'menus/docs', :path => ':title_id/docs'
        resources :results, :controller => 'menus/results', :path => ':title_id/results'
        resources :csv_exports, :controller => 'menus/csv_exports', :path => ':title_id/csv_exports' do
            collection do
              put :export_csv
            end
        end
        resources :file_exports, :controller => 'menus/file_exports', :path => ':title_id/file_exports' do
            collection do
              get :export_file
            end
        end
      resources :ajaxusergroups do
        collection do
          get :getajax
        end
      end
      resources :menus
      resources :settings
      resources :help_configs
      resources :custom_groups do
        collection do
          put :sort_update
        end
      end
      resources :custom_user_groups do
        collection do
          put :sort_update
        end
      end
      resources :itemdeletes
      resources :builders

    end
  end

  resources :gwmonitor,  :controller => 'gwmonitor/admin/menus'

  
  match 'gwmonitor/builders/:id/closed' => 'gwmonitor/admin/builders#closed'
  match 'gwmonitor/builders/:id/reopen' => 'gwmonitor/admin/builders#reopen'
  match 'gwmonitor/:title_id/docs/:id/editing_state_setting' => 'gwmonitor/admin/menus/docs#editing_state_setting'
  match 'gwmonitor/:title_id/docs/:id/draft_state_setting' => 'gwmonitor/admin/menus/docs#draft_state_setting'
  match 'gwmonitor/:title_id/docs/:id/clone' => 'gwmonitor/admin/menus/docs#clone'

end
