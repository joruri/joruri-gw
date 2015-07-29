module Gwfaq::Model::Systemname

  def system_name
    return 'gwfaq'
  end

  def item_home_path
    return "/#{self.system_name}/"
  end

  def file_base_path
    return "/_attaches/#{self.system_name}"
  end

end