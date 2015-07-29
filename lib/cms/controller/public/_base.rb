module Cms::Public::Base
  def before_dispatch 
    super
    @id = params[:id]
    @do = params[:do]
    @in = params[:in] ? params[:in] : {}
    @sv = params[:s]  ? params[:s]  : {}
    @sv = {:reset => true} if @sv[:reset]
  end
end