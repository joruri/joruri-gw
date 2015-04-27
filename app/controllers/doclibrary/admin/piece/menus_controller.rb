class Doclibrary::Admin::Piece::MenusController < ApplicationController
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout false

  def index
    @title = Doclibrary::Control.find(params[:title_id])
    params[:state] = @title.default_folder.to_s if params[:state].blank?

    case params[:state]
    when 'GROUP'
      @grp_items = Gwboard::Group.level3_all

      items = @title.docs.public_docs.distinct(:id).group(:section_code)
      items = items.in_readable_folder(Core.user) unless @title.is_admin?
      @group_doc_counts = items.count
    when 'DATE', 'DRAFT', 'RECOGNIZE', 'PUBLISH'
      # nothing
    else
      @items = @title.folders.roots

      @folders = []
      if folder = @title.folders.find_by(id: params[:cat])
        folder.self_and_ancestors.each do |ancestor|
          @folders[ancestor.level_no] = ancestor.id if ancestor.state == 'public'
        end
      end
    end
  end
end
