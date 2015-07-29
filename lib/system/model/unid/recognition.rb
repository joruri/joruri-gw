# encoding: utf-8
module System::Model::Unid::Recognition
  def self.included(mod)
    mod.has_one :recognition, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'System::Recognition',
      :dependent => :destroy
    mod.has_many :recognizers, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'System::Recognizer',
      :dependent => :destroy

    mod.after_validation :validate_recognizers
    mod.after_save :save_recognition
    mod.after_save :save_recognizers
  end

  attr_accessor :_recognition
  attr_accessor :_recognizers

  def join_recognizers
    join "LEFT OUTER JOIN system_recognizers USING(unid)"
  end

  def recognizable
    join_recognizers
    self.and "system_recognizers.user_id", Core.user.id
    self.and "state", 'recognize'
    return self
  end

  def recognizable?(user = nil)
    return false unless state == 'recognize'
    return recognizers unless user
    return false unless recognizers
    recognizers.each do |_recognizer|
      return true if _recognizer.recognizable?(user)
    end
    return false
  end

  def recognize(user)
    _rs1 = false
    _rs2 = true
    recognizers(true).each do |rec|
      _rs1 = true  if rec.recognize(user)
      _rs2 = false unless rec.recognized?
    end

    if _rs2
      processed = false
      case recognition.after_process
      when 'publish'
        publish
        processed = true
      end if recognition

      unless processed
        self.state = 'recognized'
        sql = "UPDATE #{self.class.table_name} SET state = '#{state}' WHERE id = #{id}"
        self.class.connection.execute(sql)
        return true
      end
    end

    return _rs1
  end

  def validate_recognizers
    if state == 'recognize' && _recognizers
      valid = nil
      _recognizers.each do |k, v|
        valid = true if v.to_s != ''
      end
      errors.add "承認者", 'を選択してください' unless valid
    end
  end

  def save_recognition
    return true  unless _recognition
    return false unless unid
    return false if @save_recognition_callback_flag
    @save_recognition_callback_flag = true

    if recognition
      rec = recognition
    else
      rec = System::Recognition.new({:unid => unid})
    end

    rec.after_process = _recognition[:after_process]
    rec.save

    recognition(true)
    return true
  end

  def save_recognizers
    return true  unless _recognizers
    return false unless unid
    return false if @save_recognizer_callback_flag
    @save_recognizer_callback_flag = true

    _recognizers.each do |k, user_id|
      name  = k.to_s

      if user_id == ''
        recognizers.each do |rec|
          rec.destroy if rec.name == name
        end
      else
        recs = []
        recognizers.each do |rec|
          if rec.name == name
            recs << rec
          end
        end

        if recs.size > 1
          recs.each {|rec| rec.destroy}
          recs = []
        end

        if recs.size == 0
          rec = System::Recognizer.new({:unid => unid, :name => name, :user_id => user_id})
          rec.save
        else
          recs[0].user_id = user_id
          recs[0].recognized_at = nil
          recs[0].save
        end
      end
    end

    recognizers(true)
    return true
  end
end