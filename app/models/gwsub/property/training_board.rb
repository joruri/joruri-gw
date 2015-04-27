class Gwsub::Property::TrainingBoard < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 1, name: "gwsub_training_board", type_name: "bbs" }
  end

  def default_options
    nil
  end

  def encode(value)
    value
  end

  def decode
    options
  end

  def board_id
    options.blank? ? nil : options
  end
end
