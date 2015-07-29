# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
JoruriGw::Application.initialize!

#require 'pp'
#module Kernel
  private
  def pp(*objs)
    logger = Logger.new File.join(Rails.root, 'log', 'out.log')
    objs.each { |obj| logger.debug PP.pp(obj, '') }
    nil
  end
#  def pp_common(logfile, *objs)
#    logger = Logger.new File.join(RAILS_ROOT, 'log', logfile)
#    #logger.debug PP.pp(Time.now, '')
#    objs.each { |obj| logger.debug PP.pp(obj, '') }
#    nil
#  end
#  def pp_public_dispatch_log(*objs)
#    return unless PUBLIC_TRACE_LOG == 1
#    pp_common 'public_dispatch.log', {"time" => Time.now }, objs
#  end
#end

def nz(value, valueifnull='')
  value.blank? ? valueifnull : value
end
def nf(value, valueifnull='')
  # no-falsy, falsy: false, nil, '', 0, '0'
  value.blank? || value.to_s == '0' ? valueifnull : value
end

CalendarDateSelect.format = :db
