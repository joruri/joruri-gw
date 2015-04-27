class Digitallibrary::Admin::Piece::MenusController < ApplicationController
  include System::Controller::Scaffold
  layout false

  def index
    @title = Digitallibrary::Control.find(params[:title_id])

    @items = @title.folders.roots
    if params[:fld] == 'fop'
      @items = @items.includes(:public_children_for_tree => {:public_children_for_tree => :public_children_for_tree})
    else
      @items = @items.includes(:public_children_for_tree)
    end

    @folders = []
    if folder = @title.docs_and_folders.find_by(id: params[:cat])
      folder.self_and_ancestors.each do |ancestor|
        @folders[ancestor.level_no] = ancestor.id
      end
    end
  end
end
