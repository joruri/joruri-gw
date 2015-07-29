JoruriGw::Application.routes.draw do


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

  match 'gwworkflow/settings',
    :controller => 'gwworkflow/settings',    :action => :index,    :via => 'get'
  match 'gwworkflow/custom_routes',
    :controller => 'gwworkflow/settings',    :action => :custom_routes,    :via => 'get'
  match 'gwworkflow/custom_routes/sort',
    :controller => 'gwworkflow/settings',    :action => :custom_routes_sort,    :via => 'put'
  match 'gwworkflow/custom_routes/new',
    :controller => 'gwworkflow/settings',    :action => :custom_routes_new,    :via => 'get'
  match 'gwworkflow/custom_routes',
    :controller => 'gwworkflow/settings', :action => :custom_routes_create, :via => 'post'
  match 'gwworkflow/custom_routes/edit/:id',
    :controller => 'gwworkflow/settings',    :action => :custom_routes_edit,    :via => 'get'
  match 'gwworkflow/custom_routes',
    :controller => 'gwworkflow/settings', :action => :custom_routes_update, :via => 'put'
  match 'gwworkflow/custom_routes/destroy/:id',
    :controller => 'gwworkflow/settings', :action => :custom_routes_destroy, :via => 'get'

  match 'gwworkflow/ajax_custom_route',
    :controller => 'gwworkflow/gwworkflows', :action => :ajax_custom_route, :via => 'get'
  
  scope '_admin' do
    resources 'gwworkflow' do
      resources :attachments, :controller => 'gwworkflow/admin/attachments'
      resources :export_files, :controller => 'gwworkflow/admin/export_files'
    end
  end
  
  mod = "gwworkflow"
  scp = "admin"
  namespace mod do
    scope :module => scp do
      resources :itemdeletes
    end
  end
  
  match 'gwworkflow/notifying',
    :controller => 'gwworkflow/settings',    :action => :notifying,    :via => 'get'
  match 'gwworkflow/update_notifying',
    :controller => 'gwworkflow/settings',    :action => :update_notifying,    :via => 'put'
end
