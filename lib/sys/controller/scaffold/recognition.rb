# encoding: utf-8
module Sys::Controller::Scaffold::Recognition
  def recognize(item)
    _recognize(item)
  end
  
protected
  def _recognize(item, options = {}, &block)
    if item.recognizable?(Core.user) && item.recognize(Core.user)
      flash[:notice] = options[:notice] || '承認処理が完了しました。'
      yield if block_given?
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
        format.xml  { head :ok }
      end
    else
      flash.now[:notice] = "承認処理に失敗しました。"
      respond_to do |format|
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
