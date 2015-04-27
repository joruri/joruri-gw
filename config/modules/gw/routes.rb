Rails.application.routes.draw do

  match '/gw/pref_assembly_member_admins/csvup' => 'gw/admin/pref_assembly_member_admins#csvup', via: [:post, :get]
  match '/gw/pref_executive_admins/csvup' => 'gw/admin/pref_executive_admins#csvup', via: [:post, :get]
  match '/gw/pref_director_admins/csvup' => 'gw/admin/pref_director_admins#csvup', via: [:post, :get]
  match '/gw/reminders/requests' => 'gw/admin/reminders/requests#index', via: [:get]
  match '/gw/schedules/new' => 'gw/admin/schedules#new', via: [:post]

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
          get :getajax
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
      resources :pref_soumu_messages
      resources :admin_modes
      resources :admin_check_extensions
      resources :countings do
        collection do
          get :memos,:mobiles
        end
      end

      resources :edit_tabs do
        collection do
          get :list, :getajax
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
      resources :reminders do
        member do
          get :swap
        end
      end
      resources :portal_adds do
        member do
          get :updown
        end
      end
      resources :portal_add_configs do
        member do
          get :updown
        end
      end
      resources :portal_add_patterns do
        member do
          get :g_updown
          put :sort_update
        end
      end
      resources :portal_ad_accesses
      resources :portal_add_counts do
        member do
          get :count
        end
      end

      resources :section_admin_masters do
        collection do
          get :clear
          post :select_clear
        end
      end
      resources :section_admin_master_func_names
    end
  end

  namespace mod do
    scope :module => scp do
      resources :holidays
      resources :prop_types  do
        resources :users, :controller => 'prop_types/users'
        resources :messages, :controller => 'prop_types/messages'
      end

      resources :prop_others do
        member do
          get :upload
          post :image_create
          delete :image_destroy
        end
      end
      resources :prop_other_limits do
        collection do
          get :synchro
        end
      end

      resources :schedules do
        collection do
          get :show_month, :setting, :event_week, :event_month, :setting_ind,
            :setting_ind_schedules, :ical, :search
          put :edit_ind_schedules
        end
        member do
          get :show_one, :editlending, :edit_1, :edit_2, :quote, :destroy_repeat
          put :editlending, :edit_1, :edit_2
        end
      end
      resources :schedule_search_blanks do
        collection do
          get :show_day, :show_week
        end
      end
      resources :schedule_todos do
        collection do
          get :edit_user_property_schedule
        end
        member do
          get :finish, :quote
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
          get :getajax, :user_fields, :group_fields, :getajax_restricted
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
          get :admin_deletes, :export, :import, :portal_display
          put :edit_admin_deletes
          post :import_file
        end
      end
      resources :schedule_help_configs
      resources :schedule_events do
        collection do
          post :select_approval_open
        end
        member do
          get :approval, :open, :approval_cancel, :open_cancel
        end
      end
      resources :schedule_event_masters
      resources :meetings do
        collection do
          get :guide,:xmlput,:place_setting
          post :select
        end
        member do
          get :approval, :open, :approval_cancel, :open_cancel
        end
      end
      resources :meetings_previews
      resources :meeting_guide_backgrounds do
        member do
          get :updown
        end
      end
      resources :meeting_guide_notices do
        member do
          get :updown
        end
      end
      resources :meeting_guide_places do
        collection do
          get :get_prop_id, :prop_sync
        end
        member do
          get :updown
        end
      end
      resources :meeting_monitor_managers do
        collection do
          get :user_fields, :user_addr_fields
        end
      end
      resources :meeting_monitor_settings do
        collection do
          get :switch_monitor
        end
      end
      resources :prop_meetingrooms do
        member do
          get :upload
          post :image_create
          delete :image_destroy
        end
      end
      resources :prop_rentcars do
        member do
          get :upload
          post :image_create
          delete :image_destroy
        end
      end
      resources :prop_extras do
        collection do
          get :csvput, :confirm_all, :timeout_cancelled
          post :list, :results_delete_list
        end
        member do
          get :confirm, :rent, :return, :pm_create, :cancel
        end
      end
      resources :prop_extra_pm_meetingrooms do
        member do
          get :rent, :return, :show_group, :show_group_month, :delete_prop
        end
        collection do
          get :summarize, :csvput
        end
      end
      resources :prop_extra_pm_rentcars do
        member do
          get :rent, :return, :show_group, :show_group_month, :delete_prop
        end
        collection do
          get :summarize, :csvput, :show_month
        end
      end
      resources :prop_extra_pm_messages
      resources :prop_extra_pm_remarks
      resources :prop_extra_group_rentcar_masters
      resources :prop_extra_group_rentcars do
        member do
          get :show_group, :show_group_month
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
      resources :todos do
        member do
          get :mail_create
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
            get :redirect_to_joruri, :redirect_to_external
            post :redirect_to_joruri
          end
          member do
            get :redirect_tab, :redirect_link_piece, :redirect_portal_adds, :redirect_to_dcn
            get :redirect_pref_soumu, :redirect_pref_pieces # deprecated
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
          get :g_updown, :csvput, :get_users
          put :sort_update
          post :csvup
          get :temp_pickup, :temp_index, :temp_csv
          put :temp_pickup_run
        end
        member do
          get :updown
        end
      end
      resources :pref_executive_admins do
        collection do
          get :g_updown, :csvput, :get_users
          put :sort_update
          post :csvup, :get_users
        end
        member do
          get :updown
        end
      end
      resources :pref_assembly_member_admins do
        collection do
          get :csvput
          post :csvup
        end
        member do
          get :g_updown, :updown
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
