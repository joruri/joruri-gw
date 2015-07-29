# encoding: utf-8
module System::Controller::Scaffold::Publication
  def publish(item)
    _publish(item)
  end

  def rebuild(item)
    _rebuild(item)
  end

  def close(item)
    _close(item)
  end

protected
  def _publish(item, options = {})
    respond_to do |format|
      if item.publishable? && item.publish
        options[:after_process].call if options[:after_process]
        location = url_for(:action => :index)

        flash[:notice] = options[:notice] || '公開処理が完了しました'
        #system_log.add(:item => item, :action => 'publish')
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash[:notice] = "公開できません"
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _rebuild(item, options = {})
    respond_to do |format|
      if item.rebuildable? && item.rebuild
        options[:after_process].call if options[:after_process]
        location = url_for(:action => :index)

        flash[:notice] = options[:notice] || '再構築処理が完了しました'
        #system_log.add(:item => item, :action => 'rebuild')
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash[:notice] = "再構築できません"
        format.html { render :action => :show } #url_for(:action => :show)
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _close(item, options = {})
    respond_to do |format|
      if item.closable? && item.close
        options[:after_process].call if options[:after_process]
        location = url_for(:action => :index)

        flash[:notice] = options[:notice] || '非公開処理が完了しました'
        #system_log.add(:item => item, :action => 'close')
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash[:notice] = "公開を終了できません"
        format.html { render :action => :show } #url_for(:action => :show)
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
end