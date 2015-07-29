# encoding: utf-8
module System::Model::Unid::Creator
  def self.included(mod)
    mod.has_one :creator, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'System::Creator',
      :dependent => :destroy

    mod.after_save :save_creator
  end

  def join_creator
    join "LEFT OUTER JOIN system_creators USING(unid)"
  end

  def save_creator
    return true if creator
    return false unless unid

    _creator = System::Creator.new({:unid => unid})
    _creator.save
  end
end