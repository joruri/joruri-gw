JoruriGw::Application.routes.draw do
  mod = "gwboard"
  scp = "admin"
# GWBOARD 共通
  
  scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        resources "attachments",
          :controller => "attachments",
          :path => ":parent_id/attachments" do
            member do
              put :update_file_memo
            end
        end
        resources "maps",
          :controller => "maps",
          :path => ":parent_id/maps"
        resources "images",
          :controller => "images",
          :path => ":parent_id/images"
        resources "attaches",
          :controller => "attaches",
          :path => ":parent_id/attaches" do
            member do
              put :update_file_memo
            end
          end
        resources "receipts",
          :controller => "receipts",
          :path => "receipts" do
            member do
              get :show_object,:download_object
            end
          end
        resources "ajaxusers",
          :controller => "ajaxusers",
          :path => "ajaxusers" do
            collection do
              get :getajax,:getajax_recognizer
            end
          end
        resources "ajaxgroups",
          :controller => "ajaxgroups",
          :path => "ajaxgroups" do
            collection do
              get :getajax
            end
          end
      end
    end
  end



end
