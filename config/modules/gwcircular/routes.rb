Rails.application.routes.draw do

  scope '_admin' do
    resources 'gwcircular' do
      resources :attachments, :controller => 'gwcircular/admin/attachments'
      resources :export_files, :controller => 'gwcircular/admin/export_files'
    end
  end

  scope '_admin' do
    namespace 'gwcircular' do
      scope :module => 'admin' do
        resources :ajaxgroups do
          collection do
            get :getajax
          end
        end
      end
    end
  end

  mod = "gwcircular"
  scp = "admin"
  namespace mod do
    scope :module => scp do
      resources :itemdeletes
      resources :basics
      resources :settings
      resources :menus
      resources :docs
      resources :custom_groups do
        collection do
          put :sort_update
        end
      end
    end
  end

  match 'gwcircular/:id/csv_exports' => 'gwcircular/admin/menus/csv_exports#index', :via =>  [:post, :get]
  match 'gwcircular/:id/csv_exports/export_csv' => 'gwcircular/admin/menus/csv_exports#export_csv', :via =>  [:put, :get]
  match 'gwcircular/:id/file_exports' => 'gwcircular/admin/menus/file_exports#index', :via =>  [:post, :get]
  match 'gwcircular/:id/file_exports/export_file' => 'gwcircular/admin/menus/file_exports#export_file', :via =>  [:post, :get]
  match 'gwcircular/menus/:id/circular_publish' => 'gwcircular/admin/menus#circular_publish', :via =>  [:post, :get]
  match 'gwcircular/docs/:id/already_update' => 'gwcircular/admin/docs#already_update', :via =>  [:post, :get]
  match 'gwcircular/docs/:id/unread_update' => 'gwcircular/admin/docs#unread_update', :via =>  [:post, :get]
  match 'gwcircular/new'       => 'gwcircular/admin/menus#new', :via =>  [:post, :get]
  match 'gwcircular'          => 'gwcircular/admin/menus#index', :via =>  [:post, :get]

end
