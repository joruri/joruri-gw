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
    options.reverse_merge!(value: object.read_attribute(method).try(:strftime, '%Y-%m-%d'))
    text_field(method, options) + 
      jquery { %| $('##{tag_id(method)}').datepicker(#{picker_options.to_json}); | }.html_safe
  end

  def timepicker(method, options = {}, picker_options = {})
    options.reverse_merge!(value: object.read_attribute(method).try(:strftime, '%H:%M'))
    text_field(method, options) + 
      jquery { %| $('##{tag_id(method)}').timepicker(#{picker_options.to_json}); | }.html_safe
  end

  def datetimepicker(method, options = {}, picker_options = {})
    options.reverse_merge!(value: object.read_attribute(method).try(:strftime, '%Y-%m-%d %H:%M'))
    text_field(method, options) + 
      jquery { %| $('##{tag_id(method)}').datetimepicker(#{picker_options.to_json}); | }.html_safe
  end

  def date_select_with_picker(method, options = {}, html_options = {}, picker_options = {})
    picker_options.reverse_merge!(yearRange: "#{Date.today.year-5}:#{Date.today.year+5}")
    id = tag_id(method)
    html = date_select(method, options, html_options)
    html << hidden_field(method, value: object.read_attribute(method).try(:strftime, '%Y-%m-%d'))
    html << jquery { %| $('##{id}').datepicker(#{picker_options.to_json}); synchroDateSelectAndPicker('##{id}'); | }.html_safe
  end

  def datetime_select_with_picker(method, options = {}, html_options = {}, picker_options = {})
    picker_options.reverse_merge!(yearRange: "#{Date.today.year-5}:#{Date.today.year+5}")
    id = tag_id(method)
    html = datetime_select(method, options, html_options)
    html << hidden_field(method, value: object.read_attribute(method).try(:strftime, '%Y-%m-%d %H:%M'))
    html << jquery { %| $('##{id}').datetimepicker(#{picker_options.to_json}); synchroDatetimeSelectAndPicker('##{id}'); | }.html_safe
  end

  def datetime_select_for_mobile(method, options = {}, html_options = {})
    datetime_select(method, options, html_options).gsub('日', '日<br />').html_safe
  end

  private

  def jquery
    %|<script type="text/javascript"> (function($) { $(function() { #{yield} }); })(jQuery); </script>|
  end

  def object
    @object ? @object : @template.instance_variable_get("@#{@object_name}")
  end

  def tag_id(method)
    ActionView::Helpers::Tags::Base.new(@object_name, method, @template).send(:tag_id)
  end

  def separators_from_options(options, mode = :datetime)
    seps = [[:discard_year, '年'], [:discard_month, '月'], [:discard_day, '日']].select{|k,_| !options[k]}.map(&:last)
    if mode == :datetime
      seps += [[:discard_hour, '時'], [:discard_minute, '分']].select{|k,_| !options[k]}.map(&:last)
      seps += '秒' if options[:include_seconds]
    end
    seps
  end
end
