module Concerns::Gw::Upload::TmpId
  extend ActiveSupport::Concern

  def set_tmp_id
    self.tmp_id ||= Digest::MD5.new.update(Time.now.to_s).to_s
  end

end
