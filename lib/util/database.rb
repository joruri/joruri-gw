class Util::Database
  def self.lock_by_name(name, timeout = 30, &block)
    begin
      ActiveRecord::Base.connection.execute("SELECT GET_LOCK('#{name}', #{timeout});")
      yield
    rescue => e
      error_log(e)
    ensure
      begin
        ActiveRecord::Base.connection.execute("SELECT RELEASE_LOCK('#{name}');")
      rescue => e
        error_log(e)
      end
    end
  end
end