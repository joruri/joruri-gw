class Gw::Property::PortalAddDispLimit < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  validates :left_limit, numericality: true
  validates :bottom_limit, numericality: true
  validates :right_limit, numericality: true
  validate :validate_right_numericality

  def default_attributes
    { class_id: 3, uid: "portal_add", name: "portal_disp_limit", type_name: "json" }
  end

  def default_options
    Array.new(3, ['0'])
  end

  def left_limit
    options_value.flatten[0]
  end

  def bottom_limit
    options_value.flatten[1]
  end

  def right_limit
    options_value.flatten[2]
  end

  private

  def validate_right_numericality
    if right_limit.to_i > 3
      errors.add(:right_limit, :less_than_or_equal_to, :count => 3)
    end
  end
end
