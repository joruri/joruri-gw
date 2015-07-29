# -*- encoding: utf-8 -*-
module Gwboard::Model::Recognition
  def self.included(mod)
    mod.after_validation :validate_recognizers
  end

  attr_accessor :_recognition
  attr_accessor :_recognizers

  def validate_recognizers
    if state == 'recognize' && _recognizers
      valid = nil
      _recognizers.each do |k, v|
        valid = true if v.to_s != ''
      end
      errors.add "承認者", 'を選択してください' unless valid
    end
  end
  
end