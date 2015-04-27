class Gw::Admin::PropMeetingroomsController < Gw::Admin::PropGenreCommonController
  def pre_dispatch
    super
    @genre = 'meetingroom'
    @model = Gw::PropMeetingroom
    init_params
  end
end
