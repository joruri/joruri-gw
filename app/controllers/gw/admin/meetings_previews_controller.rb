class Gw::Admin::MeetingsPreviewsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/meeting_preview"

  def pre_dispatch
    Page.title = "会議等案内プレビュー"
    d = params['s_date']
    @st_date = d =~ /[0-9]{8}/ ? Date.strptime(d, '%Y%m%d') : Date.today
    @css = %w(/_common/themes/gw/css/meeting_preview.css)
  end

  def index
    cond_date = "'#{@st_date.strftime('%Y-%m-%d 0:0:0')}' <= st_at and '#{@st_date.strftime('%Y-%m-%d 23:59:59')}' >= st_at"

    @items = Gw::Schedule.where(cond_date).where(guide_state: 2)
      .order(allday: :desc, st_at: :asc, ed_at: :asc, id: :asc)
      .paginate(page: params[:page], per_page: 7)
  end
end
