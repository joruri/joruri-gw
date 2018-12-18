class Gwbbs::Admin::CommentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwbbs"

  def pre_dispatch
    @title = Gwbbs::Control.find(params[:title_id])
    return error_auth unless @title.is_readable?

    Page.title = @title.title
    initialize_value_set_new_css
  end

  def new
    @item = @title.docs.find(params[:p_id])
    @comment = @item.comments.build(
      title_id: @title.id,
      state: 'public',
      published_at: Core.now,
    )
 end

  def create
    @item = @title.docs.find(params[:p_id])
    @comment = @item.comments.build(comment_params)
    @comment.title_id = params[:title_id]
    @comment.parent_id = params[:p_id]
    @comment.latest_updated_at = Core.now
    @comment.body = '・' if @comment.body.blank?
    @comment.save

    flash[:notice] = 'コメントを登録しました。'
    redirect_to "/gwbbs/docs/#{params[:p_id]}?title_id=#{params[:title_id]}#{gwbbs_params_set}"
  end

  def edit
    @comment = Gwbbs::Comment.find(params[:id])
    @item = @comment.doc
    params[:p_id] = @comment.parent_id
  end

  def update
    @comment = Gwbbs::Comment.find(params[:id])
    @comment.attributes = comment_params
    @comment.title_id = params[:title_id]
    @comment.parent_id = params[:p_id]
    @comment.latest_updated_at = Core.now
    @comment.body = '・' if @comment.body.blank?
    @comment.save
    flash[:notice] = 'コメントを更新しました。'
    redirect_to "/gwbbs/docs/#{params[:p_id]}?title_id=#{params[:title_id]}#{gwbbs_params_set}"
  end

  def destroy
    @comment = Gwbbs::Comment.find(params[:id])
    _destroy @comment, success_redirect_uri: "/gwbbs/docs/#{@comment.parent_id}?title_id=#{@comment.title_id}#{gwbbs_params_set}", notice: 'コメントを削除しました。'
  end

private
  def comment_params
    params.require(:comment).permit(:body)
  end

end
