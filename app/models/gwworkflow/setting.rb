class Gwworkflow::Setting < Gw::Database
  self.table_name = 'gw_workflow_mail_settings'

  def creatable?
    return true
  end

  def editable?
    return true
  end

end
