module Gwsub::Admin::Sb05::Sb05RequestsHelper

  def get_desired_dates(d_cond,s_select)
    Gwsub::Sb05DesiredDate.where(d_cond).select(s_select)
  end

end
