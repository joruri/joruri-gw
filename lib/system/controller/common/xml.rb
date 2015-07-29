# encoding: utf-8
module System::Controller::Common::Xml
  def to_xml(items, options = {})
    options = {:root => 'items'}.merge(options)
    root    = options[:root]

    if items.kind_of?(ActiveRecord::Base)
      options[:root] = options[:root].singularize
      return item_to_xml(items, options)
    end

    options[:root] = options[:root].singularize
    options[:skip_instruct] = true

    if items.class == WillPaginate::Collection
      count = items.total_entries.to_s
    else
      count = items.size
    end

    xml = '<?xml version="1.0" encoding="UTF-8" ?>' + "\n"
    xml << "<#{root}>\n<count>#{count}</count>\n"
    items.each do |item|;
      xml << item_to_xml(item, options)
    end
    xml << "</#{root}>\n"
  end

  def item_to_xml(item, options ={})
    return defined?(super) ? super : item.to_xml(options)
  end

  def to_items_xml(items)
    xml = "<?xml version=\"1.0\"?>\n"
    xml << "<items>\n"
    xml << "<count>" + @items_count.to_s + "</count>\n"
    items.each do |item|
      xml << item.to_item_xml(true)
    end
    xml << "</items>\n"
  end
end