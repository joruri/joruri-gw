JoruriGw::Application.routes.draw do
  mod = "digitallibrary"
  scp = "admin"

  match "digitallibrary",                                    :to => "digitallibrary/admin/menus#index"
  match "digitallibrary/folders/:id/delete",                 :to => "digitallibrary/admin/folders#destroy"
  match "digitallibrary/docs/:parent_id/edit_file_memo/:id", :to => "digitallibrary/admin/docs#edit_file_memo"
  
  #scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        resources "menus",
          :controller => "menus",
          :path => "menus"
        resources "docs",
          :controller => "docs",
          :path => "docs" do
            member do
              get :recognize_update, :publish_update, :clone
            end
            collection do
              get :destroy_void_documents
            end
          end
        resources "cabinets",
          :controller => "cabinets",
          :path => "cabinets" do
              member do
                get :delete
              end
          end
        resources "folders",
          :controller => "folders",
          :path => "folders"
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
