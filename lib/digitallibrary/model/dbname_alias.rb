# -*- encoding: utf-8 -*-
module Digitallibrary::Model::DbnameAlias

  def set_parent_docs_hash
    item = digitallib_db_alias(Digitallibrary::Doc)
    item = item.new
    item.and :state, 'public'
    item.and :doc_type, 1
    item.and :doc_alias, 0
    items = item.find(:all,:select=>"id, seq_name, title", :order => "seq_name")
    @parent_docs = [["通常の記事として登録する",0]]
    items.each do |item|
      @parent_docs << ["#{item.seq_name} #{item.title}を参照する", item.id] unless item.id.to_s == params[:id].to_s
    end
  end

  def set_tree_list_hash(mode)
    item = digitallib_db_alias(Digitallibrary::Folder)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :level_no, 1
    item.and :doc_type, 0
    item.and :state, '!=','preparation'
    items = item.find(:all,:order => 'level_no, sort_no, parent_id, id')
    @tree_list = []
    make_folder_hash(items, mode)
  end

  def make_folder_hash(items, mode)
    if items.size > 0
      items.each do |item|
        mode_state = false
        mode_state = true unless @item.id == item.id unless @item.id == item.parent_id #自分の子には移動できなくする
        mode_state = true if mode == 'new'
        if item.doc_type == 0
          @tree_list << [item.seq_name, item.id] if @item.parent_id == item.id
          @tree_list << [item.seq_name.to_s + ' <', item.id] unless @item.parent_id == item.id
          if item.children.size > 0
            make_folder_hash(item.children, mode)
          end
        end if mode_state
      end
    end
  end

  def set_position_hash(doc_type)
    item = digitallib_db_alias(Digitallibrary::Folder)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :state, '!=','preparation'
    item.and :doc_type, doc_type
    item.and :parent_id, @item.parent_id
    items = item.find(:all,:order => 'level_no, sort_no, parent_id, id')
    @position = []
    make_position_hash(doc_type, items)
    @position << ['最後尾', 999999999.0]
  end

  def make_position_hash(doc_type, items)
    if items.size > 0
      items.each do |item|
        if item.doc_type == doc_type
          @position << [sprintf("%d",item.seq_no), item.seq_no] if item.seq_no == @item.seq_no
          @position << [sprintf("%d",item.seq_no).to_s + 'の前に挿入', item.seq_no - 0.5] unless item.seq_no == @item.seq_no
        end if item.parent_id == @item.parent_id
      end
    end
  end

  def seq_name_update(p_id)
    folder_item = digitallib_db_alias(Digitallibrary::Folder)
    folder_item.update_all("seq_name = NULL", "title_id = #{params[:title_id]} AND parent_id = #{p_id}")

    f_item = digitallib_db_alias(Digitallibrary::Folder)
    f_item = f_item.new
    f_item.and :title_id, params[:title_id]
    f_item.and :state, '!=','preparation'
    f_item.and :level_no ,'>' ,1
    f_item.and :parent_id , p_id
    items = f_item.find(:all, :order=>"level_no, parent_id, doc_type, seq_no, id")

    seq = 0
    brk_doc_type = ''
    brk_level = ''
    brk_parent = ''
    for item in items

      unless brk_doc_type == item.doc_type
        seq = 0
        brk_doc_type = item.doc_type
      end

      unless brk_level == item.level_no
        seq = 0
        brk_level = item.level_no
      end

      unless brk_parent == item.parent_id
        seq = 0
        brk_parent = item.parent_id
      end
      item.chg_parent_id = item.parent_id
      seq = seq + 1
      item.seq_no = seq
      item.order_no = seq
      item.sort_no = seq + item.doc_type * 1000000000

      if item.parent.seq_name.blank?

        item.seq_name = seq.to_s if item.doc_type == 0
        item.seq_name = seq.to_s unless item.doc_type == 0
      else

        item.seq_name = item.seq_name.to_s + item.parent.seq_name.to_s + @title.separator_str1 + seq.to_s if item.doc_type == 0     #見出し
        item.seq_name = item.seq_name.to_s + item.parent.seq_name.to_s + @title.separator_str2 + seq.to_s unless item.doc_type == 0 #記事
      end if item.parent
      item.save
    end
  end

  def sort_no_update
    folder_item = digitallib_db_alias(Digitallibrary::Folder)
    folder_item.update_all("seq_name = NULL", "title_id =#{params[:title_id]}")

    item = digitallib_db_alias(Digitallibrary::Folder)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :state, '!=','preparation'
    item.and :level_no ,'>' ,1
    items = item.find(:all, :order=>"level_no, parent_id, doc_type, seq_no, id")

    seq = 0
    brk_doc_type = ''
    brk_level = ''
    brk_parent = ''
    for item in items

      unless brk_doc_type == item.doc_type
        seq = 0
        brk_doc_type = item.doc_type
      end

      unless brk_level == item.level_no
        seq = 0
        brk_level = item.level_no
      end

      unless brk_parent == item.parent_id
        seq = 0
        brk_parent = item.parent_id
      end
      item.chg_parent_id = item.parent_id
      seq = seq + 1
      item.seq_no = seq
      item.order_no = seq
      item.sort_no = seq + item.doc_type * 1000000000
      if item.parent.seq_name.blank?
        item.seq_name = seq.to_s if item.doc_type == 0
        item.seq_name = seq.to_s unless item.doc_type == 0
      else
        item.seq_name = item.seq_name.to_s + item.parent.seq_name.to_s + @title.separator_str1 + seq.to_s if item.doc_type == 0
        item.seq_name = item.seq_name.to_s + item.parent.seq_name.to_s + @title.separator_str2 + seq.to_s unless item.doc_type == 0
      end if item.parent
      item.save
    end
  end

  def level_no_rewrite(item, level_item)
    new_level_no = 0
    new_level_no = item.parent.level_no  unless item.parent.blank?
      level_item.update(item.id, :level_no => new_level_no + 1)
  end

  def lower_level_no_rewrite(items, level_item)
    items.each do |item|
      new_level_no = 0
      new_level_no = item.parent.level_no if item.parent
      unless new_level_no == 0
        level_item.update(item.id, :level_no => new_level_no + 1)
      end
      seq_name_update(item.id)
      if 0 < item.children.size
        lower_level_no_rewrite(item.children, level_item)
      end
    end
  end

  def lower_level_state_rewrite(items, state)
    items.each do |item|
      level_item = digitallib_db_alias(Digitallibrary::Folder)
      new_level_no = 0
      new_level_no = item.parent.level_no if item.parent
      new_level_no = new_level_no + 1
      level_item.update(item.id, :level_no) if state =='public' #
      level_item.update(item.id, :state =>'closed') if state =='closed' #
      if item.children.size > 0
        lower_level_state_rewrite(item.children, state)
      end
    end
  end

  def admin_flags(title_id)
    @is_sysadm = true if System::Model::Role.get(1, Site.user.id ,'digitallibrary', 'admin')
    @is_sysadm = true if System::Model::Role.get(2, Site.user_group.id ,'digitallibrary', 'admin') unless @is_sysadm
    @is_bbsadm = true if @is_sysadm
    unless @is_bbsadm
      item = Digitallibrary::Adm.new
      item.and :user_id, 0
      item.and :group_code, Site.user_group.code
      item.and :title_id, title_id unless title_id == '_menu'
      items = item.find(:all)
      @is_bbsadm = true unless items.blank?

      unless @is_bbsadm
        item = Digitallibrary::Adm.new
        item.and :user_code, Site.user.code
        item.and :group_code, Site.user_group.code
        item.and :title_id, title_id unless title_id == '_menu'
        items = item.find(:all)
        @is_bbsadm = true unless items.blank?
      end
    end
    @is_admin = true if @is_sysadm
    @is_admin = true if @is_bbsadm
  end

  def get_writable_flag
    @is_writable = true if @is_admin
    unless @is_writable
      sql = Condition.new
      sql.and :role_code, 'w'
      sql.and :title_id, @title.id
      items = Digitallibrary::Role.find(:all, :order=>'group_code', :conditions => sql.where)
      items.each do |item|
        @is_writable = true if item.group_code == '0'
        for group in Site.user.groups
          @is_writable = true if item.group_code == group.code
          @is_writable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_writable
        end
        break if @is_writable
      end
    end

    unless @is_writable
      item = Digitallibrary::Role.new
      item.and :role_code, 'w'
      item.and :title_id, @title.id
      item.and :user_code, Site.user.code
      item = item.find(:first)
      @is_writable = true if item.user_code == Site.user.code unless item.blank?
    end
  end

  def get_readable_flag

    @is_readable = true if @is_admin
    unless @is_readable
      sql = Condition.new
      sql.and :role_code, 'r'
      sql.and :title_id, @title.id
      items = Digitallibrary::Role.find(:all, :order=>'group_code', :conditions => sql.where)
      items.each do |item|
        @is_readable = true if item.group_code == '0'

        for group in Site.user.groups
          @is_readable = true if item.group_code == group.code
          @is_readable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_readable
        end
        break if @is_readable
      end
    end

    unless @is_readable
      item = Digitallibrary::Role.new
      item.and :role_code, 'r'
      item.and :title_id, @title.id
      item.and :user_code, Site.user.code
      item = item.find(:first)
      @is_readable = true if item.user_code == Site.user.code unless item.blank?
    end
  end

  def self.get_editable_flag(item, is_admin, is_writable)
    is_editable = false
    is_editable = true if is_admin
    unless is_editable
      if is_writable
        for group in Site.user.groups
          is_editable = true if item.section_code == group.code
          is_editable = true if item.section_code == group.parent.code unless group.parent.blank?
          is_editable = true if item.creater_id == Site.user.code
          break if is_editable
        end
      end
    end
    return is_editable
  end

  def digitallib_db_alias(item)

    title_id = params[:title_id]
    title_id = @title.id unless @title.blank?

    cnn = item.establish_connection

    #modelのestablish_connetionが適用されていないので
    #値がproduction or developの初期値がセットされている
    #ex) dev_jgw_core -> dev_jgw_ -> dev_jgw_ + "dig" + "_000000"みたいな感じで処理させたい
    cn = cnn.spec.config[:database]

    dbname = ''
    dbname = @title.dbname unless @title.blank?

    unless dbname == ''
      #コントロールにdbnameが設定されているときは、dbname名で接続する
      cnn.spec.config[:database] = @title.dbname.to_s
    else
      l = 0
      l = cn.length if cn
      if l != 0
        i = cn.rindex "_", cn.length
        cnn.spec.config[:database] = cn[0,i] + '_dig'
      else
        cnn.spec.config[:database] = "dev_jgw_dig"
      end

      unless title_id.blank?
        if is_integer(title_id)
          cnn.spec.config[:database] +=  '_' + sprintf("%06d", title_id)
        end
      end
    end
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item

  end

  #no が　数値でなければ false を返す
  #nilのときは false を返す (false と nil 以外は true)
  #no が　数値の時は 数値を 返す
  def is_integer(no)
    if no == nil
      return false
    else
      begin
        Integer(no)
      rescue
        return false
      end
    end
  end

protected
   def seq_name_update_all()
    folder_item = digitallib_db_alias(Digitallibrary::Folder)
    folder_item.update_all("seq_name = NULL")

    f_item = digitallib_db_alias(Digitallibrary::Folder)
    f_item = f_item.new
    f_item.and :state, '!=','preparation'
    f_item.and :level_no ,'>' ,1
    items = f_item.find(:all, :order=>"level_no, parent_id, doc_type, seq_no, id")

    seq = 0
    brk_doc_type = ''
    brk_level = ''
    brk_parent = ''
    for item in items
      item_seq_no = 0
      item_order_no = 0
      item_sort_no = 0
      item_seq_name = ''

      unless brk_doc_type == item.doc_type
        seq = 0
        brk_doc_type = item.doc_type
      end

      unless brk_level == item.level_no
        seq = 0
        brk_level = item.level_no
      end

      unless brk_parent == item.parent_id
        seq = 0
        brk_parent = item.parent_id
      end
      item.chg_parent_id = item.parent_id
      seq = seq + 1
      item_seq_no = seq
      item_order_no = seq
      item_sort_no = seq + item.doc_type * 1000000000

      if item.parent.seq_name.blank?

        item_seq_name = seq.to_s if item.doc_type == 0
        item_seq_name = seq.to_s unless item.doc_type == 0
      else

        item_seq_name = item.seq_name.to_s + item.parent.seq_name.to_s + @title.separator_str1 + seq.to_s if item.doc_type == 0     #見出し
        item_seq_name = item.seq_name.to_s + item.parent.seq_name.to_s + @title.separator_str2 + seq.to_s unless item.doc_type == 0 #記事
      end if item.parent

      folder_item.update_all("seq_no = #{item_seq_no}, order_no = #{item_order_no}, sort_no = #{item_sort_no}, seq_name = '#{item_seq_name}'", ["id = ?", item.id])
      #item.save
    end
  end

end