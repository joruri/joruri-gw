JoruriGw::Application.routes.draw do
  mod = "system"
  scp = "admin"

  namespace mod do
    scope :module => scp do
      ## admin
      resources "ldap_groups",
        :controller => "ldap_groups",
        :path => ":parent/ldap_groups"
      resources "ldap_temporaries",
        :controller => "ldap_temporaries",
        :path => "ldap_temporaries" do
          member do
            get :synchronize
            post :synchronize
            put :synchronize
            delete :synchronize
          end
        end
      resources :users do
        collection do
          get :csv, :csvget, :csvup, :csvset, :list
          post :csvup, :csvset
        end
        member do
          get :csvshow
        end
      end
      resources :groups,
        :path => ":parent/groups" do
          collection do
            get :list
          end
        end
      resources :users_groups,
        :path => ":parent/users_groups" do
          collection do
            get :list
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
          get :create_all_group, :synchro_all_group, :user_add_sort_no, :all_groups_disabled_delete
          put :sort_update
          post :get_users
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
    end
  end

  ##API
  match 'api/checker'         => 'system/admin/api#checker'
  match 'api/checker_login'   => 'system/admin/api#checker_login'
  match 'api/air_sso'         => 'system/admin/api#sso_login'

  match ':controller(/:action(/:id))(.:format)'
end
