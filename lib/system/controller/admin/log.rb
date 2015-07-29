# encoding: utf-8
module System::Controller::Admin::Log
  def system_log
    params = {}
    params[:user_id]    = Core.user.id
    params[:controller] = self.class.to_s
    return System::AdminLog.new(params)
  end
end