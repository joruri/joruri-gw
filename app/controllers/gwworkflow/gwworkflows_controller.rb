# encoding:utf-8
class Gwworkflow::GwworkflowsController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwworkflow::Model::DbnameAlias
  include Gwworkflow::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  layout "admin/template/gwworkflow"

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwworkflow::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    Page.title = "ワークフロー"
    @css = ["/_common/themes/gw/css/workflow.css"]
    @js = %w(/_common/js/yui/build/animation/animation-min.js /_common/js/popup_calendar/popup_calendar.js /_common/js/yui/build/calendar/calendar.js /_common/js/dateformat.js)
  end
  
  def jgw_workflow_path
    return gwworkflow_menus_path
  end

  def index
    # アイテムの取得
    committed = ->{Gwworkflow::Doc.find_by_conditions :type => :committed,  :filter => params[:filter]}
    processing= ->{Gwworkflow::Doc.find_by_conditions :type => :processing, :filter => params[:filter]}
    accepted  = ->{Gwworkflow::Doc.find_by_conditions :type => :accepted,   :filter => params[:filter]}
    items = case params[:cond]
    when 'commited' then committed.call
    when 'processing'  then processing.call
    when 'accepted' then accepted.call
    else params[:cond]=''; committed.call
    end
    # View用のモデルを生成
    @records = items.map{|item|
      Gw::Model::Workflow::Viewmodel::DocRecord.new(
        :id => item[:id], :title => item[:title], :state => item.real_state, :progress => {:den => item.total_steps, :num => item.now_step},
        :updated_at => item[:updated_at], :created_at => item[:created_at],
        :expired_at => item[:expired_at], :applied_at => item[:applied_at])
    }
    @order = params[:order].blank? ? :desc : params[:order].to_sym
    @sort = params[:sort].blank? ? :applied_at : params[:sort].to_sym
    @filter = params[:filter].blank? ? :all : params[:filter].to_sym
    case @sort
    when :applied_at
      @records = @records.sort_by{|a| a.applied_at ? a.applied_at : DateTime.now }
    when :expired_at
      @records = @records.sort_by{|a| a.expired_at ? a.expired_at : DateTime.now }
    when :updated_at
      @records = @records.sort_by{|a| a.updated_at ? a.updated_at : DateTime.now }
    end
    @records = @records.reverse if @order == :desc

    Page.title = @title.title
  end

  def _new options={}
    default_published = is_integer(@title.default_published)
    default_published = 14 unless default_published
    
    @item = Gwworkflow::Doc.new
    @item.state = :quantum # 状態が安定していないという意味です
    prototype = options[:prototype] || nil
    unless prototype
      @item.title = ''
      @item.body = ''
    else
      title = options[:title] || prototype.title
      @item.title = title
      @item.body = prototype.body
      prototype.steps.each.with_index{|ps,i|
        step = @item.steps.build :number => i
        ps.committees.each{|cm|
          step.committees.build :state => :undecided, :comment => '',
            :user_id => cm.user_id, :user_name => cm.user_name, :user_gname => cm.user_gname
        }
      }
    end
    @item.creater_id = Site.user.id
    @item.creater_name = Site.user.name
    @item.creater_gname = Site.user.group_name
    @item.expired_at = default_published.days.since.strftime("%Y-%m-%d %H:00") # さしあたって
    options[:after_prepare].call(@item) if options[:after_prepare]
    @quat_id = options[:quat_id] || nil
    @item.save(:validate => false)  # ファイル添付機能を使うため、この時点でDBへ保存
    raise "Joruri error. It can not save a new workflow." if @item.id == nil
  end

  def new
    @undeletable = true
    @remanded = false
    _new 
  end

  def reapply
    item = Gwworkflow::Doc.find(params[:id].to_i)
    return http_error(404) unless item
    return authentication_error(403) unless item.real_state== :remanded
    return authentication_error(403) unless item.creater_id.to_i == Site.user.id
    
    _new :prototype => item, :title => "再申請：#{item.title}", :quat_id => item.id
    @undeletable = true
    @remanded = true
    render :new
  end
  
  def elaborate
    @item = Gwworkflow::Doc.find(params[:id].to_i)
    return http_error(404) unless @item
    return authentication_error(403) unless @item.state.to_sym == :draft
    return authentication_error(403) unless @item.creater_id.to_i == Site.user.id
    @undeletable = false
    @remanded = false
    render :new
  end
  
  def send_mail(item)
    x = Gwworkflow::Model::Mail.new
    if item.state.to_sym == :applying
      case item.real_state
      when :accepted
        x.send_notice_of_accepted(item, url_for(:action => :show))
      when :rejected
        x.send_notice_of_rejected(item, url_for(:action => :show))
      when :applying
        x.send_commission_request_to_next_committee(item, url_for(:action => :approve, :id => item.id))
      end
    end
  end

  def create
    @item = Gwworkflow::Doc.find(params[:item][:id])
    return http_error(404) unless @item
    return authentication_error(403) unless @item.state.to_sym == :quantum || @item.state.to_sym == :draft
    return authentication_error(403) unless @item.creater_id.to_i == Site.user.id
    @item.state = (params[:submit_type] == 'draft' ? :draft : :applying )
    @item.title = params[:item][:title]
    @item.body = params[:item][:body]
    @item.expired_at = params[:item][:expired_at]
    @item.updated_at = DateTime.now
    @item.applied_at = @item.state == :draft ? nil : DateTime.now
    
    unless params[:item][:quat_id].blank?
      quot_item = Gwworkflow::Doc.find(params[:item][:quat_id])
      quot_item.destroy if quot_item
    end
    @item.steps.each{|s|s.destroy}
    @item.steps = []
    (params[:committees]||[]).map{|s|s.to_i}.map{|id|
      user = System::User.find(id); [ id, user.name, user.group_name ]
    }.each.with_index{|(id,name,gname),idx|
      step = @item.steps.build :number => idx
      step.committees.build :state => :undecided, :comment => '', :user_id => id, :user_name => name, :user_gname => gname
    }
    @item.creater_id = Site.user.id
    @item.creater_name = Site.user.name
    @item.creater_gname = Site.user.group_name
    
    _create(@item, :success_redirect_uri => {:action => :index}, :ignore_validate => false, :after_process_with_item => ->(item){ send_mail(item) unless @item.state == :draft })
  end

  def showable? item
    item.creater_id.to_i == Site.user.id || item.steps.any?{|step| step.committee.user_id == Site.user.id }
  end

  def show
    @item = Gwworkflow::Doc.find(params[:id].to_i)
    return http_error(404) unless @item
    return authentication_error(403) if @item.state.to_sym == :draft
    return authentication_error(403) unless showable? @item
    @files = Gwworkflow::File.where(:parent_id => @item.id)
  end

  def approve
    @item = Gwworkflow::Doc.find(params[:id].to_i)
    return http_error(404) unless @item
    return authentication_error(403) if @item.state.to_sym == :draft
    return authentication_error(403) unless @item.current_step && @item.current_step.committee.user_id == Site.user.id
    @committee = Gwworkflow::Committee.find_by_conditions :user_id => Site.user.id, :step_id => @item.current_step.id
    return http_error(404) unless @committee
    @files = Gwworkflow::File.where(:parent_id => @item.id)
  end


  def commit
    @item = Gwworkflow::Doc.find(params[:id].to_i)
    return http_error(404) unless @item
    return authentication_error(403) if @item.state.to_sym == :draft
    return authentication_error(403) unless @item.current_step
    return authentication_error(403) unless @item.current_step.committee.user_id == Site.user.id
    @committee = Gwworkflow::Committee.find_by_conditions :user_id => Site.user.id, :step_id => @item.current_step.id
    return http_error(404) unless @committee
    
    @committee.decided_at = DateTime.now
    @committee.comment = params[:committee][:comment]
    @committee.state = case params[:submit_type]
      when 'accepted' then :accepted
      when 'remanded' then :remanded
      when 'rejected' then :rejected
      else :processing
      end

    current_number = @item.now_step
    @item.future_steps.each{|s|s.destroy}
    (params[:committees]||[]).map{|s|s.to_i}.map{|id|
      user = System::User.find(id); [ id, user.name, user.group_name ]
    }.each.with_index{|(id,name,gname),idx|
      step = @item.steps.build :number => idx + current_number + 1
      step.committees.build :state => :undecided, :comment => '', :user_id => id, :user_name => name, :user_gname => gname
    }
    @committee.save
    _create(@item, :success_redirect_uri => {:action => :index}, :after_process_with_item => ->(item){ send_mail(item) })
  end

  def destroy
    @item = Gwworkflow::Doc.find(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless @item.real_state.to_sym == :quantum || @item.real_state.to_sym == :draft || @item.real_state.to_sym == :accepted || @item.real_state.to_sym == :rejected || @item.real_state.to_sym == :remanded
    return authentication_error(403) unless @item.creater_id.to_i == Site.user.id
    Gwworkflow::File.where(:parent_id => @item.id).each{|f| f.destroy }
    @item.destroy
    redirect_to :action => :index
  end
  
  def ajax_custom_route
    cr = Gwworkflow::CustomRoute.find(params[:custom_route_id])
    cr = cr.owner_uid == Site.user.id ? cr.sorted_steps.map{|s|s.committee} : []
    _show(cr.map{|s| [s.user_id, s.user_name_and_code]})
  end

end
