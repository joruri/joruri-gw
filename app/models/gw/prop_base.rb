class Gw::PropBase < Gw::Database
  self.abstract_class = true

  def genre_name
    self.class.to_s.sub('Gw::Prop', '').downcase
  end

  def get_type_class
    ""
  end

  def display_prop_name
    name
  end

  def display_prop_name_for_select
    name
  end

  def is_admin?(user = Core.user)
    false
  end

  def is_edit?(user = Core.user)
    true
  end

  def is_read?(user = Core.user)
    true
  end

  def is_admin_or_editor_or_reader?(user = Core.user)
    true
  end

  def deleted?
    self.delete_state == 1
  end

  def reservable?
    self.reserved_state == 1
  end

  def pm_related?
    self.class.name.in?(["Gw::PropRentcar", "Gw::PropMeetingroom"])
  end

  class << self
    def load_prop_from_genre(genre_name, id)
      "Gw::Prop#{genre_name.capitalize}".constantize.find_by(id: id)
    end
  end
end
