class Doclibrary::Admin::FoldersController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Doclibrary::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  layout "admin/template/doclibrary"

  def initialize_scaffold
    @title = Doclibrary::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    Page.title = @title.title

    params[:cat] = 1 if params[:cat].blank?
    folder_item = doclib_db_alias(Doclibrary::Folder)
    item = folder_item.new
    item.and  :title_id, params[:title_id]
    item.and  :id, params[:cat]
    @parent = item.find(:first)
    unless @parent
      item = folder_item.new
      item.and  :title_id, params[:title_id]
      @parent = item.find(:first,:order=>"id")
    end
    Doclibrary::Folder.remove_connection
    return http_error(404) unless @parent
    initialize_value_set
  end

  def show
    get_role_index
    return http_error(403) unless @is_readable

    item = doclib_db_alias(Doclibrary::Folder)
    item = item.new
    item.and  :title_id, params[:title_id]
    item.and :id, params[:id]
    Doclibrary::File.remove_connection
    @item = item.find(:first)
    return http_error(404) unless @item

    @readers = JsonParser.new.parse(@item.readers_json) unless @item.readers_json.blank?
    @reader_groups = JsonParser.new.parse(@item.reader_groups_json) unless @item.reader_groups_json.blank?

    _show @item
  end

  def index
    get_role_index
    return http_error(403) unless @is_readable

    item = doclib_db_alias(Doclibrary::Folder)
    item = item.new

    if @parent.id.blank?
      item.level_no = 1
    else
      item.parent_id = @parent.id
    end

    item.and  :title_id, params[:title_id]
    item.page  params[:page], params[:limit]
    @items = item.find(:all , :order=>"level_no, sort_no, id")
    Doclibrary::Folder.remove_connection
    _index @items
  end

  def edit
    get_role_new
    return http_error(403) unless @is_writable

    item = doclib_db_alias(Doclibrary::Folder)
    @item = item.new.find(params[:id])
    Doclibrary::Folder.remove_connection
    return error_auth unless @item
    @parent_state = 'public'
    @parent_state = @item.parent.state  if @item.parent

    parent_readers_json = @item.parent.readers_json if @item.parent
    @parent_readers = JsonParser.new.parse(parent_readers_json) unless parent_readers_json.blank?
    parent_reader_groups_json = @item.parent.reader_groups_json if @item.parent
    @parent_reader_groups = JsonParser.new.parse(parent_reader_groups_json) unless parent_reader_groups_json.blank?

    @parent_config = @parent_readers || @parent_reader_groups
    @parent_readers = '' if @parent_readers.blank?
    @parent_reader_groups = '' if @parent_reader_groups.blank?
    @parent_config = '' if @parent_config.blank?
  end

  def new
    get_role_new
    return http_error(403) unless @is_writable

    item = doclib_db_alias(Doclibrary::Folder)
    @item = item.new({
      :state      => @parent.state,
      :parent_id  => @parent.id,
      :title_id  => @title.id,
      :sort_no    => 0
    })
    unless @item.parent.blank?
      @item.state = @item.parent.state
      @item.readers = @item.parent.readers
      @item.readers_json = @item.parent.readers_json
      @item.reader_groups = @item.parent.reader_groups
      @item.reader_groups_json = @item.parent.reader_groups_json
    end
    Doclibrary::Folder.remove_connection
  end

  def create
    item = doclib_db_alias(Doclibrary::Folder)
    @item = item.new(params[:item])
    @item.title_id = @title.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1
    @item.children_size  = 0
    @item.total_children_size = 0

    @parent_state = @parent.state
    @item.state = @parent.state if @parent.state=='closed'

    parent_readers_json       = @item.parent.readers_json       if @item.parent
    @item.readers_json        = parent_readers_json             if (params[:item]['readers_json'].blank? and !parent_readers_json.blank?)
    parent_reader_groups_json = @item.parent.reader_groups_json if @item.parent
    @item.reader_groups_json  = parent_reader_groups_json       if (params[:item]['reader_groups_json'].blank? and !parent_reader_groups_json.blank?)

    @parent_config = @parent_readers || @parent_reader_groups
    @parent_readers = '' if @parent_readers.blank?
    @parent_reader_groups = '' if @parent_reader_groups.blank?
    @parent_config = '' if @parent_config.blank?

    str_params = doclibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}"
    str_params += "&state=CATEGORY"
    _create_plus_location @item, str_params
  end

  def update
    item = doclib_db_alias(Doclibrary::Folder)
    @item = item.new.find(params[:id])
    @item.attributes = params[:item]

    parent_readers_json       = @item.parent.readers_json       if @item.parent
    @item.readers_json        = parent_readers_json             if (params[:item]['readers_json'].blank? and !parent_readers_json.blank?)
    parent_reader_groups_json = @item.parent.reader_groups_json if @item.parent
    @item.reader_groups_json  = parent_reader_groups_json       if (params[:item]['reader_groups_json'].blank? and !parent_reader_groups_json.blank?)
    @parent_state = @parent.state

    @parent_config = @parent_readers || @parent_reader_groups
    @parent_readers = '' if @parent_readers.blank?
    @parent_reader_groups = '' if @parent_reader_groups.blank?
    @parent_config = '' if @parent_config.blank?

    if @item.state == 'closed'
      update_doc_and_child_state @item
#    else
#      update_doc_state @item
    end

    str_params = doclibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}"
    str_params += "&state=CATEGORY"
    _update_plus_location @item, str_params
  end

  def destroy
    item = doclib_db_alias(Doclibrary::Folder)
    @item = item.new.find(params[:id])

    str_params = doclibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}"
    str_params += "&state=CATEGORY"
    _destroy_plus_location @item, str_params
  end


  def lower_level_rewrite(items, state, readers, readers_json, reader_groups, reader_groups_json)
    if items.size > 0
      items.each do |item|
        level_item = doclib_db_alias(Doclibrary::Folder)
        level_item.update(item.id,:readers => readers, :readers_json => readers_json, :reader_groups => reader_groups, :reader_groups_json => reader_groups_json) if state =='public'
        level_item.update(item.id, :state =>'closed',:readers => readers, :readers_json => readers_json, :reader_groups => reader_groups, :reader_groups_json => reader_groups_json) if state =='closed'
        if item.children.size > 0
            lower_level_rewrite(item.children, state, readers, readers_json, reader_groups, reader_groups_json)
        end
      end
    end
  end


  def maintenance_acl
    item = doclib_db_alias(Doclibrary::Folder)
    item = item.new
    items = item.find(:all)
    items.each do |item|
      item.save_acl_records
    end
    Doclibrary::Folder.remove_connection
    redirect_to "/doclibrary/folders?title_id=#{@title.id}"
  end

  def update_doc_and_child_state(item)
    update_doc_state item
    child = doclib_db_alias(Doclibrary::Folder)
    child = child.new
    children = child.find(:all, :conditions => "doclibrary_folders.parent_id = #{item.id}") rescue nil
    return unless children

    children.each{|c|
      c.state = item.state
      c.save!
      update_doc_and_child_state c # call recursively
    }
  end

  def update_doc_state(item)
    doc = doclib_db_alias(Doclibrary::Doc)
    doc = doc.new
    docs = doc.find(:all, :conditions => "doclibrary_docs.category1_id = #{item.id} and state != 'preparation' and state IS NOT NULL") rescue nil

    if docs
      docs.each{|d|
        d.state = item.state == 'closed' ? 'draft' : item.state
        d.save!
      }
    end
  end
end
