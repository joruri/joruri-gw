module Gw::Model::Reminder

  class << self
    def model_class(model_class)
      case model_class
      when 'circular'
        Gw::Model::Circular
      when 'dcn_approval'
        Gw::Model::Dcn_approval
      when 'hcs_checkup_setting'
        Gw::Model::Hcs_checkup_setting
      when 'hcs_notification_base_benefit'
        Gw::Model::Hcs_notification_base_benefit
      when 'hcs_notification_base_deduction'
        Gw::Model::Hcs_notification_base_deduction
      when 'hcs_result_record'
        Gw::Model::Hcs_result_record
      when 'memo'
        Gw::Model::Memo
      when 'monitor'
        Gw::Model::Monitor
      when 'pes_year'
        Gw::Model::Pes_year
      when 'plus_update'
        Gw::Model::Plus_update
      when 'schedule_todo'
        Gw::Model::Schedule_todo
      when 'schedule'
        Gw::Model::Schedule
      when 'workflow'
        Gw::Model::Workflow
      else
        nil
      end
    end
  end

end
