JoruriGw::Application.routes.draw do
  mod = "questionnaire"
  scp = "admin"


  #scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        resources "menus",
         :controller => "menus",
         :path=> "/",
         :constraints => {:id  => /[0-9]+/}  do
           member do
             get :open_enq, :closed
           end
         end
        resources "itemdeletes",
          :controller => "itemdeletes",
          :path => "itemdeletes"
        resources "templates",
          :controller => "templates",
          :path => "templates" do
            member do
              get :open, :close
            end
          end
        resources "menu_templates",
          :controller => "menus/templates",
          :path => ":parent_id/templates" do
            member do
              get :apply_template, :copy_form_fields
            end
            collection do
              get :new_base
              post :create_base
            end
          end

        resources "answers",
          :controller => "menus/answers",
          :path => ":parent_id/answers"
        resources "csv_exports",
          :controller => "menus/csv_exports",
          :path => ":parent_id/csv_exports" do
            collection do
              put :export_csv
            end
          end
        resources "results",
          :controller => "menus/results",
          :path => ":parent_id/results" do
            collection do
              get :answer_to_details, :result_close, :result_open
            end
          end
        resources "menu_form_fields",
          :controller => "menus/form_fields",
          :path => ":parent_id/form_fields"
        resources "menu_previews",
          :controller => "menus/previews",
          :path => ":parent_id/previews"
        resources "template_form_fields",
          :controller => "templates/form_fields",
          :path => "templates/:parent_id/form_fields"
        resources "template_previews",
          :controller => "templates/previews",
          :path => "templates/:parent_id/previews"
        resources "help_configs",
          :controller => "help_configs",
          :path => "help_configs"
      end
    end
  #end

end
