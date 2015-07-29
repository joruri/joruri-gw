# encoding: utf-8
class Gw::Tool::Board

  def self.valid_url?(url)
    if url =~ %r{/gwbbs/}
      return self.gwbbs_check(url)
    elsif url =~ %r{/gwfaq/}
      return self.gwfaq_check(url)
    elsif url =~ %r{/gwqa/}
      return self.gwqa_check(url)
    elsif url =~ %r{/doclibrary/}
      return self.doclibrary_check(url)
    elsif url =~ %r{/digitallibrary/}
      return self.digitallibrary_check(url)
    end
    return true
  end

  def self.gwbbs_check(url)
    opts = {:system=>'gwbbs',:type=>'docs',:action=>'',:tid=>'',:did=>'',:cid=>'',:state=>''}
    if url =~ %r{.*/gwbbs/comments/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'edit'
      opts[:type] = 'comments'
      opts[:cid] = $1
      opts[:tid] = $2
      opts[:state] = $3
    elsif url =~ %r{.*/gwbbs/comments/(\d+)/edit[/?](?=.*title_id=(\d+))}
      opts[:action] = 'edit'
      opts[:type] = 'comments'
      opts[:cid] = $1
      opts[:tid] = $2
    elsif url =~ %r{.*/gwbbs/comments/new[/?](?=.*title_id=(\d+))(?=.*p_id=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'new'
      opts[:type] = 'comments'
      opts[:tid] = $1
      opts[:did] = $2
      opts[:state] = $3
    elsif url =~ %r{.*/gwbbs/comments/new[/?](?=.*title_id=(\d+))(?=.*p_id=(\d+))}
      opts[:action] = 'new'
      opts[:type] = 'comments'
      opts[:tid] = $1
      opts[:did] = $2
    elsif url =~ %r{.*/gwbbs/docs/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'edit'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:state] = $3
    elsif url =~ %r{.*/gwbbs/docs/(\d+)/edit[/?](?=.*title_id=(\d+))}
      opts[:action] = 'edit'
      opts[:did] = $1
      opts[:tid] = $2
    elsif url =~ %r{.*/gwbbs/docs/(\d+)[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'show'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:state] = $3
    elsif url =~ %r{.*/gwbbs/docs/(\d+)[/?](?=.*title_id=(\d+))}
      opts[:action] = 'show'
      opts[:did] = $1
      opts[:tid] = $2
    elsif url =~ %r{.*/gwbbs/docs/new[/?](?=.*title_id=(\d+))}
      opts[:action] = 'new'
      opts[:tid] = $1
    elsif url =~ %r{.*/gwbbs/docs[/?](?=.*title_id=(\d+))}
      opts[:action] = 'index'
      opts[:tid] = $1
    end
    flag = true
    if opts[:tid] != ''
      case opts[:action]
      when 'new', 'edit'
        flag = self.writable_board?(opts[:system], opts[:tid].to_i, opts)
      when 'show', 'index'
        flag = self.readable_board?(opts[:system], opts[:tid].to_i, opts)
      end
      if flag && opts[:did] != ''
        flag = self.gwbbs_docs?(opts[:system], opts[:tid].to_i, opts[:did].to_i, opts)
      end
      if flag && opts[:cid] != ''
        flag = self.gwbbs_comments?(opts[:system], opts[:tid].to_i, opts[:cid].to_i, opts)
      end
    end
    return flag
  end

  def self.gwfaq_check(url)
    opts = {:system=>'gwfaq',:type=>'docs',:action=>'',:tid=>'',:did=>'',:state=>''}
    if url =~ %r{.*/gwfaq/docs/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'edit'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:state] = $3
    elsif url =~ %r{.*/gwfaq/docs/(\d+)/edit[/?](?=.*title_id=(\d+))}
      opts[:action] = 'edit'
      opts[:did] = $1
      opts[:tid] = $2
    elsif url =~ %r{.*/gwfaq/docs/(\d+)[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'show'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:state] = $3
    elsif url =~ %r{.*/gwfaq/docs/(\d+)[/?](?=.*title_id=(\d+))}
      opts[:action] = 'show'
      opts[:did] = $1
      opts[:tid] = $2
    elsif url =~ %r{.*/gwfaq/docs/new[/?](?=.*title_id=(\d+))}
      opts[:action] = 'new'
      opts[:tid] = $1
    elsif url =~ %r{.*/gwfaq/docs[/?](?=.*title_id=(\d+))}
      opts[:action] = 'index'
      opts[:tid] = $1
    end
    flag = true
    if opts[:tid] != ''
      case opts[:action]
      when 'new', 'edit'
        flag = self.writable_board?(opts[:system], opts[:tid].to_i, opts)
      when 'show', 'index'
        flag = self.readable_board?(opts[:system], opts[:tid].to_i, opts)
      end
      if flag && opts[:did] != ''
        flag = self.gwfaq_docs?(opts[:system], opts[:tid].to_i, opts[:did].to_i, opts)
      end
    end
    return flag
  end

  def self.gwqa_check(url)
    opts = {:system=>'gwqa',:type=>'docs',:action=>'',:tid=>'',:did=>'',:pid=>'',:state=>''}
    if url =~ %r{.*/gwqa/docs/(\d+)/settlement[/?](?=.*title_id=(\d+))}
      opts[:action] = 'settlement'
      opts[:did] = $1
      opts[:tid] = $2
    elsif url =~ %r{.*/gwqa/docs/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*p_id=(\d+))}
      opts[:action] = 'edit'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:pid] = $3
    elsif url =~ %r{.*/gwqa/docs/(\d+)/edit[/?](?=.*title_id=(\d+))}
      opts[:action] = 'edit'
      opts[:did] = $1
      opts[:tid] = $2
    elsif url =~ %r{.*/gwqa/docs/(\d+)[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'show'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:state] = $3
    elsif url =~ %r{.*/gwqa/docs/(\d+)[/?](?=.*title_id=(\d+))}
      opts[:action] = 'show'
      opts[:did] = $1
      opts[:tid] = $2
    elsif url =~ %r{.*/gwqa/docs/new[/?](?=.*title_id=(\d+))(?=.*p_id=(\d+))}
      opts[:action] = 'new'
      opts[:tid] = $1
      opts[:did] = $2
    elsif url =~ %r{.*/gwqa/docs/new[/?](?=.*title_id=(\d+))}
      opts[:action] = 'new'
      opts[:tid] = $1
    elsif url =~ %r{.*/gwqa/docs[/?](?=.*title_id=(\d+))}
      opts[:action] = 'index'
      opts[:tid] = $1
    end

    flag = true
    if opts[:tid] != ''
      case opts[:action]
      when 'new', 'edit', 'settlement'
        flag = self.writable_board?(opts[:system], opts[:tid].to_i, opts)
      when 'show', 'index'
        flag = self.readable_board?(opts[:system], opts[:tid].to_i, opts)
      end
      if flag && opts[:did] != ''
        flag = self.gwqa_docs?(opts[:system], opts[:tid].to_i, opts[:did].to_i, opts)
      end
      if flag && opts[:pid] != ''
        flag = self.gwqa_docs?(opts[:system], opts[:tid].to_i, opts[:pid].to_i, opts)
      end
    end
    return flag
  end

  def self.doclibrary_check(url)
    opts = {:system=>'doclibrary',:type=>'',:action=>'',:tid=>'',:did=>'',:state=>'',:cat=>''}
    if url =~ %r{.*/doclibrary/folders/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'edit'
      opts[:type] = 'folders'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
      opts[:state] = $4
    elsif url =~ %r{.*/doclibrary/docs/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'edit'
      opts[:type] = 'docs'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
      opts[:state] = $4

    elsif url =~ %r{.*/doclibrary/folders/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'show'
      opts[:type] = 'folders'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
      opts[:state] = $4
    elsif url =~ %r{.*/doclibrary/docs/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'show'
      opts[:type] = 'docs'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
      opts[:state] = $4

    elsif url =~ %r{.*/doclibrary/folders/new[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
      opts[:action] = 'new'
      opts[:type] = 'folders'
      opts[:tid] = $1
      opts[:cat] = $2
    elsif url =~ %r{.*/doclibrary/docs/new[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
      opts[:action] = 'new'
      opts[:type] = 'docs'
      opts[:tid] = $1
      opts[:cat] = $2

    elsif url =~ %r{.*/doclibrary/docs[/?](?=.*title_id=(\d+))}
      opts[:action] = 'index'
      opts[:type] = 'docs'
      opts[:tid] = $1
    end

    flag = true
    if opts[:tid] != ''

      case opts[:action]
      when 'new', 'edit'
        flag = self.writable_board?(opts[:system], opts[:tid].to_i, opts)
      when 'show', 'index'
        flag = self.readable_board?(opts[:system], opts[:tid].to_i, opts)
      end

      if flag && opts[:did] != '' && opts[:type] == 'docs'
        flag = self.doclibrary_docs?(opts[:system], opts[:tid].to_i, opts[:did].to_i, opts)
      end

      if flag && opts[:did] != '' && opts[:type] == 'folders'
        flag = self.doclibrary_folders?(opts[:system], opts[:tid].to_i, opts[:did].to_i, opts)
      end

      if flag && opts[:cat] != ''
        flag = self.doclibrary_folders?(opts[:system], opts[:tid].to_i, opts[:cat].to_i, opts)
      end
    end
    return flag
  end

  def self.digitallibrary_check(url)
    opts = {:system=>'digitallibrary',:type=>'',:action=>'',:tid=>'',:did=>'',:fid=>'',:state=>'',:cat=>''}

    if url =~ %r{.*/digitallibrary/docs/(\d+)/edit_file_memo/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'edit_file_memo'
      opts[:type] = 'docs'
      opts[:did] = $1
      opts[:fid] = $2
      opts[:tid] = $3
      opts[:cat] = $4
      opts[:state] = $5
    elsif url =~ %r{.*/digitallibrary/docs/(\d+)/edit_file_memo/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
      opts[:action] = 'edit_file_memo'
      opts[:type] = 'docs'
      opts[:did] = $1
      opts[:fid] = $2
      opts[:tid] = $3
      opts[:cat] = $4

    elsif url =~ %r{.*/digitallibrary/folders/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'edit'
      opts[:type] = 'folders'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
      opts[:state] = $4
    elsif url =~ %r{.*/digitallibrary/docs/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'edit'
      opts[:type] = 'docs'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
      opts[:state] = $4
    elsif url =~ %r{.*/digitallibrary/folders/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
      opts[:action] = 'edit'
      opts[:type] = 'folders'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
    elsif url =~ %r{.*/digitallibrary/docs/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
      opts[:action] = 'edit'
      opts[:type] = 'docs'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3

    elsif url =~ %r{.*/digitallibrary/folders/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'show'
      opts[:type] = 'folders'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
      opts[:state] = $4
    elsif url =~ %r{.*/digitallibrary/docs/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
      opts[:action] = 'show'
      opts[:type] = 'docs'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
      opts[:state] = $4
    elsif url =~ %r{.*/digitallibrary/folders/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
      opts[:action] = 'show'
      opts[:type] = 'folders'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3
    elsif url =~ %r{.*/digitallibrary/docs/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
      opts[:action] = 'show'
      opts[:type] = 'docs'
      opts[:did] = $1
      opts[:tid] = $2
      opts[:cat] = $3

    elsif url =~ %r{.*/digitallibrary/folders/new[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
      opts[:action] = 'new'
      opts[:type] = 'folders'
      opts[:tid] = $1
      opts[:cat] = $2
    elsif url =~ %r{.*/digitallibrary/docs/new[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
      opts[:action] = 'new'
      opts[:type] = 'docs'
      opts[:tid] = $1
      opts[:cat] = $2

    elsif url =~ %r{.*/digitallibrary/docs[/?](?=.*title_id=(\d+))}
      opts[:action] = 'index'
      opts[:type] = 'docs'
      opts[:tid] = $1
    end

    flag = true
    if opts[:tid] != ''

      case opts[:action]
      when 'new', 'edit', 'edit_file_memo'
        flag = self.writable_board?(opts[:system], opts[:tid].to_i, opts)
      when 'show', 'index'
        flag = self.readable_board?(opts[:system], opts[:tid].to_i, opts)
      end

      if flag && opts[:did] != '' && opts[:type] == 'docs'
        flag = self.digitallibrary_docs?(opts[:system], opts[:tid].to_i, opts[:did].to_i, opts)
      end

      if flag && opts[:did] != '' && opts[:type] == 'folders'
        flag = self.digitallibrary_folders?(opts[:system],opts[:tid].to_i, opts[:did].to_i, opts)
      end

      if flag && opts[:cat] != ''
        flag = self.digitallibrary_folders?(opts[:system],opts[:tid].to_i, opts[:cat].to_i, opts)
      end

      if flag && opts[:fid] != ''
        flag = self.digitallibrary_files?(opts[:system],opts[:tid].to_i, opts[:fid].to_i, opts)
      end
    end
    return flag
  end

  def self.get_title(system, title_id)
    item = self.gwboard_control(system)
    item = item.new
    item.and :state, 'public'
    item.and :id, title_id
    title = item.find(:first)
    return title
  end

  def self.get_titles(system)
    item = self.gwboard_control(system)
    item = item.new
    item.and :state, 'public'
    item.and :view_hide, 1
    item.order 'sort_no'
    return item.find(:all)
  end

  def self.readable_board?(system, title_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    opts[:admin] = self.get_admin_flag(system, title.id)
    if opts[:admin]
      readable = true
    else
      readable = self.get_readable_flag(system, title)
    end
    return readable
  end

  def self.writable_board?(system, title_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    opts[:admin] = self.get_admin_flag(system, title.id)
    if opts[:admin]
      writable = true
    else
      writable = self.get_writable_flag(system, title)
    end
    return writable
  end

  def self.gwbbs_docs?(system, title_id, doc_id, opts={})
    return !self.gwbbs_docs(system, title_id, doc_id, opts).blank?
  end

  def self.gwbbs_docs(system, title_id, doc_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    cond = Condition.new
    cond.and 'id', doc_id
    cond.and 'title_id', title.id

    if opts[:state]
      case opts[:state]
      when 'DRAFT'
        cond.and 'state', 'draft'
      when 'NEVER'
        cond.and 'state', 'public'
        cond.and 'sql', "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' < gwbbs_docs.able_date"
      when 'VOID'
        cond.and 'state', 'public'
        cond.and 'sql', "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' > gwbbs_docs.expiry_date"
      when 'RECOGNIZE'
        cond.and 'state', 'recognize'
      when 'PUBLISH'
        cond.and 'state', 'recognized'
      else
        cond.and 'state', 'public'
        cond.and 'sql', "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' > gwbbs_docs.able_date"
        cond.and 'sql', "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' < gwbbs_docs.expiry_date"
      end
    end

    if !opts[:admin] && title.restrict_access
      cond.and 'section_code', "#{Site.user_group.code}"
    end
    model = self.gwboard_doc(system, title).new
    items = model.find(:all, :conditions => cond.where)
    self.gwboard_doc_close(system)
    return items
  end

  def self.gwbbs_comments?(system, title_id, doc_id, opts={})
    return !self.gwbbs_comments(system, title_id, doc_id, opts).blank?
  end

  def self.gwbbs_comments(system, title_id, comment_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    cond = Condition.new
    cond.and 'gwbbs_comments.id', comment_id
    cond.and 'gwbbs_comments.title_id', title.id

    case opts[:state]
      when 'DRAFT'
        cond.and 'gwbbs_docs.state', 'draft'
      when 'NEVER'
        cond.and 'gwbbs_docs.state', 'public'
      when 'VOID'
        cond.and 'gwbbs_docs.state', 'public'
      when 'RECOGNIZE'
        cond.and 'gwbbs_docs.state', 'recognize'
      when 'PUBLISH'
        cond.and 'gwbbs_docs.state', 'recognized'
      else
        cond.and 'gwbbs_docs.state', 'public'
    end

    if !opts[:admin] && title.restrict_access
      cond.and 'gwbbs_docs.section_code', "#{Site.user_group.code}"
    end
    model = self.gwboard_comment(system, title).new
    items = model.find(:all, :conditions=>cond.where, :select=>'gwbbs_docs.*' ,:joins => ['inner join gwbbs_docs on gwbbs_docs.id = gwbbs_comments.parent_id'])
    self.gwboard_comment_close(system)
    return items
  end

  def self.gwfaq_docs?(system, title_id, doc_id, opts={})
    return !self.gwfaq_docs(system, title_id, doc_id, opts).blank?
  end

  def self.gwfaq_docs(system, title_id, doc_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    cond = Condition.new
    cond.and 'id', doc_id
    cond.and 'title_id', title.id

    if opts[:state]
      case opts[:state]
      when 'TODAY'
        cond.and 'state', 'public'
        cond.and 'sql', "'#{Time.now.strftime('%Y-%m-%d')} 00:00:00' < gwfaq_docs.latest_updated_at AND gwfaq_docs.latest_updated_at < '#{Time.now.strftime('%Y-%m-%d')} 23:59:59'"
      when 'DRAFT'
        cond.and 'state', 'draft'
      else
        cond.and 'state', 'public'
      end
    end
    model = self.gwboard_doc(system, title).new
    items = model.find(:all, :conditions => cond.where)
    self.gwboard_doc_close(system)
    return items
  end

  def self.gwqa_docs?(system, title_id, doc_id, opts={})
    return !self.gwqa_docs(system, title_id, doc_id, opts).blank?
  end

  def self.gwqa_docs(system, title_id, doc_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    cond = Condition.new
    cond.and 'id', doc_id
    cond.and 'title_id', title.id
    model = self.gwboard_doc(system, title).new
    items = model.find(:all, :conditions => cond.where)
    self.gwboard_doc_close(system)
    return items
  end

  def self.doclibrary_docs?(system, title_id, doc_id, opts={})
    return !self.doclibrary_docs(system, title_id, doc_id, opts).blank?
  end

  def self.doclibrary_docs(system, title_id, doc_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    cond = Condition.new
    cond.and 'id', doc_id
    cond.and 'title_id', title.id

    if opts[:state]
      case opts[:state]
      when 'DRAFT'
        cond.and 'state', 'draft'
      else
        cond.and 'state', 'public'
      end
    end
    model = self.gwboard_doc(system, title).new
    items = model.find(:all, :conditions => cond.where)
    self.gwboard_doc_close(system)
    return items
  end

  def self.doclibrary_folders?(system, title_id, doc_id, opts={})
    return !self.doclibrary_folders(system, title_id, doc_id, opts).blank?
  end

  def self.doclibrary_folders(system, title_id, folder_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    cond = Condition.new
    cond.and 'id', folder_id
    cond.and 'title_id', title.id
    model = self.gwboard_folder(system, title).new
    items = model.find(:all, :conditions => cond.where)
    self.gwboard_folder_close(system)
    return items
  end

  def self.digitallibrary_docs?(system, title_id, doc_id, opts={})
    return !self.digitallibrary_docs(system, title_id, doc_id, opts).blank?
  end

  def self.digitallibrary_docs(system, title_id, doc_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    cond = Condition.new
    cond.and 'id', doc_id
    cond.and 'title_id', title.id
    cond.and 'doc_type', 1

    if opts[:state]
      case opts[:state]
      when 'DRAFT'
        cond.and 'state', 'draft'
      else
        cond.and 'state', 'public'
      end
    end
    model = self.gwboard_doc(system, title).new
    items = model.find(:all, :conditions => cond.where)
    self.gwboard_doc_close(system)
    return items
  end

  def self.digitallibrary_folders?(system, title_id, doc_id, opts={})
    return !self.digitallibrary_folders(system, title_id, doc_id, opts).blank?
  end

  def self.digitallibrary_folders(system, title_id, folder_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    cond = Condition.new
    cond.and 'id', folder_id
    cond.and 'title_id', title.id
    cond.and 'doc_type', 0
    model = self.gwboard_folder(system, title).new
    items = model.find(:all, :conditions => cond.where)
    self.gwboard_folder_close(system)
    return items
  end

  def self.digitallibrary_files?(system, title_id, file_id, opts={})
    return !self.digitallibrary_files(system, title_id, file_id, opts).blank?
  end

  def self.digitallibrary_files(system, title_id, file_id, opts={})

    title = self.get_title(system, title_id)

    return false if title.blank?

    cond = Condition.new
    cond.and 'id', file_id
    cond.and 'title_id', title.id
    model = self.gwboard_file(system, title).new
    items = model.find(:all, :conditions => cond.where)
    self.gwboard_file_close(system)
    return items
  end

  def self.gwboard_control(system)
    case system
      when 'gwbbs'
        sys = Gwbbs::Control
      when 'gwfaq'
        sys = Gwfaq::Control
      when 'gwqa'
        sys = Gwqa::Control
      when 'doclibrary'
        sys = Doclibrary::Control
      when 'digitallibrary'
        sys = Digitallibrary::Control
    end
    return sys
  end

  def self.gwboard_adm(system)
    case system
      when 'gwbbs'
        sys = Gwbbs::Adm
      when 'gwfaq'
        sys = Gwfaq::Adm
      when 'gwqa'
        sys = Gwqa::Adm
      when 'doclibrary'
        sys = Doclibrary::Adm
      when 'digitallibrary'
        sys = Digitallibrary::Adm
    end
    return sys
  end

  def self.gwboard_role(system)
    case system
      when 'gwbbs'
        sys = Gwbbs::Role
      when 'gwfaq'
        sys = Gwfaq::Role
      when 'gwqa'
        sys = Gwqa::Role
      when 'doclibrary'
        sys = Doclibrary::Role
      when 'digitallibrary'
        sys = Digitallibrary::Role
    end
    return sys
  end

  def self.gwboard_doc(system, title)
    case system
      when 'gwbbs'
        sys = Gwbbs::Doc
      when 'gwfaq'
        sys = Gwfaq::Doc
      when 'gwqa'
        sys = Gwqa::Doc
      when 'doclibrary'
        sys = Doclibrary::Doc
      when 'digitallibrary'
        sys = Digitallibrary::Doc
    end
    return gwboard_db_alias2(sys, title)
  end

  def self.gwboard_doc_close(system)
    case system
      when 'gwbbs'
        Gwbbs::Doc.remove_connection
      when 'gwfaq'
        Gwfaq::Doc.remove_connection
      when 'gwqa'
        Gwqa::Doc.remove_connection
      when 'doclibrary'
        Doclibrary::Doc.remove_connection
      when 'digitallibrary'
        Digitallibrary::Doc.remove_connection
    end
  end

  def self.gwboard_comment(system, title)
    case system
      when 'gwbbs'
        sys = Gwbbs::Comment
    end
    return gwboard_db_alias2(sys, title)
  end

  def self.gwboard_comment_close(system)
    case system
      when 'gwbbs'
        Gwbbs::Comment.remove_connection
    end
  end

  def self.gwboard_folder(system, title)
    case system
      when 'doclibrary'
        sys = Doclibrary::Folder
      when 'digitallibrary'
        sys = Digitallibrary::Folder
    end
    return gwboard_db_alias2(sys, title)
  end

  def self.gwboard_folder_close(system)
    case system
      when 'doclibrary'
        Doclibrary::Folder.remove_connection
      when 'digitallibrary'
        Digitallibrary::Folder.remove_connection
    end
  end

  def self.gwboard_file(system, title)
    case system
      when 'doclibrary'
        sys = Doclibrary::File
      when 'digitallibrary'
        sys = Digitallibrary::File
    end
    return gwboard_db_alias2(sys, title)
  end

  def self.gwboard_file_close(system)
    case system
      when 'doclibrary'
        Doclibrary::File.remove_connection
      when 'digitallibrary'
        Digitallibrary::File.remove_connection
    end
  end

  protected

  def self.gwboard_db_alias2(item, title)

    cnn = item.establish_connection

    cn = cnn.spec.config[:database]

    dbname = ''
    dbname = title.dbname unless title.blank?
    unless dbname == ''
      cnn.spec.config[:database] = title.dbname.to_s
    else
      dbstr = ''
      dbstr = '_qa' if item.table_name.index("gwqa_")
      dbstr = '_bbs' if item.table_name.index("gwbbs_")
      dbstr = '_faq' if item.table_name.index("gwfaq_")
      dbstr = '_doc' if item.table_name.index("doclibrary_")
      dbstr = '_dig' if item.table_name.index("digitallibrary_")

      l = 0
      l = cn.length if cn
      if l != 0
        i = cn.rindex "_", cn.length
        cnn.spec.config[:database] = cn[0,i] + dbstr
      else
        cnn.spec.config[:database] = "dev_jgw" + dbstr
      end

      unless title.id.blank?
        if self.is_integer(title_id)
          cnn.spec.config[:database] +=  '_' + sprintf("%06d", title_id)
        end
      end
    end
    item::Gwboard::CommonDb.establish_connection(cnn.spec)

    return item

  end

  def self.get_admin_flag(system, title_id)
    is_sysadm = true if System::Model::Role.get(1, Site.user.id ,system, 'admin')
    is_sysadm = true if System::Model::Role.get(2, Site.user_group.id ,system, 'admin') unless is_sysadm
    is_bbsadm = true if is_sysadm

    unless is_bbsadm
      item = gwboard_adm(system)
      item = item.new
      item.and :user_id, 0
      item.and :group_code, Site.user_group.code
      item.and :title_id, title_id unless title_id == '_menu'
      items = item.find(:all)
      is_bbsadm = true unless items.blank?

      unless is_bbsadm
        item = gwboard_adm(system)
        item = item.new
        item.and :user_code, Site.user.code
        item.and :group_code, Site.user_group.code
        item.and :title_id, title_id unless title_id == '_menu'
        items = item.find(:all)
        is_bbsadm = true unless items.blank?
      end
    end

    is_admin = true if is_sysadm
    is_admin = true if is_bbsadm
    return is_admin
  end

  def self.get_writable_flag(system, title)
    is_writable = false
    sql = Condition.new
    sql.and :role_code, 'w'
    sql.and :title_id, title.id
    r_item = self.gwboard_role(system)
    items = r_item.find(:all, :order=>'group_code', :conditions => sql.where)
    items.each do |item|
      is_writable = true if item.group_code == '0'
      for group in Site.user.groups
        is_writable = true if item.group_code == group.code
        is_writable = true if item.group_code == group.parent.code unless group.parent.blank?
        break if is_writable
      end
      break if is_writable
    end
    unless is_writable
      item = self.gwboard_role(system)
      item = item.new
      item.and :role_code, 'w'
      item.and :title_id, title.id
      item.and :user_code, Site.user.code
      item = item.find(:first)
      is_writable = true if item.user_code == Site.user.code unless item.blank?
    end
    return is_writable
  end

  def self.get_readable_flag(system, title)
    is_readable = false
    sql = Condition.new
    sql.and :role_code, 'r'
    sql.and :title_id, title.id
    sql.and 'sql', 'user_id IS NULL'
    r_item = self.gwboard_role(system)
    items = r_item.find(:all, :order=>'group_code', :conditions => sql.where)
    items.each do |item|
      is_readable = true if item.group_code == '0'

      for group in Site.user.groups
        is_readable = true if item.group_code == group.code
        is_readable = true if item.group_code == group.parent.code unless group.parent.blank?
        break if is_readable
      end
      break if is_readable
    end

    unless is_readable
      item = self.gwboard_role(system)
      item = item.new
      item.and :role_code, 'r'
      item.and :title_id, title.id
      item.and :user_code, Site.user.code
      item = item.find(:first)
      is_readable = true if item.user_code == Site.user.code unless item.blank?
    end
    return is_readable
  end

  def self.is_integer(no)
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
end
