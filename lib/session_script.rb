class SessionScript

  def self.clear
    puts "#{Time.now.to_s(:db)} Start SessionScript.clear"
    begin
      System::Session.delete_expired_sessions
    rescue => e
      error_log(e.to_s)
      puts "Error: #{e}"
    end
    puts "#{Time.now.to_s(:db)} End SessionScript.clear"
  end

end