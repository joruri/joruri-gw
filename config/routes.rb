Rails.application.routes.draw do

  root 'gw/admin/portal#index'

  ## Admin
  match '_admin',           :to => 'gw/admin/portal#index', :via => [:get, :post]
  match '_admin/login',     :to => 'sys/admin/account#login', :via => [:get, :post]
  match '_admin/logout',    :to => 'sys/admin/account#logout', :via => [:get, :post]
  match '_admin/account',   :to => 'sys/admin/account#info', :via => [:get, :post]
  match "_admin/sso",       :to => "sys/admin/account#sso", :via => [:get, :post]
  match '_admin/air_login', :to => 'sys/admin/air#old_login', :via => [:get, :post]
  match '_admin/air_sso',   :to => 'sys/admin/air#login', :via => [:get, :post]
  match '_admin/cms',       :to => 'gw/admin/portal#index', :via => [:get, :post]
  match '_admin/sys',       :to => 'gw/admin/portal#index', :via => [:get, :post]
  match '_admin/system',    :to => 'gw/admin/portal#index', :via => [:get, :post]

  ## Modules
  Dir::entries("#{Rails.root}/config/modules").each do |mod|
    next if mod =~ /^\.+$/
    file = "#{Rails.root}/config/modules/#{mod}/routes.rb"
    load(file) if FileTest.exist?(file)
  end

  ## Etc
  match '/tab_main/:id', :to => 'gw/admin/tab_main#show', :via => :get
  match '/siteinfo',     :to => 'gwboard/admin/siteinfo#index', :via => :get
  match '/syntheses',    :to => 'gwboard/admin/syntheses#index', :via => :get

  ## Attachments v2以降
  match "_admin/_attaches/:system/:title_id/:name/:u_code/:d_code(/*filename)", :to => "gwboard/admin/attachments#download", :format => false, :via => :get
  ## Attachments v1
  match "_admin/attaches/:system/:title_id/:name/:u_code/:d_code(/*filename)", :to => "gwboard/admin/attachments#download", :format => false, :via => :get

  ## Exception
  match '403.:format' => 'exception#index', :via => :all
  match '404.:format' => 'exception#index', :via => :all
  match '500.:format' => 'exception#index', :via => :all
  match '*path'       => 'exception#index', :via => :all

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
