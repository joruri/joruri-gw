class Gw::SchedulePropTemporary < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Concerns::Gw::Schedule::Prop
  belongs_to :prop, :polymorphic => true

  scope :rentcars, ->{where(:prop_type=>"Gw::PropRentcar")}

  scope :check_duplication, ->(tmp_id, st_at, ed_at, prop_id,current_time) {
    interval = AppConfig.gw.confirmation_rentcar['interval'].presence || 1
    rel = all.where.not(:tmp_id => tmp_id)
             .where(arel_table[:st_at].lteq(ed_at))
             .where(arel_table[:ed_at].gteq(st_at))
             .where(arel_table[:created_at].gt(current_time - interval.minutes))
             .where(arel_table[:created_at].lteq(current_time))
             .where(:prop_id=>prop_id)
    rel
  }

end
