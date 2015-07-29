# -*- encoding: utf-8 -*-
module Gwboard::Controller::Scaffold
  def self.included(mod)
    mod.before_filter :initialize_scaffold
  end

  def initialize_scaffold

  end

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
    ignore_validate = options[:ignore_validate] || false
    failured_action = options[:failured_action] || nil
    respond_to do |format|
      if item.creatable? && item.save(:validate => (!ignore_validate))
        options[:after_process].call if options[:after_process]
        if options[:after_process_with_item]
          item.reload
          options[:after_process_with_item].call(item)
        end
        #system_log.add(:item => item, :action => 'create')
        location = options[:success_redirect_uri] ||= url_for(:action => :index)
        #location = item.item_path
        location = item.adm_show_path if options[:success_redirect_uri] == 'makers_show'
        status = params[:_created_status] || :created
        flash[:notice] = options[:notice] || '登録処理が完了しました'
        format.html { redirect_to location }
        format.xml  { render :xml => to_xml(item), :status => status, :location => location }
      else
        format.html { render :action => failured_action || "new" }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _create_doclib(item, options = {})
    respond_to do |format|
      if item.creatable? && item.save
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'create')
        location = options[:success_redirect_uri] ||= url_for(:action => :index)
        item.set_category_folder_root if options[:system_name] == 'digitallibrary'
        status = params[:_created_status] || :created
        flash[:notice] = options[:notice] || '登録処理が完了しました'
        format.html { redirect_to location }
        format.xml  { render :xml => to_xml(item), :status => status, :location => location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _create_plus_location(item, s_location,  options = {})
    respond_to do |format|
      if item.creatable? && item.save
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'create')
        location = s_location
        status = params[:_created_status] || :created
        flash[:notice] = options[:notice] || '登録処理が完了しました'
        format.html { redirect_to location }
        format.xml  { render :xml => to_xml(item), :status => status, :location => location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _create_after_set_location(item,  options = {})
    respond_to do |format|
      if item.creatable? && item.save
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'create')

        if item.state == 'recognized'
          location = item.gwqa_preview_path
        else
          location = item.gwqa_preview_index_path
        end

        status = params[:_created_status] || :created
        flash[:notice] = options[:notice] || '登録処理が完了しました'
        format.html { redirect_to location }
        format.xml  { render :xml => to_xml(item), :status => status, :location => location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _update(item, options = {})
    failured_action = options[:failured_action] || nil
    respond_to do |format|
      if item.editable? && item.save
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'update')
        flash[:notice] = options[:notice] || '更新処理が完了しました'
        location = options[:success_redirect_uri] ||= url_for(:action => :index)
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        format.html { render :action => failured_action || :edit }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _update_doclib(item, options = {})
    respond_to do |format|
      if item.editable? && item.save
        options[:after_process].call if options[:after_process]
        item.set_category_folder_root
        #system_log.add(:item => item, :action => 'update')
        flash[:notice] = options[:notice] || '更新処理が完了しました'
        location = options[:success_redirect_uri] ||= url_for(:action => :index)
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _update_plus_location(item, s_location, options = {})
    respond_to do |format|
      if item.editable? && item.save
        options[:after_process].call if options[:after_process]
        item.send_reminder unless options[:digitallibrary].blank?
        #system_log.add(:item => item, :action => 'update')
        flash[:notice] = options[:notice] || '更新処理が完了しました'
        format.html { redirect_to s_location }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _update_after_save_recognizers(item, recog_item, s_location, options = {})
    respond_to do |format|
      if item.editable? && item.save
        options[:after_process].call if options[:after_process]
        destroy_recognizers(recog_item)
        save_recognizers(item, recog_item) if is_possible_recognize(item)
        item.send_reminder unless options[:digitallibrary].blank?
        #system_log.add(:item => item, :action => 'update')
        flash[:notice] = options[:notice] || '更新処理が完了しました'
        format.html { redirect_to s_location }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy_recognizers(recog_item)
    sql = Condition.new
    sql.and "parent_id", @item.id
    sql.and "title_id", @item.title_id
    sql.where
    recog_item.destroy_all(sql.where)
  end

  def is_possible_recognize(item)
    valid = nil
    if @title.recognize == 1 && item._recognizers
      item._recognizers.each do |k, v|
        valid = true if v.to_s != ''
      end
    end

    if @title.recognize == 2 && @item.category4_id == 1 && item._recognizers
      item._recognizers.each do |k, v|
        valid = true if v.to_s != ''
      end
    end
    return valid
  end

  def save_recognizers(item, recog_item)
    item._recognizers.each do |k, v|
      unless v.to_s == ''
        user = get_user(v.to_s)
        if user
          recog_item.create(
            :title_id => params[:title_id],
            :parent_id => params[:id],
            :user_id => v.to_s,
            :code => user.code,
            :name => %Q[#{user.name}(#{user.code})]
          )
        end
      end
    end
  end

  def get_user(uid)
    ret = nil
    item = System::User.find(uid)
    ret = item if item
    return ret
  end


  def _destroy(item, options = {})
    respond_to do |format|
      if item.deletable? && item.destroy
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'destroy')

        flash[:notice] = options[:notice] || '削除処理が完了しました'
        location = options[:success_redirect_uri] ||= url_for(:action => :index)
        format.html { redirect_to location}
        format.xml  { head :ok }
      else
        flash[:notice] = '削除できません'
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _destroy_plus_location(item, s_location, options = {})
    respond_to do |format|
      if item.deletable? && item.destroy
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'destroy')

        flash[:notice] = options[:notice] || '削除処理が完了しました'
        format.html { redirect_to s_location }
        format.xml  { head :ok }
      else
        flash[:notice] = '削除できません'
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _error_msg(message)
    return respond_to do |format|
      format.html { render :text => "<div id='gwErrorMessage'>#{message}</div>" }
      format.xml  { render :xml => '<errors><error>#{message}</error></errors>' }
    end
  end

  def error_gwbbs_no_title
    error 'タイトルが指定されていないか、公開されている情報ではありません。'
  end

  def error_gwbbs_no_database
    error '設定されているデータベースが存在しません'
  end

  def error_gwbbs_no_folder
    error 'フォルダ情報が存在しません'
  end

end