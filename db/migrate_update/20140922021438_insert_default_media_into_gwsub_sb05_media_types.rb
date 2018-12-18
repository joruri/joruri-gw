class InsertDefaultMediaIntoGwsubSb05MediaTypes < ActiveRecord::Migration
  def change
    Gwsub::Sb05MediaType.where(:media_code => "1", :categories_code =>"1").first_or_create(:media_name => "新聞", :categories_name => "原稿", :state => "1")
    Gwsub::Sb05MediaType.where(:media_code => "2", :categories_code =>"1").first_or_create(:media_name => "ラジオ", :categories_name => "原稿", :state => "1")
    Gwsub::Sb05MediaType.where(:media_code => "3", :categories_code =>"1").first_or_create(:media_name => "LED", :categories_name => "屋内", :state => "2")
    Gwsub::Sb05MediaType.where(:media_code => "4", :categories_code =>"1").first_or_create(:media_name => "メルマガ", :categories_name => "情報ＢＯＸ", :state => "1")
    Gwsub::Sb05MediaType.where(:media_code => "3", :categories_code =>"2").first_or_create(:media_name => "LED", :categories_name => "屋外", :state => "2")
    Gwsub::Sb05MediaType.where(:media_code => "4", :categories_code =>"2").first_or_create(:media_name => "メルマガ", :categories_name => "イベント情報", :state => "1", :max_size => 3)
  end
end
