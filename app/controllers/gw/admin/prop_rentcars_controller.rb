class Gw::Admin::PropRentcarsController < Gw::Admin::PropGenreCommonController
  def pre_dispatch
    super
    @genre = 'rentcar'
    @model = Gw::PropRentcar
    init_params
  end
end
