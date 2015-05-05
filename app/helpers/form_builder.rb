class FormBuilder < ActionView::Helpers::FormBuilder

  def radio_buttons(method, collection, options = {}, html_options = {}, &block)
    hidden_field(method, value: '') + 
      collection_radio_buttons(method, collection, :last, :first, options, html_options, &block).gsub(/<\/label>/, '</label> ').html_safe 
  end

  def check_boxes(method, collection, options = {}, html_options = {}, &block)
    collection_check_boxes(method, collection, :last, :first, options, html_options, &block)
  end

  # needs asts_as_tree
  def select_with_tree(method, start_nodes, options = {}, html_options = {}, tree_options = {})
    tree_options.merge!(label_method: :name, value_method: :id)
    collections = []
    start_nodes.each do |start_node|
      start_node.class.walk_tree({}, 0, start_node) do |node, level|
        collections << ["　　"*level + node.read_attribute(tree_options[:label_method]), node.read_attribute(tree_options[:value_method])]
      end
    end
    select(method, collections, options, html_options)
  end

  def date_select(method, options = {}, html_options = {})
    options.merge!(date_separator: '%s')
    options.reverse_merge!(use_two_digit_numbers: true)
    separators = separators_from_options(options, :date)
    (sprintf(super(method, options, html_options), *separators) + separators.last).gsub(/\n/, '').html_safe
  end

  def datetime_select(method, options = {}, html_options = {})
    options.merge!(date_separator: '%s', datetime_separator: '%s', time_separator: '%s')
    options.reverse_merge!(use_two_digit_numbers: true, minute_step: 5)
    separators = separators_from_options(options, :datetime)
    (sprintf(super(method, options, html_options), *separators) + separators.last).gsub(/\n/, '').html_safe
  end

  def datepicker(method, options = {}, picker_options = {})
    picker_base(:date, '%Y-%m-%d', method, options, picker_options)
  end

  def timepicker(method, options = {}, picker_options = {})
    picker_base(:time, '%H:%M', method, options, picker_options)
  end

  def datetimepicker(method, options = {}, picker_options = {})
    picker_base(:datetime, '%Y-%m-%d %H:%M', method, options, picker_options)
  end

  def date_select_with_picker(method, options = {}, html_options = {}, picker_options = {})
    select_with_picker_base(:date, '%Y-%m-%d', method, options, html_options, picker_options)
  end

  def datetime_select_with_picker(method, options = {}, html_options = {}, picker_options = {})
    select_with_picker_base(:datetime, '%Y-%m-%d %H:%M', method, options, html_options, picker_options)
  end

  def datetime_select_for_mobile(method, options = {}, html_options = {})
    datetime_select(method, options, html_options).gsub('日', '日<br />').html_safe
  end

  def object
    @object ? @object : @template.instance_variable_get("@#{@object_name}")
  end

  private

  def picker_base(picker_type, format, method, options = {}, picker_options = {})
    options.reverse_merge!(value: object.read_attribute(method).try(:strftime, format))
    html = text_field(method, options)
    html << jquery { %| $('##{tag_id(method)}').#{picker_type}picker(#{picker_options.to_json}); | }
    html
  end

  def select_with_picker_base(picker_type, format, method, options = {}, html_options = {}, picker_options = {})
    picker_options.reverse_merge!(yearRange: "#{Date.today.year-5}:#{Date.today.year+5}")
    id = tag_id(method)
    html = case picker_type
      when :date; date_select(method, options, html_options)
      when :datetime; datetime_select(method, options, html_options)
      end
    html << hidden_field(method, value: object.read_attribute(method).try(:strftime, format))
    html << jquery { %| $('##{id}').#{picker_type}picker(#{picker_options.to_json}); synchro#{picker_type.capitalize}SelectAndPicker('##{id}'); | }
    html
  end

  def jquery
    %|<script type="text/javascript"> (function($) { $(function() { #{yield} }); })(jQuery); </script>|.html_safe
  end

  def tag_id(method)
    ActionView::Helpers::Tags::Base.new(@object_name, method, @template).send(:tag_id)
  end

  def separators_from_options(options, mode = :datetime)
    seps = []
    seps << '年' unless options[:discard_year]
    seps << '月' unless options[:discard_month]
    seps << '日' unless options[:discard_day]
    if mode == :datetime
      seps << '時' unless options[:discard_hour]
      seps << '分' unless options[:discard_minute]
      seps << '秒' if options[:include_seconds]
    end
    seps
  end
end
