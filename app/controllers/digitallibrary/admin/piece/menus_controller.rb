class Digitallibrary::Admin::Piece::MenusController < ApplicationController
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Digitallibrary::Model::DbnameAlias
  include Digitallibrary::Controller::AdmsInclude
  include Gwboard::Controller::Authorize

  def initialize_scaffold
    skip_layout
    @title = Digitallibrary::Control.find_by_id(params[:title_id])
    return error_gwbbs_no_title if @title.blank?
  end

  def index
    get_role_index

    folder_item = digitallib_db_alias(Digitallibrary::Folder)
    folder_item = folder_item.new
    folder_item.and :state,'!=' ,"preparation"
    folder_item.and 'sql', "parent_id IS NULL"
    @items = folder_item.find(:all, :order=>"level_no, display_order, sort_no, id")

    fid = params[:cat]
    set_folder_array(fid)
    @parent_group_code = parent_group_code
    Digitallibrary::Folder.remove_connection
  end

  def set_folder_array(param)
    @folders = []
    unless param.blank?
      fid = param.to_s
      folder = digitallib_db_alias(Digitallibrary::Folder)
      folder = folder.new
      folder.and :id, fid
      folder.and :state,'!=' ,"preparation"
      item = folder.find(:first, :order=>"level_no DESC, display_order DESC, sort_no DESC, id DESC")
      while item
        tree_state = true
        tree_state = false unless @is_writable
        tree_state = true if item.state == 'public'
        break unless tree_state
        @folders[item.level_no] = item.id
        item = item.parent
      end
    end
  end

end
