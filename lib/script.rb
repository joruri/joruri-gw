class Script
  cattr_reader   :runner
  
  def self.run?
    rs = (@@runner == true)
    @@runner = nil
    rs
  end
  
  def self.run(path)
    @@runner = true
    begin
      app = ActionController::Integration::Session.new
      #app.get "/_script#{path}"
      app.get "/_script/sys/run/#{path}"
    end
    @@runner = nil
  end
  
end