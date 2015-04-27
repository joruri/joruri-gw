Rails.application.routes.draw do
  mod = "gwbbs"
  scp = "admin"

  match "gwbbs",                                      :to => "gwbbs/admin/menus#index", :via =>  [:post, :get]
  match "gwbbs/docs/:parent_id/edit_file_memo/:id",   :to => "gwbbs/admin/docs#edit_file_memo", :via =>  [:post, :get]
  match "gwbbs/csv_exports/:id",                      :to => "gwbbs/admin/csv_exports#index", :via =>  [:post, :get]
  match "gwbbs/csv_exports/:id/export_csv",           :to => "gwbbs/admin/csv_exports#export_csv", via: [:get, :post]

  #scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        resources "theme_settings",
          :controller => "theme_settings",
          :path => "theme_settings"
        resources "menus",
          :controller => "menus",
          :path => "menus"
        resources "itemdeletes",
          :controller => "itemdeletes",
          :path => "itemdeletes"
        resources "builders",
          :controller => "builders",
          :path => "builders"
        resources "synthesetup",
          :controller => "synthesetup",
          :path => "synthesetup"
        resources "makers",
          :controller => "makers",
          :path => "makers"
        resources "categories",
          :controller => "categories",
          :path => "categories"
        resources "docs",
          :controller => "docs",
          :path => "docs" do
            member do
              get :recognize_update, :publish_update, :clone
              get :export_file, :file_exports
            end
            collection do
              get :destroy_void_documents
            end
          end
        resources "comments",
          :controller => "comments",
          :path => "comments"
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
