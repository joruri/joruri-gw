class Digitallibrary::Admin::FoldersController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Authorize
  include Gwboard::Controller::Common
  include Digitallibrary::Model::DbnameAlias

  layout "admin/template/digitallibrary"


  def initialize_scaffold
    @title = Digitallibrary::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    Page.title = @title.title
    return redirect_to("Site.current_node.public_uri?title_id=#{params[:title_id]}&limit=#{params[:limit]}&state=#{params[:state]}") if params[:reset]

    begin
      _search_condition
    rescue
      return http_error(404)
    end

    initialize_value_set_new_css_dl

  end

  def _search_condition
    params[:cat] = 1 if params[:cat].blank?
    item = digitallib_db_alias(Digitallibrary::Folder)
    @parent = item.find_by_id(params[:cat])
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable

    item = digitallib_db_alias(Digitallibrary::Folder)
    item = item.new

    unless params[:state] == 'DRAFT'
      if @parent.blank?
        item.level_no = 1
      else
        item.parent_id = @parent.id
      end
    end

    item.and :state, 'closed' if @is_writable if params[:state] == 'DRAFT'

    item.and :doc_type, 0
    item.and  :title_id, params[:title_id]
    item.page  params[:page], params[:limit]
    @items = item.find(:all , :order=>"level_no, sort_no, id")
    Digitallibrary::Folder.remove_connection
    _index @items
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    item = digitallib_db_alias(Digitallibrary::Folder)
    item = item.new
    item.and  :title_id, params[:title_id]
    item.and :id, params[:id]
    @item = item.find(:first)
    Digitallibrary::Folder.remove_connection
    return http_error(404) unless @item

    get_role_show(@item) unless @item.doc_type == 0

    _show @item
  end

  def new
    get_role_new
    return authentication_error(403) unless @is_writable

    title_id = params[:title_id]
    item = digitallib_db_alias(Digitallibrary::Folder)
    @item = item.new({
      :state      => 'public' ,
      :latest_updated_at => Time.now,
      :parent_id  => @parent.id ,
      :chg_parent_id => @parent.id ,
      :title_id  => title_id ,
      :doc_type  => 0 ,
      :level_no => @parent.level_no + 1,
      :section_code => Site.user_group.code,
      :sort_no    => 999999999 ,
      :order_no    => 999999999 ,
      :display_order => 100,  #
      :seq_no    => 999999999.0
    })

    set_tree_list_hash('new')
    set_position_hash(0)
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    item = digitallib_db_alias(Digitallibrary::Folder)
    @item = item.new.find(params[:id])
    return error_auth unless @item

    @item.section_code = nil if @item.section_code == ''
    @item.section_code = @item.section_code || Site.user_group.code

    set_tree_list_hash('edit')
    set_position_hash(0)
    Digitallibrary::Folder.remove_connection
  end

  def create
    get_role_new
    return authentication_error(403) unless @is_writable

    item = digitallib_db_alias(Digitallibrary::Folder)
    @item = item.new(params[:item])
    @item.latest_updated_at = Time.now
    @item.title_id = @title.id
    @item.parent_id = @item.chg_parent_id
    @item.sort_no = @item.seq_no
    @item.order_no = @item.seq_no
    @item.level_no = @parent.level_no + 1
    @item.doc_type = 0
    
    unless @item.save
      set_tree_list_hash('new')
      set_position_hash(0)
      return render :action => :new
    end

    item = digitallib_db_alias(Digitallibrary::Folder)
    p_item = item.find_by_id(@item.parent_id)

    level_no_rewrite(p_item, item)

    folders = item.new.find(:all, :conditions=>["parent_id = #{@item.parent_id}"], :order=>"level_no, sort_no, id")

    lower_level_no_rewrite(folders, item)

    sort_no_update
    Digitallibrary::Folder.remove_connection

    str_params = digitallibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}" unless @item.parent_id == 0 unless @item.parent_id.blank?
    redirect_to  str_params
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable

    item = digitallib_db_alias(Digitallibrary::Folder)
    @item = item.new.find(params[:id])
    return error_auth unless @item
    return error_auth unless @item.doc_type == 0

    _search_condition

    set_tree_list_hash('update')
    set_position_hash(0)

    @item.attributes = params[:item]
    @item.doc_type = 0

    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    @level_items = item.find(:all)

    unless @item.parent_id == @item.chg_parent_id
      @item.parent_id = @item.chg_parent_id
      @item.seq_no = 999999999.0
      @item.save
      item = digitallib_db_alias(Digitallibrary::Folder)
      @item = item.new.find(params[:id])

      level_no_rewrite(@item, item)

      folders = item.new.find(:all, :conditions=>["parent_id = #{@item.id}"], :order=>"level_no, sort_no, id")

      lower_level_no_rewrite(folders, item)
    end

    if params[:id].to_s == '1'
      @item.parent_id = @item.chg_parent_id
      @item.seq_no = 999999999.0
      @item.save
      item = digitallib_db_alias(Digitallibrary::Folder)
      @item = item.new.find(params[:id])

      level_no_rewrite(@item, item)

      folders = item.new.find(:all, :conditions=>["parent_id = #{@item.id}"], :order=>"level_no, sort_no, id")

      lower_level_no_rewrite(folders, item)
    end

    unless @item.order_no == @item.seq_no
      @item.parent_id == @item.chg_parent_id
      @item.save
      sort_no_update
    end
    Digitallibrary::Folder.remove_connection

    str_params = digitallibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}" unless @item.parent_id == 0 unless @item.parent_id.blank?
    _update_plus_location @item, "#{str_params}"
  end

  def destroy
    item = digitallib_db_alias(Digitallibrary::Folder)
    @item = item.new.find(params[:id])
    @item.destroy
    if @item.parent.level_no == 1
      sort_no_update
    else
      seq_name_update(@item.parent.id)
    end
    Digitallibrary::Folder.remove_connection

    str_params = digitallibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}" unless @item.parent_id == 0 unless @item.parent_id.blank?
    redirect_to  str_params
  end

end
