# encoding: utf-8
module System::Model::Unid::Inquiry
  def self.included(mod)
    mod.has_one :inquiry, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'System::Inquiry',
      :dependent => :destroy

    mod.after_save :save_inquiry
  end

  attr_accessor :_inquiry

  def inquiry_states
   {'visible' => '表示', 'hidden' => '非表示'}
  end

  def save_inquiry
    return true  unless _inquiry
    return false unless unid
    return false if @save_inquiry_callback_flag

    @save_inquiry_callback_flag = true

    _inq = inquiry || System::Inquiry.new({:unid => unid})
    _inq.state    = _inquiry['state']    unless _inquiry['state'].nil?
    _inq.group_id = _inquiry['group_id'] unless _inquiry['group_id'].nil?
    _inq.charge   = _inquiry['charge']   unless _inquiry['charge'].nil?
    _inq.tel      = _inquiry['tel']      unless _inquiry['tel'].nil?
    _inq.fax      = _inquiry['fax']      unless _inquiry['fax'].nil?
    _inq.email    = _inquiry['email']    unless _inquiry['email'].nil?
    _inq.save
  end
end