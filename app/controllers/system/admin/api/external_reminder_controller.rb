class System::Admin::Api::ExternalReminderController < ActionController::Base
  protect_from_forgery :except => [:create_data, :delete_data]
  before_action :authenticate_user_password
  layout 'empty'

  def authenticate_user_password
    #dump "ExternalReminder: #{request.env['HTTP_X_WSSE']}"
    #dump params

    unless request.post?
      return render :text => message(400, "BadRequest"), :status => 400 
    end

    system = Gw::ReminderExternalSystem.where(:code => params[:system]).first

    unless system
      return render :text => message(400, "BadRequest"), :status => 400
    end

    if request.env['HTTP_X_WSSE'].blank?
      return render :text => message(401, "Unauthorized"), :status => 401
    end

    require 'wsse'
    wsse_header = WSSE::parse(request.env['HTTP_X_WSSE'])

    if wsse_header['name'] == system.user_id && WSSE::auth(request.env['HTTP_X_WSSE'], system.password)
      return true
    else
      return render :text => message(403, "Forbidden"), :status => 403
    end
  end

  def create_data
    attrs = {:data_id => params[:id]}
    [:system, :title, :updated, :link, :author, :contributor, :member].each do |key|
      attrs[key] = params[key]
    end

    item = Gw::ReminderExternal.new(attrs)

    if item.save
      return render :text => message(201, "Created"), :status => 201
    else
      return render :text => message(400, "BadRequest"), :status => 400
    end
  end

  def delete_data
    item = Gw::ReminderExternal.new
    item.and :system, params[:system]
    item.and :data_id, params[:id]
    item.and :member, params[:member]
    item.and :deleted_at, 'IS', nil
    item = item.find(:first)
    return render :text => message(400, "BadRequest"), :status => 400 unless item

    if item.update_attribute(:deleted_at, Time.now)
      return render :text => message(200, "OK"), :status => 200
    else
      return render :text => message(400, "BadRequest"), :status => 400
    end
  end

protected

  def message(code, message)
    "<status><code>#{code}</code><message>#{message}</message></status>"      
  end
end
