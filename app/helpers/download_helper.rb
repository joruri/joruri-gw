module DownloadHelper

  def file_name_encode?(user_agent = request.user_agent)
    ie_browser?(user_agent)
  end

  def ie_browser?(user_agent = request.user_agent)
    agents = Joruri.config.application['sys.file_encode_prefix']
    if agents.present?
      agents.split(/,/).any? {|ua| user_agent.include?(ua) }
    else
      user_agent.include?("MSIE") || user_agent.include?("Trident")
    end
  end

  def chrome_browser?(user_agent = request.user_agent)
    user_agent.include?("Chrome")
  end

  def firefox_browser?(user_agent = request.user_agent)
    user_agent.include?("Firefox")
  end
end
