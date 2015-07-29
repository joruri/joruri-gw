JoruriGw::Application.routes.draw do

  match '/gw/pref_assembly_member_admins/csvup' => 'gw/admin/pref_assembly_member_admins#csvup'
  match '/gw/pref_executive_admins/csvup' => 'gw/admin/pref_executive_admins#csvup'
  match '/gw/pref_director_admins/csvup' => 'gw/admin/pref_director_admins#csvup'

  mod = "gw"
  scp = "admin"

#  match '/gw/admin/test/download'  => 'gw/admin/test#download'

  namespace mod do
    scope :module => scp do
      ## gw
      resources :portal
      resources :test, :except =>['show','index','destroy','update'] do
        collection do
          post :convert_hash, :import_csv, :download, :params_viewer, :dcn_feeds
        end
        member do
          get :redirect_pref_soumu, :redirect_pref_cms, :redirect_pref_pieces
        end
      end

      resources :memos do
        collection do
          post :list
        end
        member do
          get :finish, :quote, :confirm, :delete
        end
      end

      resources :mobile_participants do
        collection do
          get :mobile_manage
        end
      end
      resources :mobile_schedules do
        collection do
          get :list, :ind_list
          post :mobile_manage
        end
        member do
          get :confirm, :delete, :delete_repeat
        end
      end

      resources :memo_settings do
        collection do
          get :reminder, :admin_deletes, :forwarding
          put :edit_reminder, :edit_admin_deletes
          post :update_forwarding
        end
      end

      resources :config_settings do
        collection do
          get :ind_settings
        end
      end
      resources :year_fiscal_jps
      resources :year_mark_jps
      resources :admin_messages
      resources :admin_modes
      resources :countings do
        collection do
          get :memos,:mobiles
        end
      end

      resources :edit_tabs do
        collection do
          get :list
        end
        member do
          get :updown
        end
      end
      resources :edit_link_pieces do
        collection do
          get :list, :getajax_priv
        end
        member do
          get :updown, :swap
        end
      end
      resources :edit_link_piece_csses do
        collection do
          get :list
        end
        member do
          get :updown, :renew
        end
      end
      resources :mobile_settings do
        collection do
          get :access_edit, :password_edit
          put :access_updates, :password_updates
        end
      end
      resources :plus_update_settings do
        member do
          get :to_project
        end
      end
    end
  end

  namespace mod do
    scope :module => scp do
      resources :holidays
      resources :prop_types

      resources :prop_others do
        member do
          get :upload, :image_create, :image_destroy
          post :image_create
        end
      end
      resources :prop_other_limits do
        collection do
          get :synchro
        end
      end

      resources :schedules do
        collection do
          get :show_month, :setting, :setting_system, :setting_holidays, :event_week, :event_month, :setting_ind, :setting_ind_schedules, :setting_ind_ssos, :setting_ind_mobiles, :setting_gw_link, :ical, :search
          put :edit_ind_schedules, :edit_ind_ssos, :edit_ind_mobiles, :edit_gw_link, :editlending, :edit_1, :edit_2
        end
        member do
          get :show_one, :editlending, :edit_1, :edit_2, :quote, :destroy_repeat
        end
      end
      resources :schedule_props do
        collection do
          get :show_week, :show_month, :setting, :setting_system, :setting_ind, :getajax, :show_guard
        end
        member do
          get :show_one
        end
      end
      resources :schedule_users do
        collection do
          get :getajax, :user_fields, :group_fields
        end
      end
      resources :schedule_lists do
        collection do
          get :user_fields, :csvput, :icalput
          post :user_select, :user_add, :user_delete
        end
        member do
          put :import
        end
      end
      resources :schedule_settings do
        collection do
          get :admin_deletes, :export, :import, :potal_display
          put :edit_admin_deletes
          post :import_file
        end
      end

      resources :todos do
        member do
          get :finish, :delete, :quote, :delete, :finish, :confirm
        end
      end
      resources :todo_settings do
        collection do
          get :reminder, :schedule, :admin_deletes
          put :edit_reminder, :edit_schedule, :edit_admin_deletes
        end
      end

    end
  end

  # _admin
  scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        resources :link_sso, :constraints => {:id  => /[0-9]+/}  do
          collection do
            post :convert_hash, :import_csv, :download, :params_viewer
            get :redirect_to_plus
          end
          member do
            get :redirect_pref_soumu, :redirect_pref_cms, :redirect_pref_pieces, :redirect_to_dcn
          end
        end
      end
    end
  end
  #在庁管理
  namespace :gw do
    scope :module => :admin do
      resources :pref_assembly do
        member do
          get :state_change
        end
      end
      resources :pref_executives do
        member do
          get :state_change
        end
      end
      resources :pref_directors do
        member do
          get :state_change
        end
      end

      resources :pref_director_admins do
        collection do
          get :g_updown, :csvput
          put :sort_update
          post :csvup, :get_users
        end
        member do
          get :updown
        end
      end
      resources :pref_executive_admins do
        collection do
          get :g_updown, :csvput
          put :sort_update
          post :csvup, :get_users
        end
        member do
          get :updown
        end
      end
      resources :pref_assembly_member_admins do
        collection do
          get :g_updown, :csvput
          post :csvup
        end
        member do
          get :updown
        end
      end
      resources :pref_configs do
        member do
          get :display_change
        end
      end

      resources :pref_only_directors do
        member do
          get :state_change
        end
      end
      resources :pref_only_executives do
        member do
          get :state_change
        end
      end
      resources :pref_only_assembly do
        member do
          get :state_change
        end
      end
    end
  end
end
