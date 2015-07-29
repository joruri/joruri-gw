JoruriGw::Application.routes.draw do

  root :to => 'gw/admin/portal#index'

  ## Admin
  match '_admin'                 => 'sys/admin/users#index'
  match '_admin.:format'         => 'sys/admin/users#index'
  match '_admin/login.:format'   => 'sys/admin/account#login'
  match '_admin/login'           => 'sys/admin/account#login'
  match '_admin/logout.:format'  => 'sys/admin/account#logout'
  match '_admin/logout'          => 'sys/admin/account#logout'
  match '_admin/account.:format' => 'sys/admin/account#info'
  match '_admin/account'         => 'sys/admin/account#info'
  match "_admin/sso"             => "sys/admin/account#sso"
  match '_admin/air_login'       => 'sys/admin/air#old_login'
  match '_admin/air_sso'         => 'sys/admin/air#login'
  match '_admin/cms'             => 'sys/admin/front#index'
  match '_admin/sys'             => 'sys/admin/front#index'
  match '_admin/system'          => 'sys/admin/front#index'

  ## Modules
  Dir::entries("#{Rails.root}/config/modules").each do |mod|
    next if mod =~ /^\.+$/
    file = "#{Rails.root}/config/modules/#{mod}/routes.rb"
    load(file) if FileTest.exist?(file)
  end
  
  match '/tab_main/:id'  => 'gw/admin/tab_main#show'
  match '/siteinfo'      => 'gwboard/admin/siteinfo#index'
  match '/syntheses'     => 'gwboard/admin/syntheses#index'
  
  ## Attachments
  def admin_attaches(sys)
    match "_admin/_attaches/#{sys}/:title_id/:name/:u_code/:d_code", :to => "attaches/admin/#{sys}#download", :format => false
    match "_admin/_attaches/#{sys}/:title_id/:name/:u_code/:d_code/*filename", :to => "attaches/admin/#{sys}#download", :format => false

		#GW1.1.0移行対応(TinyMCE内のリンクがこのパターン）
    match "_admin/attaches/#{sys}/:title_id/:name/:u_code/:d_code", :to => "attaches/admin/#{sys}#download", :format => false
    match "_admin/attaches/#{sys}/:title_id/:name/:u_code/:d_code/*filename", :to => "attaches/admin/#{sys}#download", :format => false
  end
  
  admin_attaches('gwqa')
  admin_attaches('gwbbs')
  admin_attaches('gwfaq')
  admin_attaches('doclibrary')
  admin_attaches('digitallibrary')
  admin_attaches('gwcircular')
  admin_attaches('gwworkflow')
  admin_attaches('gwmonitor')
  admin_attaches('gwmonitor_base')
  admin_attaches('gwworkflow')
  
  ## Exception
  match '403.:format' => 'exception#index'
  match '404.:format' => 'exception#index'
  match '500.:format' => 'exception#index'
  match '*path'       => 'exception#index'

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
