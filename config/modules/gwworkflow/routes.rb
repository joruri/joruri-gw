Rails.application.routes.draw do

  get 'gwworkflow', :to => redirect('gwworkflow/docs')
  get 'gwworkflow?cond=:cond', :to => redirect('gwworkflow/docs?cond=%{cond}')
  get 'gwworkflow/show/:id', :to => redirect('gwworkflow/docs/%{id}')

  namespace 'gwworkflow' do
    scope :module => 'admin' do
      resources :docs do
        member do
          get :elaborate, :reapply, :pullback
          get :approve
          post :commit
        end
        collection do
          get :ajax_custom_route
        end
      end
      resources :itemdeletes
      resources :settings
      resources :custom_routes do
        collection do
          put :sort_update
        end
      end
    end
  end

  scope '_admin' do
    resources 'gwworkflow' do
      resources :attachments, :controller => 'gwworkflow/admin/attachments'
      resources :export_files, :controller => 'gwworkflow/admin/export_files'
    end
  end
end
