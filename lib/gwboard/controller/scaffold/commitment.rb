# -*- encoding: utf-8 -*-
module Gwboard::Controller::Scaffold::Commitment
  def rollback(item)
    _rollback(item)
  end

protected
  def _rollback(item, options = {})
    conditions = {:unid => item.unid, :version => params[:version], :name => 'attributes'}
    com = System::Commitment.find(:first, :conditions => conditions)

    respond_to do |format|
      if item.editable? && com.rollback(item)
        options[:after_process].call if options[:after_process]

        location = item.item_path

        status = params[:_created_status] || :created

        flash[:notice] = options[:notice] || 'ロールバック処理が完了しました'
        #system_log.add(:item => item, :action => 'rollback')
        format.html { redirect_to location }
        format.xml  { render :xml => to_xml(item), :status => status, :location => location }
      else
        format.html { render :action => :show }
        format.xml  { render :xml => com.errors, :status => :unprocessable_entity }
      end
    end
  end

  ############### old
  def _commitment_attributes(item)
    c = System::Commitment.find(params[:cid])

    self.class.layout 'empty'
    respond_to do |format|
      format.html {
        html = ''
        c.attributes_to_hash.each{|k, v| html += "#{k.to_s} : #{v.to_s}<hr />"}
        render :text => html
      }
      format.xml  { render :xml => c.attributes_to_hash }
    end
  end

  def _commitment_page(item)
    c = System::Commitment.find(params[:cid])

    self.class.layout 'empty'
    return render(:text => c.page_data)
  end

  def _commitment_rollback(item)
    c = System::Commitment.find(params[:cid])

    c.attributes_to_hash.each do |k, v|
      next if k.to_s == 'id'
      next if k.to_s =~ /\_at/
      eval("item.#{k.to_s} = v")
    end
    item.state = 'draft'
    _update(item)
  end
end