class Gwqa::Admin::Piece::MenusController < ApplicationController
  include System::Controller::Scaffold
  layout false

  def index
    @title = Gwqa::Control.find(params[:title_id])

    params[:state] = 'DATE' if params[:state].blank?

    @groups = Gwboard::Group.level3_all
    group_doc_counts
    category_doc_counts
    monthly_doc_counts
  end

  private

  def group_doc_counts
    @group_doc_counts = @title.docs.public_question_docs.select(:id).group(:section_code).count
  end

  def category_doc_counts
    @categories1 = @title.categories.select(:id, :name).where(level_no: 1).order(:sort_no, :id)
    @categories1 = @categories1.limit(@title.categoey_view_line) if @title.categoey_view_line > 0

    @category_doc_counts = @title.docs.public_question_docs.select(:id).group(:category1_id).count
  end

  def monthly_doc_counts
    @monthlies = @title.docs.public_question_docs
      .select("DATE_FORMAT(latest_updated_at,'%Y年%m月') AS month, DATE_FORMAT(latest_updated_at,'%Y') AS yy, DATE_FORMAT(latest_updated_at,'%m') AS mm, count(id) as cnt")
      .group("DATE_FORMAT(latest_updated_at,'%Y年%m月')")
      .order("DATE_FORMAT(latest_updated_at,'%Y年%m月') DESC")
    @monthlies = @monthlies.limit(@title.monthly_view_line) if @title.monthly_view_line > 0
  end
end
