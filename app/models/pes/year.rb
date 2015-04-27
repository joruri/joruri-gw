class Pes::Year < Pes::Database
  include System::Model::Base
  include System::Model::Base::Content

  def reminder_cond
    self.and :state, 'public'
    self.and 'sql', '( (new_project_agency_state = \'public\' AND new_project_input_state = \'public\') or (project_agency_state = \'public\' AND project_input_state = \'public\') )'
    now = Time.now
    self.and :remind_st_at, '<=', now.strftime("%Y-%m-%d %H:%M:00")
    self.and :remind_ed_at, '>=', now.strftime("%Y-%m-%d %H:%M:00")
  end

  def show_remainder_title
    "<a href='#{get_remainder_url}'>#{title}政策評価シート入力期間です。</a>"
  end

  def get_remainder_url
    sso = "/_admin/gw/link_sso/redirect_to_joruri?to=gwsub&path=" 
    return "#{sso}/pes/#{id}/policies" if project_agency_state == 'public' && project_input_state == 'public'
    return "#{sso}/pes/#{id}/0/new_projects"
  end
end
