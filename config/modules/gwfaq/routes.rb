Rails.application.routes.draw do
  mod = "gwfaq"
  scp = "admin"

  match 'gwfaq',            :to => 'gwboard/admin/knowledges#index', :via =>  [:post, :get]
  match 'gwfaq/controls',   :to => 'gwboard/admin/knowledge_makers#index', :via =>  [:post, :get]

  #scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        resources "menus",
        :controller => "menus",
        :path => "menus"
        resources "makers",
        :controller => "makers",
        :path => "makers" do
          member do
            get :design_publish, :delete
          end
        end
        resources "docs",
        :controller => "docs",
        :path => "docs" do
          collection do
            get :latest_answer
          end
          member do
            get :settlement, :delete, :recognize_update, :publish_update
          end
        end
        resources "categories",
        :controller => "categories",
        :path => "categories"
        resources "banners",
          :controller => "piece/banners",
          :path => "piece/banners"
        resources "menus",
          :controller => "piece/menus",
          :path => "piece/menus"
      end
    end
  #end


end
