JoruriGw::Application.routes.draw do

  mod = "gwsub"
  scp = "admin"
  namespace mod do
    scope :module => scp do
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
    end
  end

  scope '_admin' do
    resources :gwsub do
      resources :attaches, :controller => 'gwsub/admin/attaches'
    end
  end

  match '/gwsub/sb01/sb01_trainings/:id/closed' => 'gwsub/admin/sb01/sb01_trainings#closed'
  match '/gwsub/sb01/sb01_training_plans/:id/closed' => 'gwsub/admin/sb01/sb01_training_plans#closed'
  match '/gwsub/sb01/sb01_training_plans/:id/prepared' => 'gwsub/admin/sb01/sb01_training_plans#prepared'
  match '/gwsub/sb01/sb01_training_plans/:id/expired' => 'gwsub/admin/sb01/sb01_training_plans#expired'
  match '/gwsub/sb01/sb01_training_schedule_conditions/make_skd' => 'gwsub/admin/sb01/sb01_training_schedule_conditions#make_skd'
  match '/gwsub/sb01/sb01_training_schedule_props/:id/closed' => 'gwsub/admin/sb01/sb01_training_schedule_props#closed'
  match '/gwsub/sb01/sb01_training_schedule_props/:id/prepared' => 'gwsub/admin/sb01/sb01_training_schedule_props#prepared'
  match '/gwsub/sb01/sb01_training_schedules/:id/closed' => 'gwsub/admin/sb01/sb01_training_schedules#closed'
  match '/gwsub/sb01/sb01_training_schedules/:id/prepared' => 'gwsub/admin/sb01/sb01_training_schedules#prepared'

  match '/gwsub/sb04/04/sb04assignedjobs/year_copy_run' => 'gwsub/admin/sb04/sb04assignedjobs#year_copy_run'
  match '/gwsub/sb04/04/sb04stafflists/year_copy_run' => 'gwsub/admin/sb04/sb04stafflists#year_copy_run'
  match '/gwsub/sb04/04/sb04stafflists/stafflists_create_run' => 'gwsub/admin/sb04/sb04stafflists#stafflists_create_run'
  match '/gwsub/sb04/02/sb04divideduties/:id/assigned_job_edit' => 'gwsub/admin/sb04/sb04divideduties#assigned_job_edit'
  match '/gwsub/sb04/02/sb04divideduties/:id/assigned_job_update' => 'gwsub/admin/sb04/sb04divideduties#assigned_job_update'

end
