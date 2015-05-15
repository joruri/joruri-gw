class Gwworkflow::DocsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwworkflow"

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwworkflow::Control.find(params[:title_id])

    Page.title = "ワークフロー"
    @css = ["/_common/themes/gw/css/workflow.css"]
  end

  def url_options
    super.merge(params.slice(:cond, :filter, :sort, :order).symbolize_keys)
  end

  def index
    @items = Gwworkflow::Doc.search_with_params(params).index_order_with_params(params)
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:steps => :committees)

    @records = @items.map {|item| Gwworkflow::View::Doc.new(item) }

    _index @items
  end

  def show
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.showable?

    @files = @item.files
  end

  def new
    @remanded = false
    _new
  end

  def reapply
    item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless item.reapplyable?

    _new :prototype => item, :title => "再申請：#{item.title}", :quat_id => item.id
    @remanded = true
    render :new
  end

  def elaborate
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.elaboratable?

    @remanded = false
    render :new
  end

  def pullback
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.pullbackable?

    @item.pullback
    redirect_to url_for(action: :show, id: @item.id), notice: '引き戻しが完了しました。'
  end

  def create
    @item = Gwworkflow::Doc.find(params[:item][:id])
    return error_auth unless @item.state.to_sym == :quantum || @item.state.to_sym == :draft
    return error_auth unless @item.creater_id == Core.user.id

    @item.state = (params[:submit_type] == 'draft' ? :draft : :applying )
    @item.title = params[:item][:title]
    @item.body = params[:item][:body]
    @item.expired_at = params[:item][:expired_at]
    @item.updated_at = Time.now
    @item.applied_at = @item.state == :draft ? nil : DateTime.now
    @item.creater_id = Core.user.id
    @item.creater_name = Core.user.name
    @item.creater_gname = Core.user.group_name

    unless params[:item][:quat_id].blank?
      quot_item = Gwworkflow::Doc.find(params[:item][:quat_id])
      quot_item.destroy if quot_item
    end

    @item.steps.each(&:mark_for_destruction)
    (params[:committees]||[]).map(&:to_i).each_with_index do |uid, idx|
      if user = System::User.find_by(id: uid)
        step = @item.steps.build(number: idx)
        step.committees.build(
          state: 'undecided', 
          comment: '', 
          user_id: user.id,
          user_name: user.name,
          user_gname: user.group_name
        )
      end
    end

    _create @item do
      send_mail(@item) unless @item.state == :draft
    end
  end

  def approve
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.approvable?
    return error_auth unless @item.current_step
    @committee = @item.current_step.committees.detect {|c| c.user_id == Core.user.id }
    return http_error(404) unless @committee
    @files = @item.files
  end

  def commit
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.approvable?
    return error_auth unless @item.current_step
    @committee = @item.current_step.committees.detect {|c| c.user_id == Core.user.id }
    return http_error(404) unless @committee
    @files = @item.files

    @committee.decided_at = DateTime.now
    @committee.comment = params[:committee][:comment]
    @committee.state = case params[:submit_type]
      when 'accepted' then :accepted
      when 'remanded' then :remanded
      when 'rejected' then :rejected
      else :processing
      end

    @item.future_steps.each(&:mark_for_destruction)
    (params[:committees]||[]).map(&:to_i).each_with_index do |uid, idx|
      if user = System::User.find_by(id: uid)
        step = @item.steps.build(number: @item.current_number + idx + 1)
        step.committees.build(
          state: 'undecided',
          comment: '',
          user_id: user.id,
          user_name: user.name, 
          user_gname: user.group_name
        )
      end
    end

    _create @item do
      send_mail(@item)
    end
  end

  def destroy
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.destroyable?

    _destroy @item
  end

  def ajax_custom_route
    cr = Gwworkflow::CustomRoute.find(params[:custom_route_id])
    cr = cr.owner_uid == Core.user.id ? cr.steps.map{|s|s.committee} : []
    _show(cr.map{|s| [s.user_id, s.user_name_and_code]})
  end

  private

  def load_approvable_item
    
  end

  def _new(options = {})
    default_published = Integer(@title.default_published) rescue false
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
    @item.creater_id = Core.user.id
    @item.creater_name = Core.user.name
    @item.creater_gname = Core.user.group_name
    @item.expired_at = default_published.days.since.strftime("%Y-%m-%d %H:00") # さしあたって
    options[:after_prepare].call(@item) if options[:after_prepare]
    @quat_id = options[:quat_id] || nil
    @item.save(:validate => false)  # ファイル添付機能を使うため、この時点でDBへ保存
    raise "Joruri error. It can not save a new workflow." if @item.id == nil
  end

  def send_mail(item)
    mail = Gwworkflow::Model::Mail.new
    if item.state.to_sym == :applying
      case item.real_state
      when :accepted
        mail.send_notice_of_accepted(item, url_for(action: :show, id: item.id))
      when :rejected
        mail.send_notice_of_rejected(item, url_for(action: :show, id: item.id))
      when :applying
        mail.send_commission_request_to_next_committee(item, url_for(action: :approve, id: item.id))
      end
    end
  end
end
