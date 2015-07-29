module Doclibrary::Admin::Piece::MenusHelper

  def doclibrary_folder_trees(items)
    return if items.blank?
    return if items.size == 0
    last  = []
    count = []
    class_str = %Q(level#{items[0].level_no})
    if @btmfolder == 1
      html = "<li class='bottom'><ul class='#{class_str}'>\n"
    else
      html = "<li><ul class='#{class_str}'>\n"
    end

    last[items[0].level_no] = 0
    count[items[0].level_no] = 1

    items.each do |item|
     unless @iname == item.id
      @iname = item.id
      last[items[0].level_no] = 1 if count[items[0].level_no] == items.size
      html << "#{doclibrary_folder_li(item,last[items[0].level_no])}\n"
      count[items[0].level_no] =  count[items[0].level_no]+1
      check_code = item.id.to_s
      if @folders[item.level_no].to_s == check_code
        if params[:f] == 'op'
          unless check_code == params[:cat].to_s
            str_html = ''
            sub_folders = category_sub_folders(item)
            str_html = doclibrary_folder_trees(sub_folders) unless sub_folders.count == 0 unless sub_folders.blank?
            html << str_html unless str_html.blank?
          end
        else
          str_html = ''
          sub_folders = category_sub_folders(item)
          str_html = doclibrary_folder_trees(sub_folders) unless sub_folders.count == 0 unless sub_folders.blank?
          html << str_html unless str_html.blank?
        end
      end if item.children.size > 0
     end
    end
    html << "</ul></li>\n"
    return html.html_safe
  end

  def group_sub_folders(item)
    return item.children.select{|x| x.state == 'public'}
  end

  def category_sub_folders(item)
      parent_grp = Site.user.groups[0].parent unless Site.user.groups[0].parent.blank?
      p_grp_code = ''
      p_grp_code = parent_grp.code unless parent_grp.blank?
      grp_code = Site.user.groups[0].code unless Site.user.groups.blank?
      enabled_children = item.enabled_children
      sub_folders = enabled_children.select{|x|
        if @is_admin
          ((x.state == 'public') and (x.acl_flag == 0)) || ((x.state == 'public') and (x.acl_flag == 9))
        else
          ((x.state == 'public') and (x.acl_flag == 0)) ||
          ((x.state == 'public') and (x.acl_flag == 1) and (x.acl_section_code == p_grp_code)) ||
          ((x.state == 'public') and (x.acl_flag == 1) and (x.acl_section_code == grp_code)) ||
          ((x.state == 'public') and (x.acl_flag == 2) and (x.acl_user_code == Site.user.code))
        end
      }
    return sub_folders
  end

  def doclibrary_folder_li(item,last)
    @btmfolder = 0
    ret = ''
    sub_folders = category_sub_folders(item)
    children_count = item.count_children.count
    if item.state == 'public'
      level_no = 'folder'
      level_no = 'f_plus' unless children_count == 0
      level_no = 'root' if item.level_no == 1
      if params[:f] == 'op'
        unless item.id.to_s == params[:cat].to_s
          level_no = 'open' if @folders[item.level_no].to_s == item.id.to_s
          level_no = 'open current' if item.id.to_s == params[:cat].to_s
        else
          level_no = 'folder current'
          level_no = 'f_plus current' unless children_count == 0
        end
      else
        level_no = 'open' if @folders[item.level_no].to_s == item.id.to_s
        level_no = 'open current' if item.id.to_s == params[:cat].to_s
      end
      if level_no == 'open current'
        level_no = level_no + " noneFolder" if children_count == 0
      end
      if last.to_i == 1
        level_no = level_no + " bottomFolder"
        @btmfolder = 1
        if /open/ =~ level_no
          level_no = level_no.gsub(/open/,'')
          level_no = level_no.gsub(/ bottomFolder/,' openBottomFolder')
        end
      end
      level_no = level_no + " noneFolder" if sub_folders.count == 0
      strparam = ''
      strparam += "&state=#{params[:state]}" unless params[:state]== 'DRAFT' unless params[:state].blank?
      if /open/ =~ level_no
        strparam += "&f=op" unless item.id.to_s == '1'
      end unless sub_folders.count == 0
      
      ret  = %Q(<li class="#{level_no}">)
      ret << link_to(item.name, "#{@title.item_home_path}docs?title_id=#{item.title_id}&cat=#{item.id}#{strparam}")
      ret << %Q(</li>)
    end
    return ret
  end
end
