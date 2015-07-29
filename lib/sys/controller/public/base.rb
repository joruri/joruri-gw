class Sys::Controller::Public::Base < ApplicationController
  before_filter :pre_dispatch
  
  def pre_dispatch
    ## each processes before dispatch
  end
end
