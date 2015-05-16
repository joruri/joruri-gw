class Gwworkflow::Admin::DocsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwworkflow"

  def pre_dispatch
    @title = Gwworkflow::Control.find(1)

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
  end

  def new
    @item = Gwworkflow::Doc.new(
      state: :quantum,
      expired_at: @title.default_published.to_i.days.since.strftime("%Y-%m-%d %H:00"),
      creater_id: Core.user.id,
      creater_name: Core.user.name,
      creater_gname: Core.user.group_name,
      current_number: -1
    )
    @item.save(validate: false)
  end

  def reapply
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.reapplyable?

    @item.title = @item.title.gsub(/^(再申請：){0,1}/, '再申請：')
    @item.current_number = -1

    render :new
  end

  def elaborate
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.elaboratable?

    render :new
  end

  def pullback
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.pullbackable?

    @item.pullback
    redirect_to url_for(action: :show, id: @item.id), notice: '引き戻しが完了しました。'
  end

  def create
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.reapplyable? || @item.elaboratable?

    @item.attributes = params[:item]
    @item.state = (params[:draft] ? :draft : :applying)
    @item.applied_at = @item.state == :draft ? nil : Time.now
    @item.creater_id = Core.user.id
    @item.creater_name = Core.user.name
    @item.creater_gname = Core.user.group_name

    @item.rebuild_steps_and_committees(params[:committees])

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
  end

  def commit
    @item = Gwworkflow::Doc.find(params[:id])
    return error_auth unless @item.approvable?
    return error_auth unless @item.current_step

    @committee = @item.current_step.committees.detect {|c| c.user_id == Core.user.id }
    return http_error(404) unless @committee

    @committee.attributes = params[:committee]
    @committee.decided_at = Time.now
    @committee.state = case
      when params[:accepted] then :accepted
      when params[:remanded] then :remanded
      when params[:rejected] then :rejected
      else :processing
      end

    @item.rebuild_future_steps_and_committees(params[:committees])

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
