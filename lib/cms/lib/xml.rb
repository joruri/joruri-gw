module Cms::Lib::Xml
  def to_item_xml(skip_instruct = false)
    xml = skip_instruct ? "" : "<?xml version=\"1.0\"?>\n"
    xml << self.to_xml(
      :root           => "item",
      :skip_instruct  => true,
      :dasherize      => false
    )
  end
end