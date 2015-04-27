Rails.application.routes.draw do
  mod = "system"
  scp = "admin"

  namespace mod do
    scope :module => scp do
      ## admin
      resources :ldap_groups, :path => ":parent/ldap_groups"
      resources :ldap_temporaries do
          member do
            get :synchronize
            post :synchronize
            put :synchronize
            delete :synchronize
          end
        end
      resources :users do
        collection do
          get :list
        end
        member do
          get :csvshow
        end
      end
      resources :groups, :path => ":parent/groups" do
          collection do
            get :list
          end
        end
      resources :users_groups, :path => ":parent/users_groups" do
          collection do
            get :list
          end
        end
      resources :users_groups_csvdatas do
        collection do
          get :csv, :csvget, :csvup, :csvset
          post :csvup, :csvset
        end
      end
      resources "roles" do
        collection do
          get :user_fields
        end
      end
      resources "role_developers"
      resources "priv_names"
      resources "role_names"
      resources "role_name_privs" do
        collection do
          get :getajax
        end
      end
      resources :custom_groups do
        collection do
          get :create_all_group, :synchro_all_group, :all_groups_disabled_delete
          put :sort_update
          get :get_users
        end
      end
      resources :group_change_dates
      resources :group_changes do
        collection do
          get :reflect, :set_incoming_group_id, :csvup
          post :csvup
        end
      end
      resources :group_change_pickups
      resources :group_updates do
        collection do
          get :csv
          post :csvup
        end
      end
      resources :group_nexts
      resources :user_temporaries
      resources :group_temporaries
      resources :users_group_temporaries
      resources :group_history_temporaries
      resources :users_group_history_temporaries
      resources :products
      resources :product_synchros do
        collection do
          get :synchronize
        end
      end
      resources :product_synchro_plans
    end
  end

  ##API
  match 'api/checker'         => 'system/admin/api#checker', :via =>  [:post, :get]
  match 'api/checker_login'   => 'system/admin/api#checker_login', :via =>  [:post, :get]
  match 'api/air_sso'         => 'system/admin/api#sso_login', :via =>  [:post, :get]

  match 'api/dcn/approval/:ucode' => 'system/admin/api/dcn#approval', :via => [:get, :post]
  match 'api/external/reminder/CreateData' => 'system/admin/api/external_reminder#create_data', :via => :post
  match 'api/external/reminder/DeleteData' => 'system/admin/api/external_reminder#delete_data', :via => :post

  match '/api/schedule/kaigi/'         => 'system/admin/api/meeting_guides#meetings'    , :via =>  [:get]
  match '/api/schedule/backgrounds/'   => 'system/admin/api/meeting_guides#backgrounds' , :via =>  [:get]
  match '/api/schedule/notices/'       => 'system/admin/api/meeting_guides#notices'     , :via =>  [:get]
  match '/api/schedule/access/'        => 'system/admin/api/meeting_guides#accesses'    , :via =>  [:get]
  match '/api/pref/exectives'         => 'system/admin/api/access_registers#exectives'    , :via =>  [:get]
  match '/api/pref/executives'        => 'system/admin/api/access_registers#executives'    , :via =>  [:get]
  match '/api/pref/secretary'         => 'system/admin/api/access_registers#secretary'    , :via =>  [:get]
  match '/api/pref/access'            => 'system/admin/api/access_registers#access'    , :via =>  [:get]
  match '/api/pref/monitors'          => 'system/admin/api/access_registers#monitors'    , :via =>  [:get]


  match ':controller(/:action(/:id))(.:format)', :via =>  [:post, :get]
end
