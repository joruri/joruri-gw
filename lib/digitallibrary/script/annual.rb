# -*- encoding: utf-8 -*-
class Digitallibrary::Script::Annual

  def self.renew(start_date = nil)
    if start_date.blank?
      return false
    else
      @start_date = start_date
    end
    p "電子図書年次切替所属情報更新 開始:#{Time.now}."
    renew_adms
    renew_admingrps_json
    renew_roles
    renew_editors_json
    renew_readers_json
    renew_docs_section_code
    renew_dsp_admin_name
    p "電子図書年次切替所属情報更新 終了:#{Time.now}."
  end

  def self.renew_adms
    p "renew_adms 開始:#{Time.now}."
    sql  = 'SELECT group_id, group_code'
    sql += " FROM digitallibrary_adms"
    sql += " GROUP BY group_id, group_code"
    sql += " ORDER BY group_id, group_code"
    adms = Digitallibrary::Adm.find_by_sql(sql)
    for adm in adms
      item = Gwboard::RenewalGroup.new
      item.and :present_group_id, adm.group_id
      item.and :present_group_code, adm.group_code
      item.and :start_date, @start_date
      group = item.find(:first, :order=> 'present_group_id, present_group_code')
      next if group.blank?

      update_fields="group_id=#{group.incoming_group_id}, group_code='#{group.incoming_group_code}',group_name='#{group.incoming_group_name}'"
      update_set = ["group_id= ?, group_code= ? ,group_name= ? ", group.incoming_group_id, group.incoming_group_code, group.incoming_group_name]
      sql_where = "group_id=#{adm.group_id} AND group_code='#{adm.group_code}'"
      Digitallibrary::Adm.update_all(update_set, sql_where)
      p "#{adm.group_id}, #{adm.group_code}, #{update_fields}, #{Time.now}."
    end
    p "renew_adms 終了:#{Time.now}."
  end

  def self.renew_admingrps_json
    p "renew_admingrps_json 開始:#{Time.now}."

    title = Digitallibrary::Control.new
    titles = title.find(:all, :order=>'id')

    for title in titles
      groups = JsonParser.new.parse(title.admingrps_json)
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
        update_field = "admingrps_json='#{JsonBuilder.new.build(groups)}'"
        update_set = ["admingrps_json=?" , JsonBuilder.new.build(groups)]
        Digitallibrary::Control.update_all(update_set, "id=#{title.id}")
        p "#{title.id}, #{update_field}, #{Time.now}."
      end
    end
    p "renew_admingrps_json 終了:#{Time.now}."
  end

  def self.renew_roles
    p "renew_roles 開始:#{Time.now}."

    sql  = 'SELECT group_id, group_code'
    sql += " FROM digitallibrary_roles"
    sql += " GROUP BY group_id, group_code"
    sql += " ORDER BY group_id, group_code"
    roles = Digitallibrary::Role.find_by_sql(sql)
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
      update_set = ["group_id= ?, group_code= ? ,group_name= ? ", group.incoming_group_id, group.incoming_group_code, group.incoming_group_name]
      sql_where = "group_id=#{role.group_id} AND group_code='#{role.group_code}'"
      Digitallibrary::Role.update_all(update_set, sql_where)
      p "#{role.group_id}, #{role.group_code}, #{update_fields}, #{Time.now}."
    end
    p "renew_roles 終了:#{Time.now}."
  end

  def self.renew_editors_json
    p "renew_editors_json 開始:#{Time.now}."

    title = Digitallibrary::Control.new
    titles = title.find(:all, :order=>'id')

    for title in titles
      groups = JsonParser.new.parse(title.editors_json)
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
        update_field = "editors_json='#{JsonBuilder.new.build(groups)}'"
        update_set = ["editors_json=?" , JsonBuilder.new.build(groups)]
        Digitallibrary::Control.update_all(update_set, "id=#{title.id}")
        p "#{title.id}, #{update_field}, #{Time.now}."
      end
    end
    p "renew_editors_json 終了:#{Time.now}."
  end

  def self.renew_readers_json
    p "renew_readers_json 開始:#{Time.now}."

    title = Digitallibrary::Control.new
    titles = title.find(:all, :order=>'id')

    for title in titles
      groups = JsonParser.new.parse(title.readers_json)
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
        update_field = "readers_json='#{JsonBuilder.new.build(groups)}'"
        update_set = ["readers_json=?" , JsonBuilder.new.build(groups)]
        Digitallibrary::Control.update_all(update_set, "id=#{title.id}")
        p "#{title.id}, #{update_field}, #{Time.now}."
      end
    end
    p "renew_readers_json 終了:#{Time.now}."
  end

  def self.renew_docs_section_code
    p "renew_docs_section_code 開始:#{Time.now}."

    items = Digitallibrary::Control.find(:all, :order=>'id')
    for @title in items
      begin
        doc_item = db_alias(Digitallibrary::Doc)
        sql  = 'SELECT section_code FROM digitallibrary_docs GROUP BY section_code ORDER BY section_code'
        docs = doc_item.find_by_sql(sql)
        for doc in docs
          next if doc.section_code.blank?
          group = Gwboard::RenewalGroup.new
          group.and :present_group_code, doc.section_code
          group.and :start_date, @start_date
          group = group.find(:first)
          next if group.blank?

          update_fields = "section_code='#{group.incoming_group_code}', section_name='#{group.incoming_group_code}#{group.incoming_group_name}'"
          update_set = ["section_code=?, section_name=?", group.incoming_group_code, %Q(#{group.incoming_group_code}#{group.incoming_group_name})]
          doc_item.update_all(update_set, "section_code='#{doc.section_code}'")
          p "#{@title.dbname}, #{doc.section_code}, #{update_fields}, #{Time.now}."
        end
      rescue => ex
        p "ERROR: #{@title.dbname} :#{ex.message}."
      end
      Digitallibrary::Doc.remove_connection
    end
    p "renew_docs_section_code 終了:#{Time.now}."
  end

  def self.renew_dsp_admin_name
    p "renew_dsp_admin_name 開始:#{Time.now}."

    title = Digitallibrary::Control.new
    titles = title.find(:all, :order=> 'id')
    for title in titles
      group = Gwboard::RenewalGroup.new
      group.and :present_group_name, title.dsp_admin_name
      group.and :start_date, @start_date
      group = group.find(:first)
      next if group.blank?

      update_field = "dsp_admin_name='#{group.incoming_group_name}'"
      update_set = ["dsp_admin_name=?" , group.incoming_group_name]
      Digitallibrary::Control.update_all(update_set, "id='#{title.id}'")
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
