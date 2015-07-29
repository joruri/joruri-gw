JoruriGw::Application.routes.draw do
  scp = "admin"
  mod = "sys"

  scope "_#{scp}" do
    resources "users",
      :controller => "users",
      :path => "" do
        collection do
          get :csvput, :csvup
          post :csvup
      end
    end
  end

  scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        ## admin
      end
    end
  end
  match ':controller(/:action(/:id))(.:format)'
end