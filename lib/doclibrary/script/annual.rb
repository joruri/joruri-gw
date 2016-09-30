class Doclibrary::Script::Annual

  def self.renew(start_date = nil)
    if start_date.blank?
      return false
    else
      @start_date = start_date
    end
    p "書庫年次切替所属情報更新 開始:#{Time.now}."
    renew_adms
    renew_admingrps_json
    renew_roles
    renew_editors_json
    renew_readers_json
    renew_docs_section_code
    renew_folder_acls
    renew_folder_reader_groups_json
    renew_dsp_admin_name
    p "書庫年次切替所属情報更新 終了:#{Time.now}."
  end

  def self.renew_adms
    p "renew_adms 開始:#{Time.now}."
    sql  = 'SELECT group_id, group_code'
    sql += " FROM doclibrary_adms"
    sql += " GROUP BY group_id, group_code"
    sql += " ORDER BY group_id, group_code"
    adms = Doclibrary::Adm.find_by_sql(sql)
    for adm in adms
      item = Gwboard::RenewalGroup.new
      item.and :present_group_id, adm.group_id
      item.and :present_group_code, adm.group_code
      item.and :start_date, @start_date
      group = item.find(:first, :order=> 'present_group_id, present_group_code')
      next if group.blank?

      update_fields="group_id=#{group.incoming_group_id}, group_code='#{group.incoming_group_code}',group_name='#{group.incoming_group_name}'"
      sql_where = "group_id=#{adm.group_id} AND group_code='#{adm.group_code}'"
      Doclibrary::Adm.where(:group_id=>adm.group_id, :group_code=>adm.group_code).update_all(:group_id=>group.incoming_group_id,:group_code=>group.incoming_group_code,:group_name=>group.incoming_group_name)
      p "#{adm.group_id}, #{adm.group_code}, #{update_fields}, #{Time.now}."
    end
    p "renew_adms 終了:#{Time.now}."
  end

  def self.renew_admingrps_json
    p "renew_admingrps_json 開始:#{Time.now}."

    title = Doclibrary::Control.new
    titles = title.find(:all, :order=>'id')

    for title in titles
      groups = title.admingrps_json.blank? ? [] : JSON.parse(title.admingrps_json)
      is_update = false
      groups.each do |group|
        renewal = Gwboard::RenewalGroup.new
        renewal.and :present_group_id, group[1]
        renewal.and :present_group_code, group[0]
        renewal.and :start_date, @start_date
        if item = renewal.find(:first)
          group[0] = item.incoming_group_code
          group[1] = item.incoming_group_id.to_s
          group[2] = item.incoming_group_name
          is_update = true
        else
          renewal = Gwboard::RenewalGroup.new
          renewal.and :present_group_id, group[1]
          renewal.and :start_date, @start_date
          if item = renewal.find(:first)
            group[1] = item.incoming_group_id.to_s
            group[2] = item.incoming_group_name
            is_update = true
          end
        end
      end
      if is_update
        groups.uniq!
        update_field = "admingrps_json='#{JSON.generate(groups)}'"
        Doclibrary::Control.where(:id=>title.id).update_all(:admingrps_json=>JSON.generate(groups))
        p "#{title.id}, #{update_field}, #{Time.now}."
      end
    end
    p "renew_admingrps_json 終了:#{Time.now}."
  end

  def self.renew_roles
    p "renew_roles 開始:#{Time.now}."

    sql  = 'SELECT group_id, group_code'
    sql += " FROM doclibrary_roles"
    sql += " GROUP BY group_id, group_code"
    sql += " ORDER BY group_id, group_code"
    roles = Doclibrary::Role.find_by_sql(sql)
    for role in roles
      next if role.group_id.blank?
      next if role.group_id == 0

      item = Gwboard::RenewalGroup.new
      item.and :present_group_id, role.group_id
      item.and :present_group_code, role.group_code
      item.and :start_date, @start_date
      group = item.find(:first, :order=> 'present_group_id, present_group_code')
      next if group.blank?

      update_fields="group_id=#{group.incoming_group_id}, group_code='#{group.incoming_group_code}',group_name='#{group.incoming_group_name}'"
      sql_where = "group_id=#{role.group_id} AND group_code='#{role.group_code}'"
      Doclibrary::Role.where(:group_id=>role.group_id,:group_code=>role.group_code).update_all(:group_id=>group.incoming_group_id,:group_code=>group.incoming_group_code,:group_name=>group.incoming_group_name)
      p "#{role.group_id}, #{role.group_code}, #{update_fields}, #{Time.now}."
    end
    p "renew_roles 終了:#{Time.now}."
  end

  def self.renew_editors_json
    p "renew_editors_json 開始:#{Time.now}."

    title = Doclibrary::Control.new
    titles = title.find(:all, :order=>'id')

    for title in titles
      groups = title.editors_json.blank? ? [] : JSON.parse(title.editors_json)
      is_update = false
      groups.each_with_index do |group,idx|
        renewal = Gwboard::RenewalGroup.new
        renewal.and :present_group_id, group[1]
        renewal.and :present_group_code, group[0]
        renewal.and :start_date, @start_date
        if item = renewal.find(:first)
          group[0] = item.incoming_group_code
          group[1] = item.incoming_group_id.to_s
          group[2] = item.incoming_group_name
          is_update = true
        else
          renewal = Gwboard::RenewalGroup.new
          renewal.and :present_group_id, group[1]
          renewal.and :start_date, @start_date
          if item = renewal.find(:first)
            group[1] = item.incoming_group_id.to_s
            group[2] = item.incoming_group_name
            is_update = true
          end
        end
      end
      if is_update
        groups.uniq!
        update_field = "editors_json='#{JSON.generate(groups)}'"
        Doclibrary::Control.where(:id=>title.id).update_all(:editors_json=>JSON.generate(groups))
        p "#{title.id}, #{update_field}, #{Time.now}."
      end
    end
    p "renew_editors_json 終了:#{Time.now}."
  end

  def self.renew_readers_json
    p "renew_readers_json 開始:#{Time.now}."

    title = Doclibrary::Control.new
    titles = title.find(:all, :order=>'id')

    for title in titles
      groups = title.readers_json.blank? ? [] : JSON.parse(title.readers_json)
      is_update = false
      groups.each do |group|
        renewal = Gwboard::RenewalGroup.new
        renewal.and :present_group_id, group[1]
        renewal.and :present_group_code, group[0]
        renewal.and :start_date, @start_date
        if item = renewal.find(:first)
          group[0] = item.incoming_group_code
          group[1] = item.incoming_group_id.to_s
          group[2] = item.incoming_group_name
          is_update = true
        else
          renewal = Gwboard::RenewalGroup.new
          renewal.and :present_group_id, group[1]
          renewal.and :start_date, @start_date
          if item = renewal.find(:first)
            group[1] = item.incoming_group_id.to_s
            group[2] = item.incoming_group_name
            is_update = true
          end
        end
      end
      if is_update
        groups.uniq!
        update_field = "readers_json='#{JSON.generate(groups)}'"
        Doclibrary::Control.where(:id=>title.id).update_all(:readers_json=>JSON.generate(groups))
        p "#{title.id}, #{update_field}, #{Time.now}."
      end
    end
    p "renew_readers_json 終了:#{Time.now}."
  end

  def self.renew_folder_acls
    p "renew_folder_acls 開始:#{Time.now}."

    items = Doclibrary::Control.all.order('id')
    for @title in items
      acls = Doclibrary::FolderAcl.where(:title_id => @title.id).select("acl_section_id, acl_section_code").group("acl_section_id, acl_section_code").order(:acl_section_id).order(:acl_section_code)
      for acl in acls
        next if acl.acl_section_id.blank?

        item = Gwboard::RenewalGroup.new
        item.and :present_group_id, acl.acl_section_id
        item.and :present_group_code, acl.acl_section_code
        item.and :start_date, @start_date
        group = item.find(:first)
        next if group.blank?

        update_fields="acl_section_id=#{group.incoming_group_id}, acl_section_code='#{group.incoming_group_code}',acl_section_name='#{group.incoming_group_name}'"
        sql_where = "acl_section_id=#{acl.acl_section_id} AND acl_section_code='#{acl.acl_section_code}'"
        target_item = Doclibrary::FolderAcl.where(:acl_section_id=>acl.acl_section_id,:acl_section_code=>acl.acl_section_code)
        target_item.update_all(:acl_section_id=>group.incoming_group_id,:acl_section_code=>group.incoming_group_code,:acl_section_name=>group.incoming_group_name)
        p "#{@title.dbname}, #{sql_where}, #{update_fields}, #{Time.now}."
      end
    end
    p "renew_folder_acls 終了:#{Time.now}."
  end

  def self.renew_folder_reader_groups_json
    p "renew_folder_reader_groups_json 開始:#{Time.now}."

    items = Doclibrary::Control.all
    for @title in items
      item = Doclibrary::FolderAcl
      item = item.new
      item.and :title_id, @title.id
      item.and :acl_flag, 1
      acls = item.find(:all, :order=>'folder_id, acl_section_id')
      break_folder_id = 0
      is_update = false
      array_group = Array.new
      for acl in acls
        unless acl.folder_id == break_folder_id
          if is_update
            update_field = "reader_groups_json='#{JSON.generate(array_group)}'"
            folder = Doclibrary::Folder
            folder.where(:id=>break_folder_id).update_all(:reader_groups_json=>JSON.generate(array_group))
            p "#{@title.dbname}, #{break_folder_id}, #{update_field}, #{Time.now}."
          end
          is_update = false
          array_group = Array.new
        end unless break_folder_id == 0

        array_group << [acl.acl_section_code.to_s, acl.acl_section_id.to_s, acl.acl_section_name.to_s]

        item = Gwboard::RenewalGroup.new
        item.and :incoming_group_id, acl.acl_section_id
        item.and :incoming_group_code, acl.acl_section_code
        item.and :start_date, @start_date
        group = item.find(:first, :order=> 'incoming_group_id, incoming_group_code')
        is_update = true unless group.blank?
      end
      unless break_folder_id == 0
        if is_update
          update_field = "reader_groups_json='#{JSON.generate(array_group)}'"
          folder = Doclibrary::Folder
          folder.where(:id=>break_folder_id).update_all(:reader_groups_json=>JSON.generate(array_group))
          p "#{@title.dbname}, #{break_folder_id}, #{update_field}, #{Time.now}."

        end
      end

    end
    p "renew_folder_reader_groups_json 終了:#{Time.now}."
  end

  def self.renew_docs_section_code
    p "renew_docs_section_code 開始:#{Time.now}."

    items = Doclibrary::Control.all
    for @title in items
      begin
        doc_item = Doclibrary::Doc
        docs = Doclibrary::Doc.where(:title_id => @title.id).select(:section_code).group(:section_code).order(:section_code)
        for doc in docs
          next if doc.section_code.blank?
          group = Gwboard::RenewalGroup.new
          group.and :present_group_code, doc.section_code
          group.and :start_date, @start_date
          group = group.find(:first)
          next if group.blank?

          update_fields = "section_code='#{group.incoming_group_code}', section_name='#{group.incoming_group_code}#{group.incoming_group_name}'"
          doc_item.where(:id => doc.id , :title_id => @title.id, :section_code=>doc.section_code).update_all(:section_code=>group.incoming_group_code,:section_name=>"#{group.incoming_group_code}#{group.incoming_group_name}")
          p "#{@title.dbname}, #{doc.section_code}, #{update_fields}, #{Time.now}."
        end
      rescue => ex
        p "ERROR: #{@title.dbname} :#{ex.message}."
      end

    end
    p "renew_docs_section_code 終了:#{Time.now}."
  end

  def self.renew_dsp_admin_name
    p "renew_dsp_admin_name 開始:#{Time.now}."

    title = Doclibrary::Control.new
    titles = title.find(:all, :order=> 'id')
    for title in titles
      group = Gwboard::RenewalGroup.new
      group.and :present_group_name, title.dsp_admin_name
      group.and :start_date, @start_date
      group = group.find(:first)
      next if group.blank?

      update_field = "dsp_admin_name='#{group.incoming_group_name}'"
      Doclibrary::Control.where(:id=>title.id).update_all(:dsp_admin_name=>group.incoming_group_name)
      p "#{title.id}, #{title.create_section}, #{update_field}, #{Time.now}."
    end

    p "renew_dsp_admin_name 終了:#{Time.now}."
  end

  def self.db_alias(item)
    cnn = item.establish_connection

    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end

end
