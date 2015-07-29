# -*- encoding: utf-8 -*-
module Digitallibrary::Admin::Piece::MenusHelper

  def digitallibrary_folder_trees(items)
    last  = []
    count = []
    if items.size > 0
      class_str = %Q(level#{items[0].level_no})
      if @btmfolder == 1
        html = "<li class='bottom'><ul class='#{class_str}'>\n"
      else
        html = "<li><ul class='#{class_str}'>\n"
      end
      last[items[0].level_no] = 0
      count[items[0].level_no] = 1

      items.each do |item|
        sub_folders  = readable_or_writable_sub_folders(item) if item.doc_type == 0
        last[items[0].level_no] = 1 if count[items[0].level_no] == items.select{|x| x.state == 'public' }.size
        html << "#{digitallibrary_folder_li(item,last[items[0].level_no],sub_folders)}\n"
        count[items[0].level_no] =  count[items[0].level_no]+1

        check_code = item.id.to_s
        if @folders[item.level_no].to_s == check_code
          str_html = ''
          if params[:f] == 'op'
            unless check_code == params[:cat].to_s
              sub_folders  = item.children.select{|x| x.state == 'public'}
              str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
            end
          else
            sub_folders  = item.children.select{|x| x.state == 'public'}
            str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
          end
          html << str_html unless str_html.blank?
        end if sub_folders.size > 0 unless params[:fld] == 'fop' if item.doc_type == 0

        if params[:fld] == 'fop'
          str_html = ''
          if params[:f] == 'op'
            if @folders[item.level_no] == item.id
              sub_folders  = item.children.select{|x| x.state == 'public'}
              str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
            else
              if item.level_no == 1
                sub_folders  = item.children.select{|x| x.state == 'public'}
                str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
              end
            end
          else
            sub_folders  = item.children.select{|x| x.state == 'public'}
            str_html = digitallibrary_folder_trees(sub_folders) unless sub_folders.count == 0
          end
          html << str_html unless str_html.blank?
        end if sub_folders.size > 0 if item.doc_type == 0
      end
    html << "</ul></li>\n"
    return html.html_safe
    end
  end

  def digitallibrary_folder_li(item, last, sub_folders )
    tree_state = false
    @btmfolder = 0
    ret = ''
    tree_state = true unless item.state == 'preparation'
    tree_state = false unless @is_writable
    tree_state = true if item.state == 'public'
    #sub_folders  = item.children.select{|x| x.state == 'public'}
    if tree_state
      level_no = 'folder'
      level_no = 'f_plus' unless sub_folders.size == 0 if item.doc_type == 0
      level_no = 'draft' unless item.state == 'public'
      level_no = 'doc' if item.doc_type == 1 and item.state == 'public'

      if params[:f] == 'op'
        unless params[:fld] == 'fop'
          unless item.id.to_s == params[:cat].to_s
            level_no = 'open' if @folders[item.level_no].to_s == item.id.to_s
            level_no = 'open' if params[:fld]=='fop' and item.state=='public' and item.doc_type!= 1
            level_no = 'open current' if item.id.to_s == params[:cat].to_s if item.doc_type == 0
            level_no = 'doc current' if item.id.to_s == params[:cat].to_s if item.doc_type == 1
          else
            level_no = 'folder current'
            level_no = 'f_plus current' unless sub_folders.size == 0 if item.doc_type == 0
            level_no = 'draft current' unless item.state == 'public'
            level_no = 'doc current' if item.doc_type == 1 and item.state == 'public'
          end
        end

        if params[:fld] == 'fop'
          if @folders[item.level_no].to_s == item.id.to_s
            level_no = 'open' if @folders[item.level_no].to_s == item.id.to_s
            level_no = 'open' if params[:fld]=='fop' and item.state=='public' and item.doc_type!= 1
            level_no = 'open current' if item.id.to_s == params[:cat].to_s if item.doc_type == 0
            level_no = 'doc current' if item.id.to_s == params[:cat].to_s if item.doc_type == 1
          end
        end
      else
        level_no = 'open' if @folders[item.level_no].to_s == item.id.to_s
        level_no = 'open' if params[:fld]=='fop' and item.state=='public' and item.doc_type!= 1
        level_no = 'open current' if item.id.to_s == params[:cat].to_s if item.doc_type == 0
        level_no = 'doc current' if item.id.to_s == params[:cat].to_s if item.doc_type == 1
      end

      level_no = 'root' if item.level_no == 1
      if level_no == 'open current' || level_no == 'open'
        level_no = level_no + ' noneFolder' if sub_folders.count == 0 if item.doc_type == 0
      end

       if last.to_i == 1
         if item.doc_type.to_i == 1
          level_no = level_no + " bottomFile"
         else
          level_no = level_no + " bottomFolder"
          if /open/ =~ level_no
            level_no = level_no.gsub(/open /,'')
            level_no = level_no.gsub(/bottomFolder/,' openBottomFolder')
          end
         end
        @btmfolder = 1
      end
      lvnm = ""
      unless item.seq_name.blank?
        lvnm = ""
        lvnm = "[編集]" unless item.state == 'public'
        lvnm = lvnm + "(#{item.seq_name})" if @title.category == 0
      end
      s_fop = ""
      s_fop = "&fld=fop" if params[:fld] == 'fop' if params[:f].blank?

      strparam = ''
      if /open/ =~ level_no
        strparam = "&f=op" unless item.id.to_s == '1'
      end unless sub_folders.count == 0 if item.doc_type == 0
      strparam = "&f=op" if s_fop == "&fld=fop" if item.doc_type == 1
      lib_show_path = "#{digitallibrary_doc_path(item)}?title_id=#{item.title_id}"
      lib_show_path += "&cat=#{item.id}" if item.doc_type == 1              #記事
      lib_show_path += "&cat=#{item.parent_id}" unless item.doc_type == 1   #見出し
      
      ret = %Q(<li class="#{level_no}">)
      unless item.doc_type == 1
        ret << link_to("#{lvnm}#{item.title}", "#{digitallibrary_docs_path}?title_id=#{item.title_id}&cat=#{item.id}#{s_fop}#{strparam}")
      else
        ret << link_to(lvnm + item.title.to_s, "#{lib_show_path}#{s_fop}#{strparam}")
      end
      ret << %Q(</li>)
    end
    return ret
  end

protected

  def readable_or_writable_sub_folders(item)
    group_codes = Site.parent_user_groups.map{|x| x.code}

    sub_folders = item.children.select{|x|
      #if @is_admin
      #  x.state == 'public'
      #else
      #  ((x.state == 'public') and (group_codes.index(x.acl_section_code) != nil)) ||
      #  ((x.state == 'public') and (x.acl_user_code == Site.user.code))
      #end
      x.state == 'public'
    }
    sub_folders.uniq
  end
end
