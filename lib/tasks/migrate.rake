# Ver3移行タスク
namespace :joruri do
  namespace :migrate do
    def _target_control_models
      [Gwbbs::Control, Gwfaq::Control, Gwqa::Control, Doclibrary::Control, Digitallibrary::Control]
    end

    def _target_models_and_columns
      {
        #gwbbs
        Gwbbs::Category => ["id"],
        Gwbbs::Comment  => ["id", "parent_id"],
        Gwbbs::DbFile => ["id", "parent_id"],
        Gwbbs::Doc => ["id", "category1_id"],
        Gwbbs::File => ["id", "parent_id", "db_file_id"],
        Gwbbs::Image => ["id", "parent_id", "db_file_id"],
        Gwbbs::Recognizer => ["id", "parent_id"],
        #gwfaq
        Gwfaq::Category => ["id"],
        Gwfaq::DbFile => ["id", "parent_id"],
        Gwfaq::Doc => ["id", "category1_id"],
        Gwfaq::File => ["id", "parent_id", "db_file_id"],
        Gwfaq::Image => ["id", "parent_id", "db_file_id"],
        Gwfaq::Recognizer => ["id", "parent_id"],
        #gwqa
        Gwqa::Category => ["id"],
        Gwqa::DbFile => ["id", "parent_id"],
        Gwqa::Doc => ["id", "parent_id", "category1_id"],
        Gwqa::File => ["id", "parent_id", "db_file_id"],
        Gwqa::Image => ["id", "parent_id", "db_file_id"],
        Gwqa::Recognizer => ["id", "parent_id"],
        #doclibrary
        Doclibrary::Category => ["id"],
        Doclibrary::DbFile => ["id", "parent_id"],
        Doclibrary::Doc => ["id", "category1_id", "category2_id"],
        Doclibrary::File => ["id", "parent_id", "db_file_id"],
        Doclibrary::FolderAcl => ["id", "folder_id"],
        Doclibrary::Folder => ["id", "parent_id"],
        Doclibrary::GroupFolder => ["id", "parent_id"],
        Doclibrary::Image => ["id", "parent_id"],
        Doclibrary::Recognizer => ["id", "parent_id"],
        #digitallibrary
        Digitallibrary::DbFile => ["id", "parent_id"],
        Digitallibrary::Doc => ["id", "parent_id", "doc_alias", "chg_parent_id", "category1_id"],
        Digitallibrary::File => ["id", "parent_id", "db_file_id"],
        Digitallibrary::Image => ["id", "parent_id", "db_file_id"],
        Digitallibrary::Recognizer => ["id", "parent_id"]
      }
    end

    def get_system_name(model)
      model.to_s.split('::').first.downcase
    end

    def get_old_filename(file)
      if file.content_id == 2
        "#{sprintf("%08d", file.serial_no)}.dat"
      else
        file.filename
      end
    end

    def get_old_file_path(file)
      old_file_name = file.content_id == 2 ? "#{sprintf("%08d", file.serial_no)}.dat" : file.filename
      parent_id_dir = Util::CheckDigit.check(format('%07d', file.doc.serial_no))
      self_id = sprintf("%08d", file.serial_no)
      self_id_dir = "#{self_id[0..3]}/#{self_id[4..7]}"
      "#{file.base_dir}/#{sprintf('%06d', file.title_id)}/#{parent_id_dir}/#{self_id_dir}/#{get_old_filename(file)}"
    end

    def get_old_file_uri(file, system_name)
      if file.content_id == 2
        "/_admin/gwboard/receipts/#{file.serial_no}/download_object?system=#{system_name}&title_id=#{file.title_id}"
      else
        parent_id_dir = Util::CheckDigit.check(format('%07d', file.doc.serial_no))
        self_id = sprintf("%08d", file.serial_no)
        self_id_dir = "#{self_id[0..3]}/#{self_id[4..7]}"
        uri = "#{file.file_base_path}/#{sprintf('%06d', file.title_id)}/#{parent_id_dir}/#{self_id_dir}/#{URI.encode(file.filename)}"
        file.content_id == 3 && !file.is_image ? "/_admin#{uri}".gsub('/_attaches/', '/attaches/') : uri
      end
    end

    def get_old_image_path(image)
      parent_id_dir = Util::CheckDigit.check(format('%07d', image.doc.serial_no))
      self_id = sprintf("%08d", image.serial_no)
      self_id_dir = "#{self_id[0..3]}/#{self_id[4..7]}"
      "#{Rails.root}/public/_common/modules/#{image.system_name}/#{sprintf('%06d', image.title_id)}/#{parent_id_dir}/#{self_id_dir}/#{image.filename}"
    end

    def get_old_image_uri(image)
      parent_id_dir = Util::CheckDigit.check(format('%07d', image.doc.serial_no))
      self_id = sprintf("%08d", image.serial_no)
      self_id_dir = "#{self_id[0..3]}/#{self_id[4..7]}"
      "/_common/modules/#{image.system_name}/#{sprintf('%06d', image.title_id)}/#{parent_id_dir}/#{self_id_dir}/#{URI.encode(image.filename)}"
    end

    desc 'サブデータベースをメインデータベースに統合します'
    task :integrate_db => :environment do
      db_conf = JoruriGw::Application.config.database_configuration
      db_keys = ["dev_jgw_gw", "gw", "gwsub"]

      main_conf = db_conf[Rails.env]
      sub_confs = db_keys.map{|key| db_conf[key] if db_conf[key] }.compact

      puts "Are you sure to copy tables from '#{sub_confs.map{|conf| conf["database"]}.join(', ')}' to '#{main_conf["database"]}'?"
      print "[yes/no] "

      if STDIN.gets.chomp != "yes"
        puts "cancelled"
        next
      end

      sub_confs.each do |conf|
        dump_file = "tmp/#{conf["database"]}.dump"

        puts "dumping database '#{conf["database"]}' to '#{dump_file}'..."
        `mysqldump --host=#{conf["host"]} -u#{conf["username"]} -p#{conf["password"]} #{conf["database"]} --skip-lock-tables > #{dump_file}`
      end

      sub_confs.each do |conf|
        dump_file = "tmp/#{conf["database"]}.dump"
        next unless FileTest.exist?(dump_file)

        puts "importing dump file '#{dump_file}' to '#{main_conf["database"]}'..."
        `mysql --host=#{main_conf["host"]} -u#{main_conf["username"]} -p#{main_conf["password"]} #{main_conf["database"]} < #{dump_file}`
      end

      sub_confs.each do |conf|
        dump_file = "tmp/#{conf["database"]}.dump"
        next unless FileTest.exist?(dump_file)

        puts "removing dump file '#{dump_file}'..."
        `rm #{dump_file}`
      end

      puts "done"
    end

    desc 'メインデータベースにボード系テーブルを作成します'
    task :create_board_table, [:mode] => :environment do |task, args|
      # テーブル作成
      versions = [20140701000000, 20140701000005]
      # wikiカラム追加
      versions += [20140901023729, 20140903055257, 20140904055618, 20140904093300, 20140905024106] if args[:mode].to_s == 'pref'
      # serial_no, migratedカラム追加
      versions += [20140701000010]

      versions.each do |version|
        ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_path, version)
      end

      puts "done"
    end

    desc '不正なボード系テーブルを修正します'
    task :modify_board_table, [:mode] => :environment do |task, args|
      conn = ActiveRecord::Base.connection

      if args[:mode].to_s == 'pref'
        # 不足カラム追加
        Gwbbs::Control.select(:id, :dbname).order(:id).each do |control|
          next if control.dbname.blank?
          conn.execute "alter table #{control.dbname}.gwbbs_comments add column keyword1 text after category4_id" rescue nil
          conn.execute "alter table #{control.dbname}.gwbbs_comments add column keyword2 text after keyword1" rescue nil
          conn.execute "alter table #{control.dbname}.gwbbs_comments add column keyword3 text after keyword2" rescue nil
          conn.execute "alter table #{control.dbname}.gwbbs_docs add column inpfld_006w varchar(255) after inpfld_006" rescue nil
          conn.execute "alter table #{control.dbname}.gwbbs_docs add column inpfld_006d datetime after inpfld_006w" rescue nil
          conn.execute "alter table #{control.dbname}.gwbbs_docs add column wiki int(11)" rescue nil
        end
        Doclibrary::Control.select(:id, :dbname).order(:id).each do |control|
          next if control.dbname.blank?
          conn.execute "alter table #{control.dbname}.doclibrary_categories add column content_id int(11) after unid" rescue nil
          conn.execute "alter table #{control.dbname}.doclibrary_docs add column wiki int(11)" rescue nil
          conn.execute "alter table #{control.dbname}.doclibrary_folders add column children_size int(11) after level_no" rescue nil
          conn.execute "alter table #{control.dbname}.doclibrary_folders add column total_children_size int(11) after children_size" rescue nil
          conn.execute "alter table #{control.dbname}.doclibrary_folders add column docs_last_updated_at datetime" rescue nil
          conn.execute "alter table #{control.dbname}.doclibrary_group_folders add column children_size int(11) after level_no" rescue nil
          conn.execute "alter table #{control.dbname}.doclibrary_group_folders add column total_children_size int(11) after children_size" rescue nil
          conn.execute "alter table #{control.dbname}.doclibrary_group_folders add column docs_last_updated_at datetime" rescue nil
        end
        Digitallibrary::Control.select(:id, :dbname).order(:id).each do |control|
          next if control.dbname.blank?
          conn.execute "alter table #{control.dbname}.digitallibrary_docs add column wiki int(11)" rescue nil
        end
        # 不正カラム名修正
        ActiveRecord::Migrator.run(:up, 'db/migrate_pref', 20140702000000)
      end

      puts "done"
    end

    desc 'ボード系以外のテーブルをVer3にアップデートします'
    task :update_table, [:mode] => :environment do |task, args|
      if args[:mode] == 'pref'
        Rails.application.config.paths['db/migrate'] = 'db/migrate_pref'
      end
      Rake::Task["db:migrate"].invoke
      puts "done"
    end

    desc 'ボード系データベースのデータをメインデータベースにコピーします'
    task :copy_board_data, [:system] => :environment do |task, args|
      conn = ActiveRecord::Base.connection
      main_dbname = JoruriGw::Application.config.database_configuration[Rails.env]["database"]

      control_models = _target_control_models
      update_models = _target_models_and_columns
      if args[:system].present?
        control_models = control_models.select {|model| get_system_name(model) == args[:system].to_s}
        update_models = update_models.select {|model, _| get_system_name(model) == args[:system].to_s}
      end

      show_databases = conn.execute("show databases").to_a.flatten

      control_models.each do |control_model|
        select_models = update_models.select{|model, _| get_system_name(model) == get_system_name(control_model) }

        controls = control_model.select(:id, :dbname).order(:id).to_a
        # データベースが存在するコントロールのみ選択
        controls = controls.select {|control| control.dbname.present? && show_databases.include?(control.dbname) }

        # 開始ID取得(開始ID = 最大ID+1)
        start_id = 0
        controls.each do |control|
          select_models.each do |model, _|
            id = conn.execute("select max(id) from #{control.dbname}.#{model.table_name}").to_a.flatten.first.to_i rescue nil
            start_id = id+1 if id && id+1 > start_id 
          end
        end

        controls.each do |control|
          # テーブルが存在するモデルのみ選択
          models = select_models.select {|model, _| conn.execute("select count(id) from #{control.dbname}.#{model.table_name}") rescue nil }

          # 最大ID取得
          max_id = models.inject(0) do |max, (model, _)|
            id = conn.execute("select max(id) from #{control.dbname}.#{model.table_name}").to_a.flatten.first.to_i
            id > max ? id : max
          end

          puts "copying '#{control.dbname}' to '#{main_dbname}' (ID range: #{start_id} - #{start_id + max_id})..."
          models.each do |model, renew_columns|
            copy_columns = model.column_names.reject{|c| c.in?(renew_columns + ["serial_no", "migrated"])}
            copy_column_sql = copy_columns.join(',')
            renew_column_insert_sql = renew_columns.join(', ')
            renew_column_select_sql = renew_columns.map{|c| "case when #{c} = null then null when #{c} <= 0 then #{c} else #{c} + #{start_id} end" }.join(', ')
            conn.execute <<-SQL
              insert into #{main_dbname}.#{model.table_name} (#{renew_column_insert_sql}, #{copy_column_sql}, serial_no, migrated) 
                select #{renew_column_select_sql}, #{copy_column_sql}, id, 1 from #{control.dbname}.#{model.table_name};
            SQL
          end

          start_id = start_id + max_id + 10
        end
      end

      # parent_id修正
      conn.execute "update doclibrary_folders set parent_id = null where level_no = 1"
      conn.execute "update doclibrary_group_folders set parent_id = null where level_no = 1"
      conn.execute "update digitallibrary_docs set parent_id = null, chg_parent_id = null, category1_id = null where doc_type = 0 and level_no = 1"

      puts "done"
    end

    desc 'ボード系テーブルのデータを修正します'
    task :modify_board_data, [:system] => :environment do |task, args|
      doc_models = [Gwbbs::Doc, Gwfaq::Doc, Gwqa::Doc, Doclibrary::Doc, Digitallibrary::Doc]
      doc_models = doc_models.select {|model| get_system_name(model) == args[:system].to_s } if args[:system].present?

      # name, pname修正
      doc_models.each do |doc_model|
        num = 0
        doc_model.find_each do |doc|
          doc.update_columns(name: Util::CheckDigit.check(format('%07d', doc.id)))
          doc.update_columns(pname: Util::CheckDigit.check(format('%07d', doc.parent_id))) if doc_model == Gwqa::Doc && doc.parent_id.present?
          num += 1
        end
        puts "#{doc_model.table_name}: #{num} modified"
      end

      image_models = [Gwbbs::Image, Gwfaq::Image, Gwqa::Image, Doclibrary::Image, Digitallibrary::Image]
      image_models = image_models.select {|model| get_system_name(model) == args[:system].to_s } if args[:system].present?

      # parent_name修正
      image_models.each do |image_model|
        num = 0
        image_model.find_each do |image|
          next if image.parent_id.blank?
          next if image.parent_name.to_s.size != 8

          image.update_columns(parent_name: Util::CheckDigit.check(format('%07d', image.parent_id)))
          num += 1
        end
        puts "#{image_model.table_name}: #{num} modified"
      end

      puts "done"
    end

    desc '添付ファイルのディレクトリを移動します'
    task :modify_attach_dir, [:system] => :environment do |task, args|
      file_models = [Gwbbs::File, Gwfaq::File, Gwqa::File, Doclibrary::File, Digitallibrary::File]
      file_models = file_models.select {|model| get_system_name(model) == args[:system].to_s } if args[:system].present?

      file_models.each do |file_model|
        file_model.preload(:doc).find_each do |file|
          next unless file.doc

          old_path = get_old_file_path(file)
          next unless FileTest.exist?(old_path)

          FileUtils.mkdir_p(file.f_path) unless FileTest.exist?(file.f_path)
          FileUtils.mv(old_path, file.f_name)
          puts "#{old_path} -> #{file.f_name}"
        end
      end

      puts "done"
    end

    desc '添付ファイルのリンクを修正します'
    task :modify_attach_link, [:system, :target] => :environment do |task, args|
      file_models = [Gwbbs::File, Gwfaq::File, Gwqa::File, Doclibrary::File, Digitallibrary::File]
      file_models = file_models.select {|model| get_system_name(model) == args[:system].to_s } if args[:system].present?

      file_models.each do |file_model|
        system_name = get_system_name(file_model)
        file_model.preload(:doc).find_each do |file|
          next unless file.doc

          # 添付ファイルリンクの新旧対応
          old_link = get_old_file_uri(file, system_name)
          new_link = file.file_uri(system_name)

          # 置換
          old_link_quoted = ActiveRecord::Base.connection.quote(old_link)
          new_link_quoted = ActiveRecord::Base.connection.quote(new_link)
          if args[:target] == 'all'
            [Gwbbs::Doc, Gwfaq::Doc, Gwqa::Doc, Doclibrary::Doc, Digitallibrary::Doc].each do |doc_model|
              doc_model.update_all("body = replace(body, #{old_link_quoted}, #{new_link_quoted})")
              doc_model.update_all("body = replace(body, #{old_link.gsub('&', '&amp;')}, #{new_link_quoted})") if old_link_quoted.include?('&')
            end
          else
            file.doc.class.where(id: file.doc.id).update_all("body = replace(body, #{old_link_quoted}, #{new_link_quoted})")
            file.doc.class.where(id: file.doc.id).update_all("body = replace(body, #{old_link_quoted.gsub('&', '&amp;')}, #{new_link_quoted})") if old_link_quoted.include?('&')
          end
          puts "#{old_link} -> #{new_link}"
        end
      end

      puts "done"
    end

    desc '画像ファイルのディレクトリを移動します'
    task :modify_image_dir, [:system] => :environment do |task, args|
      image_models = [Gwbbs::Image, Gwfaq::Image, Gwqa::Image, Doclibrary::Image, Digitallibrary::Image]
      image_models = image_models.select {|model| get_system_name(model) == args[:system].to_s } if args[:system].present?

      image_models.each do |image_model|
        image_model.preload(:doc).find_each do |image|
          next unless image.doc
          next if image.parent_name.to_s.size != 8

          old_path = get_old_image_path(image)
          next unless FileTest.exist?(old_path)

          FileUtils.mkdir_p(image.f_path) unless FileTest.exist?(image.f_path)
          FileUtils.mv(old_path, image.f_name)
          puts "#{old_path} -> #{image.f_name}"
        end
      end

      puts "done"
    end

    desc '画像ファイルのリンクを修正します'
    task :modify_image_link, [:system, :target] => :environment do |task, args|
      image_models = [Gwbbs::Image, Gwfaq::Image, Gwqa::Image, Doclibrary::Image, Digitallibrary::Image]
      image_models = image_models.select {|model| get_system_name(model) == args[:system].to_s } if args[:system].present?

      image_models.each do |image_model|
        system_name = get_system_name(image_model)
        image_model.preload(:doc).find_each do |image|
          next unless image.doc
          next if image.parent_name.to_s.size != 8

          # 画像ファイルリンクの新旧対応
          old_link = get_old_image_uri(image)
          new_link = image.file_uri

          # 置換
          old_link_quoted = ActiveRecord::Base.connection.quote(old_link)
          new_link_quoted = ActiveRecord::Base.connection.quote(new_link)
          if args[:target] == 'all'
            [Gwbbs::Doc, Gwfaq::Doc, Gwqa::Doc, Doclibrary::Doc, Digitallibrary::Doc].each do |doc_model|
              doc_model.update_all("body = replace(body, #{old_link_quoted}, #{new_link_quoted})")
            end
          else
            image.doc.class.where(id: image.doc.id).update_all("body = replace(body, #{old_link_quoted}, #{new_link_quoted})")
          end
          puts "#{old_link} -> #{new_link}"
        end
      end

      puts "done"
    end

    desc '添付ファイル、画像ファイルのリンクを修正します'
    task :modify_attach_and_image_link, [:system] => :environment do |task, args|
      # 修正対象カラム
      update_models_and_columns = {
        Gwbbs::Doc => [:body],
        Gwfaq::Doc => [:body],
        Gwqa::Doc => [:body],
        Doclibrary::Doc => [:body],
        Digitallibrary::Doc => [:body], 
        Gwcircular::Doc => [:body],
        Gwmonitor::Control => [:caption],
        Gwsub::Sb01Training => [:body]
      }

      file_models = [Gwbbs::File, Gwfaq::File, Gwqa::File, Doclibrary::File, Digitallibrary::File]
      file_models = file_models.select {|model| get_system_name(model) == args[:system].to_s } if args[:system].present?

      image_models = [Gwbbs::Image, Gwfaq::Image, Gwqa::Image, Doclibrary::Image, Digitallibrary::Image]
      image_models = image_models.select {|model| get_system_name(model) == args[:system].to_s } if args[:system].present?

      update_models_and_columns.each do |doc_model, columns|
        columns.each do |column|
          # attaches
          doc_model.where("lower(#{column}) regexp 'attaches/(gwbbs|gwfaq|gwqa|doclibrary|digitallibrary)/'").find_each do |record|
            new_body = record.read_attribute(column).dup
  
            file_models.each do |file_model|
              system_name = get_system_name(file_model)
              new_body.gsub!(/attaches\/#{system_name}\/(\d+)\/(\d+)\/(\d+)\/(\d+)\//) do |link|
                if file = file_model.where(title_id: $1.to_i, serial_no: "#{$3}#{$4}".to_i).first
                  new_link = "attaches/#{system_name}/#{$1}/#{file.send(:parent_id_dir)}/#{file.send(:self_id_dir)}/"
                  puts "#{doc_model.table_name} #{record.id}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
            end
  
            record.update_columns(column => new_body) if new_body != record.read_attribute(column)
          end
  
          # receipts
          doc_model.where("lower(#{column}) regexp '/gwboard/receipts/(gwbbs|gwfaq|gwqa|doclibrary|digitallibrary)/'").find_each do |record|
            new_body = record.read_attribute(column).dup
  
            file_models.each do |file_model|
              system_name = get_system_name(file_model)
              new_body.gsub!(/\/gwboard\/receipts\/(\d+)\/download_object?system=#{system_name}&title_id=(\d+)/) do |link|
                if file = file_model.where(title_id: $2.to_i, serial_no: $1.to_i).first
                  new_link = "/gwboard/receipts/#{file.id}/download_object?system=#{system_name}&title_id=#{$2}"
                  puts "#{doc_model.table_name} #{record.id}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
            end
  
            record.update_columns(column => new_body) if new_body != record.read_attribute(column)
          end
  
          # modules
          doc_model.where("lower(#{column}) regexp '/_common/modules/(gwbbs|gwfaq|gwqa|doclibrary|digitallibrary)/'").find_each do |record|
            new_body = record.read_attribute(column).dup
  
            image_models.each do |image_model|
              system_name = get_system_name(image_model)
              new_body.gsub!(/\/_common\/modules\/#{system_name}\/(\d+)\/(\d+)\/(\d+)\/(\d+)\//) do |link|
                if image = image_model.where(title_id: $1.to_i, serial_no: "#{$3}#{$4}".to_i).first
                  new_link = "/_common/modules/#{system_name}/#{$1}/#{image.send(:parent_id_dir)}/#{image.send(:self_id_dir)}/"
                  puts "#{doc_model.table_name} #{record.id}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
            end
  
            record.update_columns(column => new_body) if new_body != record.read_attribute(column)
          end
        end
      end

      puts "done"
    end

    desc 'emotionsアイコンのリンクを修正します'
    task :modify_emotions_link, [:mode] => :environment do |task, args|
      # 修正対象カラム
      update_models_and_columns = {
        Gwbbs::Doc => [:body],
        Gwfaq::Doc => [:body],
        Gwqa::Doc => [:body],
        Doclibrary::Doc => [:body],
        Digitallibrary::Doc => [:body], 
        Gwcircular::Doc => [:body],
        Gwmonitor::Control => [:caption],
        Gwsub::Sb01Training => [:body]
      }

      update_models_and_columns.each do |doc_model, columns|
        old_link = '/_common/tiny_mce/plugins/emotions/img/'
        new_link = '/_common/tiny_mce/plugins/prefemotions/img/'
        columns.each do |column|
          doc_model.update_all("#{column} = replace(#{column}, '#{old_link}', '#{new_link}')")
        end
      end
      puts "done"
    end

    desc '記事のリンクを修正します'
    task :modify_doc_link, [:system] => :environment do |task, args|
      # 修正対象カラム
      update_models_and_columns = {
        Gwbbs::Doc => [:body],
        Gwfaq::Doc => [:body],
        Gwqa::Doc => [:body],
        Doclibrary::Doc => [:body],
        Digitallibrary::Doc => [:body], 
        Gwmonitor::Control => [:caption],
        Gwcircular::Doc => [:body],
        Gw::Memo => [:body],
        Gw::UserProperty => [:options],
        Gw::PropExtraPmRemark => [:url],
        Gwsub::Sb01Training => [:body, :bbs_url],
        Gwsub::Sb01TrainingGuide => [:bbs_url],
        Gwsub::Sb04CheckSection => [:bbs_url],
        Gwsub::Sb04SeatingList => [:bbs_url],
        Gwsub::Sb04help => [:bbs_url],
        Gwsub::Sb04section => [:bbs_url],
        Gwsub::Sb06AssignedHelp => [:bbs_url],
        Gwsub::Sb06BudgetNotice => [:bbs_url]
      }

      update_models_and_columns.each do |model, columns|
        columns.each do |column|
          model.where("lower(#{column}) regexp '/(gwbbs|gwfaq|gwqa|doclibrary|digitallibrary)/docs'").find_each do |record|
            body = record.read_attribute(column)
            new_body = body.dup

            # gwbbs
            if args[:system].blank? || args[:system] == 'gwbbs'
              new_body.gsub!(/\/gwbbs\/docs\/(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)/) do |link|
                if doc = Gwbbs::Doc.where(title_id: $3, serial_no: $1).first
                  new_link = "/gwbbs/docs/#{doc.id}#{$2}title_id=#{doc.title_id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
            end

            # gwfaq
            if args[:system].blank? || args[:system] == 'gwfaq'
              new_body.gsub!(/\/gwfaq\/docs\/(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)/) do |link|
                if doc = Gwfaq::Doc.where(title_id: $3, serial_no: $1).first
                  new_link = "/gwfaq/docs/#{doc.id}#{$2}title_id=#{doc.title_id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
            end

            # gwqa
            if args[:system].blank? || args[:system] == 'gwqa'
              new_body.gsub!(/\/gwqa\/docs\/(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)/) do |link|
                if doc = Gwqa::Doc.where(title_id: $3, serial_no: $1).first
                  new_link = "/gwqa/docs/#{doc.id}#{$2}title_id=#{doc.title_id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
            end

            # doclibrary
            if args[:system].blank? || args[:system] == 'doclibrary'
              new_body.gsub!(/\/doclibrary\/docs\/(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)([\x20-\x3D|\x3F-\x7E]*?)cat=(\d+)/) do |link|
                doc = Doclibrary::Doc.where(title_id: $3, serial_no: $1).first
                folder = Doclibrary::Folder.where(title_id: $3, serial_no: $5).first
                if doc && folder
                  new_link = "/doclibrary/docs/#{doc.id}#{$2}title_id=#{doc.title_id}#{$4}cat=#{folder.id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
              new_body.gsub!(/\/doclibrary\/docs\/(\d+)([\x20-\x3D|\x3F-\x7E]*?)cat=(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)/) do |link|
                doc = Doclibrary::Doc.where(title_id: $5, serial_no: $1).first
                folder = Doclibrary::Folder.where(title_id: $5, serial_no: $3).first
                if doc && folder
                  new_link = "/doclibrary/docs/#{doc.id}#{$2}title_id=#{doc.title_id}#{$4}cat=#{folder.id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
              new_body.gsub!(/\/doclibrary\/docs\/(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)/) do |link|
                if doc = Doclibrary::Doc.where(title_id: $3, serial_no: $1).first
                  new_link = "/doclibrary/docs/#{doc.id}#{$2}title_id=#{doc.title_id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
              new_body.gsub!(/\/doclibrary\/docs([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)([\x20-\x3D|\x3F-\x7E]*?)cat=(\d+)/) do |link|
                if folder = Doclibrary::Folder.where(title_id: $2, serial_no: $4).first
                  new_link = "/doclibrary/docs#{$1}title_id=#{folder.title_id}#{$3}cat=#{folder.id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
              new_body.gsub!(/\/doclibrary\/docs([\x20-\x3D|\x3F-\x7E]*?)cat=(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)/) do |link|
                if folder = Doclibrary::Folder.where(title_id: $4, serial_no: $2).first
                  new_link = "/doclibrary/docs#{$1}title_id=#{folder.title_id}#{$3}cat=#{folder.id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
            end

            # digitallibrary
            if args[:system].blank? || args[:system] == 'digitallibrary'
              new_body.gsub!(/\/digitallibrary\/docs\/(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)([\x20-\x3D|\x3F-\x7E]*?)cat=(\d+)/) do |link|
                doc = Digitallibrary::Doc.where(title_id: $3, serial_no: $1).first
                folder = Digitallibrary::Doc.where(title_id: $3, serial_no: $5).first
                if doc && folder
                  new_link = "/digitallibrary/docs/#{doc.id}#{$2}title_id=#{doc.title_id}#{$4}cat=#{folder.id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
              new_body.gsub!(/\/digitallibrary\/docs\/(\d+)([\x20-\x3D|\x3F-\x7E]*?)cat=(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)/) do |link|
                doc = Digitallibrary::Doc.where(title_id: $5, serial_no: $1).first
                folder = Digitallibrary::Doc.where(title_id: $5, serial_no: $3).first
                if doc && folder
                  new_link = "/digitallibrary/docs/#{doc.id}#{$2}title_id=#{doc.title_id}#{$4}cat=#{folder.id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
              new_body.gsub!(/\/digitallibrary\/docs\/(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)/) do |link|
                if doc = Digitallibrary::Doc.where(title_id: $3, serial_no: $1).first
                  new_link = "/digitallibrary/docs/#{doc.id}#{$2}title_id=#{doc.title_id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
              new_body.gsub!(/\/digitallibrary\/docs([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)([\x20-\x3D|\x3F-\x7E]*?)cat=(\d+)/) do |link|
                if folder = Digitallibrary::Doc.where(title_id: $2, serial_no: $4).first
                  new_link = "/digitallibrary/docs#{$1}title_id=#{folder.title_id}#{$3}cat=#{folder.id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
              new_body.gsub!(/\/digitallibrary\/docs([\x20-\x3D|\x3F-\x7E]*?)cat=(\d+)([\x20-\x3D|\x3F-\x7E]*?)title_id=(\d+)/) do |link|
                if folder = Digitallibrary::Doc.where(title_id: $4, serial_no: $2).first
                  new_link = "/digitallibrary/docs#{$1}title_id=#{folder.title_id}#{$3}cat=#{folder.id}"
                  puts "#{model.table_name} #{record.id} #{column}: #{link} -> #{new_link}"
                  new_link
                else
                  link
                end
              end
            end

            record.update_columns(column => new_body) if new_body != body
          end
        end
      end

      puts "done"
    end

    desc '研修申込の添付ファイル情報をメインデータベースにコピーします'
    task :copy_sb01_data => :environment do |task, args|
      conn = ActiveRecord::Base.connection
      conn.execute "insert into gwsub_sb01_training_files (id, unid, content_id, state, created_at, updated_at, recognized_at, published_at, latest_updated_at, parent_id, title_id, content_type, filename, memo, size, width, height, db_file_id) \
          select id, unid, content_id, state, created_at, updated_at, recognized_at, published_at, latest_updated_at, parent_id, title_id, content_type, filename, memo, size, width, height, db_file_id from gwbbs_files where title_id = 5"

      Gwsub::Sb01TrainingFile.find_each do |file|
        doc = Gwbbs::Doc.find_by(id: file.parent_id)
        next unless doc
        training = Gwsub::Sb01Training.find_by(bbs_doc_id: doc.serial_no)
        next unless training

        file.update_columns(parent_id: training.id, content_id: 1)
      end

      puts "done"
    end

    desc '研修申込の添付ファイルを新ディレクトリにコピーします'
    task :modify_sb01_attach_dir => :environment do |task, args|
      Gwsub::Sb01TrainingFile.find_each do |file|
        next unless file.parent
        Dir.glob("#{Rails.root}/public/_attaches/gwbbs/000005/**/*").each do |old_file|
          next unless FileTest.file?(old_file)

          if old_file =~ /\/(\d+)\/(\d+)\/(\d+)\/(\d+)\/([^\/]+)$/
            new_file = "#{Rails.root}/public/_attaches/gwsub/sb01_training/#{sprintf("%06d", file.parent_id)}/#{$3}/#{$4}/#{$5}"
            new_dir = File.dirname(new_file)
            FileUtils.mkdir_p(new_dir) unless FileTest.exist?(new_dir)
            FileUtils.cp(old_file, new_file)
            puts "#{old_file} -> #{new_file}"
          end
        end
      end

      puts "done"
    end

    desc 'メインデータベースのボード系テーブルをクリアします'
    task :clear_board_data, [:system] => :environment do |task, args|
      models = _target_models_and_columns
      models = models.select {|model, _| get_system_name(model) == args[:system].to_s} if args[:system].present?

      models.each do |model, _|
        model.connection.execute "truncate table #{model.table_name}"
      end
      puts "done"
    end

    desc '統合済みのサブデータベース、ボード系データベースを削除します'
    task :drop_db => :environment do
      db_conf = JoruriGw::Application.config.database_configuration
      db_keys = ["dev_jgw_gw", "gw", "gwsub"]
      db_names = db_keys.map{|key| db_conf[key]["database"] if db_conf[key] }.compact

      _target_control_models.each do |control_model|
        control_model.select(:id, :dbname).order(:id).each do |control|
          db_names << control.dbname if control.dbname.present?
        end
      end
      db_names.sort!

      puts "Are you sure to delete databases as follows?"
      puts db_names.join("\n")
      print "[yes/no] "

      if STDIN.gets.chomp != "yes"
        puts "cancelled"
        next
      end

      db_names.each do |db_name|
        puts "deleting database '#{db_name}'..."
        ActiveRecord::Base.connection.execute("drop database if exists #{db_name}")
      end

      puts "done"
    end
  end
end
