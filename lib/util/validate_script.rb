module Util::ValidateScript

  def check_script(value)
    value.present? && value =~ /script/
  end

end