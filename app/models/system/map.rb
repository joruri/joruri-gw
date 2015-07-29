# encoding: utf-8
class System::Map < ActiveRecord::Base
  include System::Model::Base

  def is_point(num)
    return false if self.send('point' + num.to_s + '_name').to_s ==''
    return false if self.send('point' + num.to_s + '_lat').to_s ==''
    return false if self.send('point' + num.to_s + '_lng').to_s ==''
    return true;
  end

  def get_point_params(num)
    return self.send('point' + num.to_s + '_lat') +
      ', ' + self.send('point' + num.to_s + '_lng') +
      ", '" + self.send('point' + num.to_s + '_name').gsub(/'/, "\\\\'") + "'"
  end
end
