module Cms::Controller::Common::Pagination
  def paginate(model, params = {}, params2 = {})
    options = {}
    options[:include] = params[:include]
    options = options.merge(params2)
    
    modify_options = Proc.new do
      sort = params[:sort] == 'desc' ? 'DESC' : 'ASC';
      options[:order] = params[:order] + ' ' + sort
    end
    
    paginate = Proc.new do
      params[:order] = 'id' unless params[:order]
      params[:sort]  = 'desc' unless params[:sort]
      modify_options.call
      options[:page]     = params[:page] ? params[:page] : 1
      options[:per_page] = params[:limit] ? params[:limit] : 20
      return model.paginate(options)
    end
    
    find_all = Proc.new do
      params[:order] = 'id' unless params[:order]
      params[:sort]  = '' unless params[:sort]
      modify_options.call
      return model.find(:all, options)
    end
    
    respond_to do |format|
      format.html { paginate.call }
      format.xml  { params[:page] ? paginate.call : find_all.call }
    end
  end
end