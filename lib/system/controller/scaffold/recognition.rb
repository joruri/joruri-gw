# encoding: utf-8
module System::Controller::Scaffold::Recognition
  def recognize(item)
    _recognize(item)
  end

protected
  def _recognize(item, options = {})
    respond_to do |format|
      if item.recognizable?(Core.user) && item.recognize(Core.user)
        options[:after_process].call if options[:after_process]
        location = url_for(:action => :index)

        flash[:notice] = options[:notice] || '承認処理が完了しました'
        #system_log.add(:item => item, :action => 'recognize')
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash[:notice] = "承認できません"
        format.html { render :action => :show } #url_for(:action => :show)
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
