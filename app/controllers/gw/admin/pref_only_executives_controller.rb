class Gw::Admin::PrefOnlyExecutivesController < Gw::Admin::PrefExecutivesController
  layout 'admin/template/pref_only'

  def init_params
    super
    @u_role = false
    @sp_mode = :zaichou_assembly
    @css = %w(/_common/themes/gw/css/schedule_assembly.css)
  end
end
