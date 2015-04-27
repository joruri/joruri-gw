class System::ProductSynchroPlan < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  serialize :product_ids, Array

  has_many :product_synchros, -> { order(:id) }, :class_name => 'System::ProductSynchro', :foreign_key => :plan_id

  before_validation :set_product_ids

  validates_presence_of :start_at
  validate :validate_start_at

  def states
    [['予定','plan'],['実行中','start'],['実行済','end']]
  end

  def state_label
    str = states.rassoc(self.state)
    str ? str[0] : ''
  end

  def editable?
    state == 'plan'
  end

  def products
    System::Product.where(:id => self.product_ids).order(:id)
  end

  def set_product_ids
    if self.product_ids_changed?
      self.product_ids = System::Product.where(:id => self.product_ids).order(:id).pluck(:id)
    end
  end

protected

  def validate_start_at
    if self.start_at
      arel_table = self.class.arel_table
      item = self.class.where(:state => 'plan')
        .where(arel_table[:start_at].gteq(start_at - 1.hours))
        .where(arel_table[:start_at].lteq(start_at + 1.hours))
      item = item.where(arel_table[:id].not_eq(id)) unless new_record?
      if item.first
        self.errors.add(:start_at, 'の前後1時間以内に既に同期予定があります。')
      end
    end
  end
end
