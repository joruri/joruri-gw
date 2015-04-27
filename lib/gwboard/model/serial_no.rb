module Gwboard::Model::SerialNo
  extend ActiveSupport::Concern

  included do
    before_create :set_serial_no
  end

  private

  def set_serial_no
    self.serial_no = self.class.where(title_id: self.title_id).maximum(:serial_no).to_i + 1
  end
end
