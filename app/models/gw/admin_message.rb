# encoding: utf-8
class Gw::AdminMessage < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :state, :sort_no, :body, :mode
  validates_numericality_of :sort_no
  validates_length_of :body, :maximum=>10000

  def modes
    [['いつも',1], ['通常時',2], ['災害時',3]]
  end

  def mode_label
    modes.rassoc(mode).try(:first)
  end

  def state_label
    self.class.state_select.rassoc(state).try(:first)
  end

  def self.is_admin?( uid = Site.user.id )
    is_admin = System::Model::Role.get(1, uid ,'_admin', 'admin')
    return is_admin
  end

  def self.state_select
    [['する',1],['しない',2]]
  end

  def self.state_show(state)
    states = [[1,'する'],[2,'しない']]
    show = states.assoc(state)
    return show[1] unless show.blaknk?
    return ''
  end
end
