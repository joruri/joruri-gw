# -*- encoding: utf-8 -*-

class Gwworkflow::Setting < Gw::Database
  set_table_name 'gw_workflow_mail_settings'
  
  def creatable?
    return true
  end

  def editable?
    return true
  end

end
