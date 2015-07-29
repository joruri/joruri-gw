class System::Session < ActiveRecord::Base
  self.table_name = 'sessions'

  def self.delete_past_sessions_at_random(rand_max = 10000)
    return unless rand(rand_max) == 0
    self.delete_expired_sessions
  end

  def self.delete_expired_sessions
    expiration = Joruri.config.application['sys.session_expiration']
    self.delete_all(["updated_at < ?", expiration.hours.ago])
  end

end
