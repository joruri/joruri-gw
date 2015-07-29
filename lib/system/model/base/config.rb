# encoding: utf-8
module System::Model::Base::Config
  def states
    {'disabled' => '無効', 'enabled' => '有効'}
  end

  def readable
    self.and "'readable'", 'readable'
    return self
  end

  def editable
    self.and "'editable'", 'editable'
    return self
  end

  def deletable
    self.and "'destroyable'", 'destroyable'
    return self
  end

  def enabled
    self.and "state", 'enabled'
    return self
  end

  def disabled
    self.and "state", 'disabled'
    return self
  end

  def readable?
    return true
  end

  def creatable?
    return true
  end

  def editable?
    return true
  end

  def deletable?
    return true
  end

  def enabled?
    return state == 'enabled'
  end

  def disabled?
    return state == 'disabled'
  end
end