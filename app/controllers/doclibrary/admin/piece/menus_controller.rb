class Doclibrary::Admin::Piece::MenusController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Doclibrary::Model::DbnameAlias
  include Doclibrary::Controller::AdmsInclude
  include Gwboard::Controller::Authorize

  def initialize_scaffold
    skip_layout
    @title = Doclibrary::Control.find_by_id(params[:title_id])
    return error_gwbbs_no_title if @title.blank?

    params[:state] = @title.default_folder.to_s if params[:state].blank?
    unless params[:state] == 'GROUP'
      folder = doclib_db_alias(Doclibrary::Folder)
      @folder_items = folder.find(:all, :order=>"level_no DESC, sort_no DESC, id DESC")
    else
      @grp_items = Gwboard::Group.level3_all
    end
    Doclibrary::Folder.remove_connection
  end

  def index
    get_role_index
    return http_error(404) unless @is_readable

    if params[:state] == 'GROUP'
      make_hash_variable_doc_counts
    else
      index_category
    end
  end

  def index_category
    return false if params[:state] == 'GROUP'

    folder = doclib_db_alias(Doclibrary::ViewAclFolder)
    @items = folder.find(:all, :conditions=>["parent_id IS NULL"], :order=>"level_no, sort_no, id")
    fid = params[:cat]
    set_folder_array(fid)
    @parent_group_code = parent_group_code
    Doclibrary::Folder.remove_connection
    Doclibrary::GroupFolder.remove_connection
    Doclibrary::ViewAclFolder.remove_connection
  end

  def set_folder_array(param)
    @folders = []
    return if param.blank?
    fid = param.to_s
    @folder_items.each do |item|
      if fid.to_s == item.id.to_s
        @folders[item.level_no] = item.id
        fid = item.parent_id.to_s
      end if item.state == 'public'
    end
  end
	
  def make_hash_variable_doc_counts

		#改善版を呼び出してリターン
		if TRUE
			make_hash_variable_doc_counts2
			return
		end
		
    p_grp_code = ''
    p_grp_code = Site.user_group.parent.code unless Site.user_group.parent.blank?
    grp_code = ''
    grp_code = Site.user_group.code unless Site.user_group.blank?

    str_where  = " (state = 'public' AND title_id = #{@title.id} AND acl_flag = 0)"
    if @is_admin

      str_where  += " OR (state = 'public' AND title_id = #{@title.id} AND acl_flag = 9)"
    else
      str_where  += " OR (state = 'public' AND title_id = #{@title.id} AND acl_flag = 1 AND acl_section_code = '#{p_grp_code}')"
      str_where  += " OR (state = 'public' AND title_id = #{@title.id} AND acl_flag = 1 AND acl_section_code = '#{grp_code}')"
      str_where  += " OR (state = 'public' AND title_id = #{@title.id} AND acl_flag = 2 AND acl_user_code = '#{Site.user.code}')"
    end
    str_sql  = 'SELECT doclibrary_view_acl_doc_counts.section_code, SUM(doclibrary_view_acl_doc_counts.cnt) AS total_cnt'
    str_sql += ' FROM doclibrary_view_acl_doc_counts'
    str_sql += ' WHERE ' + str_where
    str_sql += ' GROUP BY doclibrary_view_acl_doc_counts.section_code'
    item = doclib_db_alias(Doclibrary::ViewAclDocCount)
    @group_doc_counts = item.find_by_sql(str_sql).index_by(&:section_code)
  end

	def make_hash_variable_doc_counts2
    p_grp_code = ''
    p_grp_code = Site.user_group.parent.code unless Site.user_group.parent.blank?
    grp_code = ''
    grp_code = Site.user_group.code unless Site.user_group.blank?
		is_admin = @is_admin.blank? ? FALSE : TRUE
		
		@group_doc_counts = _make_hash_variable_doc_count2(Site.user.code, is_admin, 'public', @title.id, p_grp_code, grp_code).index_by(&:section_code)
  end

	def _make_hash_variable_doc_count2(user_code, is_admin, state, title_id, parent_group_code, group_code)
    str_where  = " (state = '#{state}' AND doclibrary_folders.title_id = #{title_id}) AND ((acl_flag = 0)"
    if is_admin
      str_where  += " OR (acl_flag = 9))"
    else
      str_where  += " OR (acl_flag = 1 AND acl_section_code = '#{parent_group_code}')"
      str_where  += " OR (acl_flag = 1 AND acl_section_code = '#{group_code}')"
      str_where  += " OR (acl_flag = 2 AND acl_user_code = '#{user_code}'))"
    end
    
		str_sql = 'SELECT doclibrary_folders.id FROM doclibrary_folder_acls, doclibrary_folders WHERE doclibrary_folder_acls.folder_id = doclibrary_folders.id'
		str_sql += ' AND ( ' + str_where + ' )'
		str_sql += ' GROUP BY doclibrary_folders.id'

		cnn = doclib_db_alias(Doclibrary::ViewAclFolder)
		items = cnn.find_by_sql(str_sql)
		folder_ids = items.map{|f| f.id}
		cnn.remove_connection
		
		item = doclib_db_alias(Doclibrary::Doc)
    item.find_by_sql(['SELECT section_code, COUNT(id) AS total_cnt FROM doclibrary_docs WHERE state = "public" AND category1_id IN (?) GROUP BY section_code', folder_ids])
  end
	
  Doclibrary::ViewAclDocCount.remove_connection
end
