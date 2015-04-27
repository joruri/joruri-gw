class Site
  def self.user
    debug_log "[DEPRECATED] Site.user called from #{caller[0]}"
    Core.user
  end

  def self.user_group
    debug_log "[DEPRECATED] Site.user_group called from #{caller[0]}"
    Core.user_group
  end

  def self.mode
    debug_log "[DEPRECATED] Site.mode called from #{caller[0]}"
    'admin'
  end

  def self.request_path
    debug_log "[DEPRECATED] Site.request_path called from #{caller[0]}"
    nil
  end

  def self.title
    site = YAML.load_file('config/site.yml')
    site['gw_information']['title']
  end

  def self.parent_user_groups
    debug_log "[DEPRECATED] Site.parent_user_groups called from #{caller[0]}"
    Core.user_group.self_and_ancestors
  end
end
