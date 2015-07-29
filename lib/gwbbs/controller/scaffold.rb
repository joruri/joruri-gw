# -*- encoding: utf-8 -*-
module Gwbbs::Controller::Scaffold
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
    respond_to do |format|
      if item.creatable? && item.save
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'create')

        location = item.item_path
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
    respond_to do |format|
      if item.editable? && item.save
        options[:after_process].call if options[:after_process]
        system_log.add(:item => item, :action => 'update')

        send_recognition_mail(item) if defined?(item.recognizable?) && item.recognizable?

        flash[:notice] = '更新処理が完了しました'
        format.html { redirect_to item.item_path }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def send_recognition_mail(item)
    mail_fr = 'admin@127.0.0.1'
    subject = '【' + Core.title + '】 承認依頼'
    message = '下記URLから承認処理をお願いします。' + "\n\n" +
      url_for(:action => :show)

    item.recognizers.each do |_recognizer|
      mail_to = _recognizer.user.email
      mailer = Cms::Lib::Mail::Smtp.deliver_recognition(mail_fr, mail_to, subject, message)
    end
  end

  def _destroy(item, options = {})
    respond_to do |format|
      if item.deletable? && item.destroy
        options[:after_process].call if options[:after_process]
        system_log.add(:item => item, :action => 'destroy')

        flash[:notice] = options[:notice] || '削除処理が完了しました'
        format.html { redirect_to item.item_path }
        format.xml  { head :ok }
      else
        flash[:notice] = '削除できません'
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

end