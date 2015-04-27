I18n.module_eval do
  class << self
    def translate_to_array_for_select(*args)
      t = translate(*args)
      if t.is_a?(Hash)
        t = t.stringify_keys if t.keys.first.is_a?(Symbol)
        t.invert.to_a
      else
        t
      end
    end
    alias :a :translate_to_array_for_select
  end
end
