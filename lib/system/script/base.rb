class System::Script::Base
  def self.run
    caller = caller_locations(1,1)[0].label
    start = Time.now
    puts "[#{start.strftime('%Y-%m-%d %H:%M:%S')}] #{self}.#{caller}: start"

    yield

    finish = Time.now
    past = sprintf('%.2f', finish - start)
    puts "[#{finish.strftime('%Y-%m-%d %H:%M:%S')}] #{self}.#{caller}: finished (#{past} sec)"

  rescue => e
    puts "ERROR #{e}"
    puts e.backtrace.join("\n")
  end

  def self.log(message)
    if block_given?
      puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{message}..."
      yield
      puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] 終了"
    else
      puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{message}"
    end
    self
  end

  def self.limit_date_for_preparation
    return @limit_date_for_preparation if @limit_date_for_preparation
    @limit_date_for_preparation = Time.now.ago(1.day)
  end
end
