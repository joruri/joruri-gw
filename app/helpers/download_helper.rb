module DownloadHelper

  def file_name_encode?(user_agent)
    #IE判定
    agents = Joruri.config.application['sys.file_encode_prefix']
    if agents.blank?
      chk = user_agent.index("MSIE")
      chk = user_agent.index("Trident") if chk.blank?
    else
      chk = false
      agent_list = agents.split(/,/)
      agent_list.each do |agent|
        chk = true if !user_agent.index(agent).blank?
      end
    end
    return false if chk.blank?
    return true
  end

  def chrome_browser(user_agent)
    chk = user_agent.index("Chrome")
    return false if chk.blank?
    return true
  end

  def firefox_browser(user_agent)
    chk = user_agent.index("Firefox")
    return false if chk.blank?
    return true
  end


end
