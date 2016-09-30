Rails.application.routes.draw do

  mod = "gwsub"
  scp = "admin"
  namespace mod do
    scope :module => scp do

      resources :sb00_conference_references, :controller => 'sb00/sb00_conference_references', :path => 'sb00/sb00_conference_references'

      resources :sb00_conference_managers, :controller => 'sb00/sb00_conference_managers', :path => 'sb00/sb00_conference_managers' do
        collection do
          get :user_fields
        end
      end

      resources :sb00_conference_section_manager_names, :controller => 'sb00/sb00_conference_section_manager_names', :path => 'sb00/sb00_conference_section_manager_names' do
        collection do
          get :synchro, :csvput
          post :csvup
        end
      end

      resources :sb01_trainings, :controller => 'sb01/sb01_trainings', :path => 'sb01/sb01_trainings' do
        collection do
          get :index_over
        end
        member do
          put :closed
        end
      end
      resources :sb01_training_entries, :controller => 'sb01/sb01_training_entries', :path => 'sb01/sb01_training_entries' do
        collection do
          get :index_date
        end
      end
      resources :sb01_training_guides, :controller => 'sb01/sb01_training_guides', :path => 'sb01/sb01_training_guides' do
        collection do
          get :user, :manager
        end
      end
      resources :sb01_training_plans, :controller => 'sb01/sb01_training_plans', :path => 'sb01/sb01_training_plans' do
        collection do
          get :user_fields
        end
        member do
          put :closed, :prepared, :expired
        end
      end
      resources :sb01_training_schedule_conditions, :controller => 'sb01/sb01_training_schedule_conditions', :path => 'sb01/sb01_training_schedule_conditions' do
        collection do
          post :make_skd
        end
      end
      resources :sb01_training_schedule_props, :controller => 'sb01/sb01_training_schedule_props', :path => 'sb01/sb01_training_schedule_props' do
        member do
          put :closed, :prepared
        end
      end
      resources :sb01_training_schedule_members, :controller => 'sb01/sb01_training_schedule_members', :path => 'sb01/sb01_training_schedule_members' do
        collection do
          get :user_fields
        end
      end
      resources :sb01_training_schedules, :controller => 'sb01/sb01_training_schedules', :path => 'sb01/sb01_training_schedules' do
        collection do
          get :csvput
        end
        member do
          put :closed, :prepared
        end
      end
      resources :sb01_training_boards, :controller => 'sb01/sb01_training_boards', :path => 'sb01/sb01_training_boards'
      # 職員録　コード管理
      resources :sb0404menu, :controller => 'sb04/sb0404menu', :path => 'sb04/04/sb0404menu'
      # 期限設定
      resources :sb04_editable_dates  , :controller => 'sb04/sb04_editable_dates' , :path => 'sb04/04/sb04_editable_dates'
      # 職名一覧
      resources :sb04officialtitles   , :controller => 'sb04/sb04officialtitles'  , :path => 'sb04/04/sb04officialtitles' do
        collection do
          get  :csvput,:csvadd_check,:index_csv
          post :csvadd_check_run
        end
        member do
          get :show_csv
        end
      end
      # 所属一覧
      resources :sb04sections   , :controller => 'sb04/sb04sections'  , :path => 'sb04/04/sb04sections' do
        collection do
          get  :index2,:index3,:csvput,:csvadd_check,:index_csv
          post :csvadd_check_run
        end
        member do
          get :show_csv
        end
      end
      # 担当一覧
      resources :sb04assignedjobs   , :controller => 'sb04/sb04assignedjobs'  , :path => 'sb04/04/sb04assignedjobs' do
        collection do
          get  :csvput,:csvadd_check,:index_csv,:sb04_dev_section_fields,:section_fields,:year_copy
          post :csvadd_check_run
          put  :year_copy_run
        end
        member do
          get :show_csv
        end
      end
      # 職員一覧
      resources :sb04stafflists   , :controller => 'sb04/sb04stafflists'  , :path => 'sb04/04/sb04stafflists' do
        collection do
          get  :csvput,:csvadd_check,:index_csv,:master_sections_fields,:officialtitles_fields,:sb04_dev_section_fields,:section_fields,:assignedjobs_fields,:stafflists_create,:year_copy
          post :csvadd_check_run
          put  :stafflists_create_run,:year_copy_run
        end
        member do
          get :show_csv
        end
      end
      # 座席表管理者メニュー
      resources :sb04_seating_lists   , :controller => 'sb04/sb04_seating_lists'  , :path => 'sb04/04/sb04_seating_lists' do
        collection do
          get  :section_fields_year_copy
        end
      end
      # 座席表公開メニュー
      resources :sb04_seating_lists   , :controller => 'sb04/sb04_seating_lists'  , :path => 'sb04/06/sb04_seating_lists'
      # ヘルプ・利用ガイド
      resources :sb04helps  , :controller => 'sb04/sb04helps' , :path => 'sb04/05/sb04helps'
      # 表示行数設定
      resources :sb04_limit_settings  , :controller => 'sb04/sb04_limit_settings' , :path => 'sb04/09/sb04_limit_settings'
      # URL設定
      resources :sb04_settings  , :controller => 'sb04/sb04_settings' , :path => 'sb04/09/sb04_settings'
      # 主管課マスタ
      resources :sb04stafflistview_masters   , :controller => 'sb04/sb04stafflistview_masters'  , :path => 'sb04/01/sb04stafflistview_masters' do
        collection do
          get  :section_fields_year_copy
        end
      end
      # 電子職員録
      resources :sb04stafflistview   , :controller => 'sb04/sb04stafflistview'  , :path => 'sb04/01/sb04stafflistview' do
        collection do
          get  :section_fields,:csvview,:csvput
        end
      end
      # 事務分掌表
      resources :sb04divideduties   , :controller => 'sb04/sb04divideduties'  , :path => 'sb04/02/sb04divideduties' do
        collection do
          get :assigned_job_edit
        end
        member do
          put :assigned_job_update
        end
      end

    #広報依頼
      resources :sb05_desired_date_conditions , :controller => 'sb05/sb05_desired_date_conditions', :path => 'sb05/sb05_desired_date_conditions' do
        member do
          post :expand_date
        end
      end
      resources :sb05_desired_dates , :controller => 'sb05/sb05_desired_dates', :path => 'sb05/sb05_desired_dates' do
        collection do
          get :csvput
          post :csvup, :making
        end
      end
      resources :sb05_media_types, :controller => 'sb05/sb05_media_types', :path => 'sb05/sb05_media_types' do
       collection do
         get :csvput
         post :csvup
       end
      end
      resources :sb05_requests, :controller => 'sb05/sb05_requests', :path => 'sb05/sb05_requests' do
        collection do
          get :csvput, :index_created_dates, :index_before_publish, :index_before_confirm
          post :csvup, :list
        end
        member do
          get :recognized, :rejected, :draft_on, :check_on, :check_off
        end
      end
      resources :sb05_users, :controller => 'sb05/sb05_users', :path => 'sb05/sb05_users' do
       collection do
         get :csvput
         post :csvup
       end
      end
      resources :sb05_requests_put, :controller => 'sb05/sb05_requests_put', :path => 'sb05/sb05_requests_put' do
        collection do
          get :csvput, :start_fields, :finished
        end
      end

      resources :sb05_requests_finished, :controller => 'sb05/sb05_requests_finished', :path => 'sb05/sb05_requests_finished' do
        collection do
          post :list
        end
        member do
          get :finished, :finished_off
        end
      end
      resources :sb05_notices, :controller => 'sb05/sb05_notices', :path => 'sb05/sb05_notices' do
       collection do
         get :csvput
         post :csvup
       end
      end
      #予算担当管理　担当者名等管理

      resources :sb06_budget_setup, :controller => 'sb06/sb06_budget_setup', :path => 'sb06/sb06_budget_setup'
      resources :sb06_assigned_setup, :controller => 'sb06/sb06_budget_setup', :path => 'sb06/sb06_budget_setup'

      resources :sb0605menu, :controller => 'sb06/sb0605menu', :path => 'sb06/sb0605menu'
      resources :sb0606menu, :controller => 'sb06/sb0606menu', :path => 'sb06/sb0606menu'
      resources :sb06_budget_assigns, :controller => 'sb06/sb06_budget_assigns', :path => 'sb06/sb06_budget_assigns' do
        member do
          get :user_fields
        end
      end

      resources :sb06_budget_assign_csvput, :controller => 'sb06/sb06_budget_assign_csvput', :path => 'sb06/sb06_budget_assign_csvput'
      resources :sb06_budget_assign_mains, :controller => 'sb06/sb06_budget_assign_mains', :path => 'sb06/sb06_budget_assign_mains' do
        collection do
          get :user_fields
        end
      end
      resources :sb06_budget_assign_admins , :controller => 'sb06/sb06_budget_assign_admins', :path => 'sb06/sb06_budget_assign_admins' do
        collection do
          get :user_fields
        end
      end
      resources :sb06_budget_notices, :controller => 'sb06/sb06_budget_notices', :path => 'sb06/sb06_budget_notices'
      resources :sb06_budget_roles, :controller => 'sb06/sb06_budget_roles', :path => 'sb06/sb06_budget_roles' do
        collection do
          get :csvput, :csvup
          post  :csvup
        end
      end

      resources :sb06_budget_editable_dates, :controller => 'sb06/sb06_budget_editable_dates', :path => 'sb06/sb06_budget_editable_dates'
      resources :sb06_assigned_conf_categories, :controller => 'sb06/sb06_assigned_conf_categories', :path => 'sb06/sb06_assigned_conf_categories' do
        collection do
          get :csvput, :csvup
          post  :csvup
        end
      end
      resources :sb06_assigned_conf_groups, :controller => 'sb06/sb06_assigned_conf_groups', :path => 'sb06/sb06_assigned_conf_groups' do
        collection do
          get :csvput, :csvup
          post  :csvup
        end
      end
      resources :sb06_assigned_conf_items, :controller => 'sb06/sb06_assigned_conf_items', :path => 'sb06/sb06_assigned_conf_items' do
        collection do
          get :csvput, :csvup, :conf_kinds_select
          post  :csvup
        end
      end


      resources :sb06_assigned_conf_item_subs, :controller => 'sb06/sb06_assigned_conf_item_subs', :path => 'sb06/sb06_assigned_conf_item_subs' do
        collection do
          get :csvput, :csvup
          post  :csvup
        end
      end
      resources :sb06_assigned_conf_kinds, :controller => 'sb06/sb06_assigned_conf_kinds', :path => 'sb06/sb06_assigned_conf_kinds' do
        collection do
          get :csvput, :csvup
          post  :csvup
        end
      end
      resources :sb06_assigned_official_titles, :controller => 'sb06/sb06_assigned_official_titles', :path => 'sb06/sb06_assigned_official_titles' do
        collection do
          get :csvput, :csvup
          post  :csvup
        end
      end
      resources :sb06_assigned_conferences, :controller => 'sb06/sb06_assigned_conferences', :path => 'sb06/sb06_assigned_conferences' do
        collection do
          get :user_fields,:manager_name_field,:csvput
        end
        member do
          get :show_print,:draft_on,:check_on,:check_off,:recognized,:rejected,:edit_docno
          put :udpate_docno
        end
      end

      resources :sb06_assigned_helps, :controller => 'sb06/sb06_assigned_helps', :path => 'sb06/sb06_assigned_helps' do
        collection do
          get :kind_fields
        end
      end


      # USBメモリ/外部記録媒体管理台帳
      resources :externalusbs, :controller => 'sb12/externalusbs', :path => 'sb12/externalusbs' do
        collection do
          get :user_fields, :admin_index, :csvput, :csvup
          post :csvup
        end
      end
      resources :capacityunitsets, :controller => 'sb12/capacityunitsets', :path => 'sb12/capacityunitsets' do
        collection do
          get :csvput, :csvup
          post :csvup
        end
      end
      resources :externalmedias, :controller => 'sb13/externalmedias', :path => 'sb13/externalmedias' do
        collection do
          get :user_fields, :admin_index, :csvput, :csvup
          post :csvup
        end
      end
      resources :externalmediakinds, :controller => 'sb13/externalmediakinds', :path => 'sb13/externalmediakinds' do
        collection do
          get :csvput, :csvup
          post :csvup
        end
      end

    end
  end

  scope '_admin' do
    resources :gwsub do
      resources :attaches, :controller => 'gwsub/admin/attaches' do
        collection do
          post :upload
        end
      end
      resources :receipts, :controller => 'gwsub/admin/receipts' do
        member do
          get :download_object, :show_object
        end
      end
    end
  end

  match '/gwsub/sb00/sb00_conference_section_manager_names/csvup'  => 'gwsub/admin/sb00/sb00_conference_section_manager_names#csvup', :via =>  [:post, :get]

  match '/gwsub/sb01/sb01_trainings/:id/closed' => 'gwsub/admin/sb01/sb01_trainings#closed', :via =>  [:post, :get]
  match '/gwsub/sb01/sb01_training_plans/:id/closed' => 'gwsub/admin/sb01/sb01_training_plans#closed', :via =>  [:post, :get]
  match '/gwsub/sb01/sb01_training_plans/:id/prepared' => 'gwsub/admin/sb01/sb01_training_plans#prepared', :via =>  [:post, :get]
  match '/gwsub/sb01/sb01_training_plans/:id/expired' => 'gwsub/admin/sb01/sb01_training_plans#expired', :via =>  [:post, :get]
  match '/gwsub/sb01/sb01_training_schedule_conditions/make_skd' => 'gwsub/admin/sb01/sb01_training_schedule_conditions#make_skd', :via =>  [:post, :get]
  match '/gwsub/sb01/sb01_training_schedule_props/:id/closed' => 'gwsub/admin/sb01/sb01_training_schedule_props#closed', :via =>  [:post, :get]
  match '/gwsub/sb01/sb01_training_schedule_props/:id/prepared' => 'gwsub/admin/sb01/sb01_training_schedule_props#prepared', :via =>  [:post, :get]
  match '/gwsub/sb01/sb01_training_schedules/:id/closed' => 'gwsub/admin/sb01/sb01_training_schedules#closed', :via =>  [:post, :get]
  match '/gwsub/sb01/sb01_training_schedules/:id/prepared' => 'gwsub/admin/sb01/sb01_training_schedules#prepared', :via =>  [:post, :get]

  match '/gwsub/sb04/04/sb04assignedjobs/year_copy_run' => 'gwsub/admin/sb04/sb04assignedjobs#year_copy_run', :via =>  [:post, :get]
  match '/gwsub/sb04/04/sb04stafflists/year_copy_run' => 'gwsub/admin/sb04/sb04stafflists#year_copy_run', :via =>  [:post, :get]
  match '/gwsub/sb04/04/sb04stafflists/stafflists_create_run' => 'gwsub/admin/sb04/sb04stafflists#stafflists_create_run', :via =>  [:post, :get]
  match '/gwsub/sb04/02/sb04divideduties/:id/assigned_job_edit' => 'gwsub/admin/sb04/sb04divideduties#assigned_job_edit', :via =>  [:post, :get]
  match '/gwsub/sb04/02/sb04divideduties/:id/assigned_job_update' => 'gwsub/admin/sb04/sb04divideduties#assigned_job_update', :via =>  [:post, :get]

  match '/gwsub/sb05/sb05_desired_date_conditions/:id/expand_date' => 'gwsub/admin/sb05/sb05_desired_date_conditions#expand_date', :via =>  [:post, :get]
  match '/gwsub/sb05/sb05_desired_dates/making'  => 'gwsub/admin/sb05/sb05_desired_dates#making', :via =>  [:post, :get]
  match '/gwsub/sb05/sb05_desired_dates/csvup'   => 'gwsub/admin/sb05/sb05_desired_dates#csvup', :via =>  [:post, :get]
  match '/gwsub/sb05/sb05_media_types/csvup'     => 'gwsub/admin/sb05/sb05_media_types#csvup', :via =>  [:post, :get]
  match '/gwsub/sb05/sb05_requests/csvup'        => 'gwsub/admin/sb05/sb05_requests#csvup', :via =>  [:post, :get]
  match '/gwsub/sb05/sb05_users/csvup'           => 'gwsub/admin/sb05/sb05_users#csvup', :via =>  [:post, :get]
  match '/gwsub/sb05/sb05_notices/csvup'         => 'gwsub/admin/sb05/sb05_notices#csvup', :via =>  [:post, :get]

  match 'gwsub/sb06/sb06_budget_roles/csvup' => 'gwsub/public/sb06/sb06_budget_roles#csvup', :via =>  [:post, :get]
  match 'gwsub/sb06/sb06_assigned_conf_categories/csvup' => 'gwsub/public/sb06/sb06_assigned_conf_categories#csvup', :via =>  [:post, :get]
  match 'gwsub/sb06/sb06_assigned_conf_groups/csvup' => 'gwsub/public/sb06/sb06_assigned_conf_groups#csvup', :via =>  [:post, :get]
  match 'gwsub/sb06/sb06_assigned_conf_items/csvup' => 'gwsub/public/sb06/sb06_assigned_conf_items#csvup', :via =>  [:post, :get]
  match 'gwsub/sb06/sb06_assigned_conf_item_subs/csvup' => 'gwsub/public/sb06/sb06_assigned_conf_item_subs#csvup', :via =>  [:post, :get]
  match 'gwsub/sb06/sb06_assigned_conf_kinds/csvup' => 'gwsub/public/sb06/sb06_assigned_conf_kinds#csvup', :via =>  [:post, :get]
  match 'gwsub/sb06/sb06_assigned_official_titles/csvup' => 'gwsub/public/sb06/sb06_assigned_official_titles#csvup', :via =>  [:post, :get]
  match 'gwsub/sb06/sb06_assigned_conferences/udpate_docno' => 'gwsub/public/sb06/sb06_assigned_conferences#udpate_docno', :via =>  [:post, :get]

end
