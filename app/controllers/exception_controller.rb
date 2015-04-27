class ExceptionController < ApplicationController
  def index
    http_error 404
  end
end
