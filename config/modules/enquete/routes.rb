JoruriGw::Application.routes.draw do
  mod = "enquete"
  scp = "admin"

  match 'enquete'             => 'enquete/admin/menus#index'

  #scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        resources "menus",
          :controller => "menus",
          :path => "menus"
        resources "answers",
          :controller => "menus/answers",
          :path => ":title_id/answers" do
            member do
              get :public_seal
            end
          end
      end
    end
  #end


end
