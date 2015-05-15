Rails.application.routes.draw do

  namespace 'gwworkflow' do
    scope :module => 'admin' do
      resources :itemdeletes
      resources :settings
      resources :custom_routes do
        collection do
          put :sort_update
        end
      end
    end
  end

  match 'gwworkflow',
    :controller => 'gwworkflow/gwworkflows', :action => :index,  :via => 'get'
  match 'gwworkflow',
    :controller => 'gwworkflow/gwworkflows', :action => :create, :via => 'post'
  match 'gwworkflow/new',
    :controller => 'gwworkflow/gwworkflows', :action => :new,    :via => 'get'
  match 'gwworkflow/elaborate/:id',
    :controller => 'gwworkflow/gwworkflows', :action => :elaborate,    :via => 'get'
  match 'gwworkflow/reapply/:id',
    :controller => 'gwworkflow/gwworkflows', :action => :reapply,    :via => 'get'

  match 'gwworkflow/show/:id',
    :controller => 'gwworkflow/gwworkflows', :action => :show,    :via => 'get'

  match 'gwworkflow/approve/:id',
    :controller => 'gwworkflow/gwworkflows', :action => :approve,    :via => 'get'
  match 'gwworkflow/commit/:id',
    :controller => 'gwworkflow/gwworkflows', :action => :commit,    :via => 'post'
  match 'gwworkflow/destroy/:id',
    :controller => 'gwworkflow/gwworkflows', :action => :destroy, :via => 'delete'

  match 'gwworkflow/ajax_custom_route',
    :controller => 'gwworkflow/gwworkflows', :action => :ajax_custom_route, :via => 'get'

  scope '_admin' do
    resources 'gwworkflow' do
      resources :attachments, :controller => 'gwworkflow/admin/attachments'
      resources :export_files, :controller => 'gwworkflow/admin/export_files'
    end
  end
end
