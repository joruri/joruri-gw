class Gwbbs::Admin::Piece::MenusController < ApplicationController
  include System::Controller::Scaffold
  layout false

  def index
    @title = Gwbbs::Control.find(params[:title_id])

    params[:state] = 'DATE' if params[:state].blank?

    if @title.form_name == 'form006' || @title.form_name == 'form007'
      @groups = @title.notes_field01
      group_doc_counts_form006_and_form007
      category_doc_counts
      if @title.form_name == 'form006'
        monthly_doc_counts_form006
      else
        monthly_doc_counts
      end
    else
      @groups = Gwboard::Group.level3_all
      group_doc_counts
      category_doc_counts
      monthly_doc_counts
    end
  end

  private

  def group_doc_counts
    @group_doc_counts = @title.docs.public_docs.select(:id).group(:section_code).count
  end

  def category_doc_counts
    @categories1 = @title.categories.select(:id, :name).where(level_no: 1).order(:sort_no, :id)
    @categories1 = @categories1.limit(@title.categoey_view_line) if @title.categoey_view_line > 0

    @category_doc_counts = @title.docs.public_docs.select(:id).group(:category1_id).count
  end

  def monthly_doc_counts
    @monthlies = @title.docs.public_docs
      .select("DATE_FORMAT(latest_updated_at,'%Y年%m月') AS month, DATE_FORMAT(latest_updated_at,'%Y') AS yy, DATE_FORMAT(latest_updated_at,'%m') AS mm, count(id) as cnt")
      .group("DATE_FORMAT(latest_updated_at,'%Y年%m月')")
      .order("DATE_FORMAT(latest_updated_at,'%Y年%m月') DESC")
    @monthlies = @monthlies.limit(@title.monthly_view_line) if @title.monthly_view_line > 0
  end

  def group_doc_counts_form006_and_form007
    @grp_items = @title.docs.public_docs
      .select("inpfld_002, count(id) as cnt")
      .group(:inpfld_002)
      .order(:inpfld_002)
  end

  def monthly_doc_counts_form006
    @monthlies = @title.docs.public_docs
      .select("inpfld_006w, count(id) as cnt")
      .group(:inpfld_006w)
      .order("DATE_FORMAT(inpfld_006d,'%Y年%m月') DESC")
    @monthlies = @monthlies.limit(@title.monthly_view_line) if @title.monthly_view_line > 0
  end
end
