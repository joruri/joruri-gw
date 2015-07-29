module Gwworkflow::Model::Systemname
  def system_name
    return 'gwworkflow'
  end
  def file_base_path
    return "/_attaches/#{self.system_name}"
  end
end