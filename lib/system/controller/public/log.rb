# encoding: utf-8
module System::Controller::Public::Log
  def system_log
    params = {}
    params[:user_id]    = Core.user.id
    params[:controller] = self.class.to_s
    return System::PublicLog.new(params)
  end
end