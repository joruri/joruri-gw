# encoding: utf-8

class Sys::Script::RunnerController < ApplicationController
  def run
    return http_error(404) unless ::Script.run?
    Dir.chdir("#{Rails.root}")
    
    begin
      puts "#{Core.now} Start Script::Runner"
      path = params[:paths].join('/')
      res  = render_component_as_string :controller => File.dirname(path),
        :action => File.basename(path)
    rescue => e
      puts "Error: #{e}"
    end
    
    puts "#{Core.now} End Script::Runner"
    render :text => 'OK'
  end
end
