class Util::File::Lock
  @locked = {}
  
  def self.lock_by_name(name)
    begin
      f = File.open("#{Rails.root}/tmp/lock_#{name}", 'w')
      begin
        f.flock(File::LOCK_EX)
        return @locked[name] = f
      rescue
        f.close
      end
    rescue
      return nil
    end
  end
  
  def self.unlock_by_name(name)
    begin
      f = @locked[name]
      begin
        f.flock(File::LOCK_UN)
      rescue
      ensure
        @locked.delete(name)
        f.close
      end
      file = "#{Rails.root}/tmp/lock_#{name}"
      File.unlink(file) if FileTest.exist?(file)
    rescue
    end
  end
end