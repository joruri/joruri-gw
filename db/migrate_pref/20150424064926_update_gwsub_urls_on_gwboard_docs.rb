class UpdateGwsubUrlsOnGwboardDocs < ActiveRecord::Migration
  def change
    production_url = Joruri.config.application['migrate.production_url']
    ind_url = Joruri.config.application['migrate.ind_url']
    ['gwbbs_docs', 'gwfaq_docs', 'gwqa_docs', 'doclibrary_docs', 'digitallibrary_docs'].each do |table|
      ['adminlibrary/', 'gw/maa_schedule_props/', 'gwsub/sb09/', 'gwsub/sb10/', 'gwsub/sb11/', 'pes/'].each do |path|
        execute "update #{table} set body = replace(body, '#{production_url}/#{path}', '#{ind_url}#{path}');"
      end
    end
    ['gw_memos'].each do |table|
      ['/gwsub/sb10/'].each do |path|
        execute "update #{table} set body = replace(body, '#{path}', '#{ind_url.chomp('/')}#{path}');"
      end
    end
  end
end
