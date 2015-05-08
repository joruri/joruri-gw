module System::Controller::Scaffold

  def edit
    show
  end

protected

  def _index(items)
    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => to_xml(items) }
    end
  end

  def _show(item)
    return send(params[:do], item) if params[:do]

    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => to_xml(item) }
      format.json { render :text => item.to_json }
      format.yaml { render :text => item.to_yaml }
    end
  end

  def _create(item, options = {})
    processed = false
    if item.is_a?(Array) || item.is_a?(ActiveRecord::Relation)
      ActiveRecord::Base.transaction do
        processed = item.all?(&:creatable?) && item.all?(&:valid?) && item.all?(&:save)
      end
    else
      processed = item.creatable? && item.save
    end

    respond_to do |format|
      if processed
        yield if block_given?
        options[:after_process].call if options[:after_process]
        location = options[:success_redirect_uri].presence || url_for(:action => :index)
        format.html { redirect_to location, notice: options[:notice] || '登録処理が完了しました' }
        format.xml  { render :xml => to_xml(item), :status => status, :location => location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _update(item, options = {})
    processed = false
    if item.is_a?(Array) || item.is_a?(ActiveRecord::Relation)
      ActiveRecord::Base.transaction do
        processed = item.all?(&:editable?) && item.all?(&:valid?) && item.all?(&:save)
      end
    else
      processed = item.editable? && item.save
    end

    respond_to do |format|
      if processed
        yield if block_given?
        options[:after_process].call if options[:after_process]
        location = options[:success_redirect_uri].presence || url_for(:action => :index)
        format.html { redirect_to location, notice: options[:notice] || '更新処理が完了しました' }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _destroy(item, options = {})
    processed = false
    if item.is_a?(Array) || item.is_a?(ActiveRecord::Relation)
      ActiveRecord::Base.transaction do
        processed = item.all?(&:deletable?) && item.all?(&:destroy)
      end
    else
      processed = item.deletable? && item.destroy
    end

    respond_to do |format|
      if processed
        yield if block_given?
        options[:after_process].call if options[:after_process]
        location = options[:success_redirect_uri].presence || url_for(:action => :index)
        format.html { redirect_to location, notice: options[:notice] || '削除処理が完了しました' }
        format.xml  { head :ok }
      else
        flash.now[:notice] = '削除処理に失敗しました'
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _index_update(items, options = {})
    processed = false
    ActiveRecord::Base.transaction do
      processed = items.all?(&:editable?) && items.all?(&:valid?) && items.all?(&:save)
    end

    respond_to do |format|
      if processed
        yield if block_given?
        options[:after_process].call if options[:after_process]
        location = options[:success_redirect_uri].presence || url_for(:action => :index)
        format.html { redirect_to location, notice: options[:notice] || '更新処理が完了しました' }
        format.xml  { head :ok }
      else
        flash.now[:notice] = '更新処理に失敗しました'
        format.html { render :action => :index }
        format.xml  { render :xml => items.map(&:errors), :status => :unprocessable_entity }
      end
    end
  end
end
