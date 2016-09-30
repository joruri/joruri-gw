module Gw::MemosHelper

  def sanitize_for_memo(body)
    return "" if body.blank?
    sanitize(body, {tags: ['a','img','br']})
  end

end
