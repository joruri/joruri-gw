# encoding: utf-8
module FormHelper
  def select_by_list(form, name, list, options = {}, default_key = nil)
    l = (list.nil? ? [] : list.collect {|a,b|[b,a]})
    l.unshift ['',''] if options[:include_blank]
    options.delete :include_blank unless options[:include_blank].nil?
    select_name = name
    begin
      select_name = "#{form.object_name.to_s}[#{name}]"
    rescue
    end
    select_tag(select_name, options_for_select(l, default_key), options)
  end

  ## tinyMCE
  def init_tiny_mce(options = {})
    settings = []
    options.each do |k, v|
      v = %Q("#{v}") if v.class == String
      settings << "#{k}:#{v}"
    end
    [
      javascript_include_tag("/_common/js/tiny_mce/tiny_mce.js"),
      javascript_include_tag("/_common/js/tiny_mce/init.js"),
      javascript_tag("initTinyMCE({#{settings.join(',')}});")
    ].join("\n")
  end

  def submission_label(name)
    {
      :add       => '追加する',
      :create    => '作成する',
      :register  => '登録する',
      :edit      => '編集する',
      :update    => '更新する',
      :change    => '変更する',
      :delete    => '削除する'
    }[name]
  end

  def submit(*args)
    make_tag = Proc.new do |_name, _label|
      _label ||= submission_label(_name) || _name.to_s.humanize
      submit_tag(_label, :name => "commit_#{_name}", :class => _name)
    end

    h = '<div class="submitters">'
    if args[0].class == String || args[0].class == Symbol
      h += make_tag.call(args[0], args[1])
    elsif args[0].class == Hash
      args[0].each {|k, v| h += make_tag.call(k, v) }
    elsif args[0].class == Array
      args[0].each {|v, k| h += make_tag.call(k, v) }
    end
    h += '</div>'
  end

  def submit_for(form, options = {})
    js_submitter = options[:js_submitter] || nil
    caption = options[:caption] || 'Submit'
    no_out_div = options[:no_out_div]
    [:js_submitter, :caption, :no_out_div].each {|x| options.delete x unless options[x].nil?}
    if js_submitter.nil?
      ret = form.submit(caption, options)
    else
      options[:id] = options[:id] || 'item_submit'
      options[:name] = options[:name] || 'commit'
      ret = button_to_function(caption, js_submitter, options)
    end
    return no_out_div ? ret : ('<div class="submitters">' + ret + '</div>').html_safe
  end

  def submit_for_create(form, options = {})
    options[:caption] = '登録する' if options[:caption].nil?
    submit_for(form, options)
  end

  def submit_for_update(form, options = {})
    options[:caption] = '編集する' if options[:caption].nil?
    submit_for(form, options)
  end

  def tool_tiny_mce(base_url = "/", options = {})
    render :partial => 'system/tool/tiny_mce/init', :locals => {:base_url => base_url, :options => options}
  end

  def radio(form, name, list, options = {})
    k,v,br,html = '','','',''
    html_a = []
    force_tag = options[:force_tag]
    options.delete :force_tag
    opt_return_array = options[:return_array]
    options.delete :return_array
#
    radio_1line = proc {|v,k|
      _v = v
      _text = ''
      unless options[:text_field].nil?
        md = _v.match(/^t:(.+?):(.+)$/)
        _v = md[2] if !md.nil?
        _text = form.text_field(md[1], :style => 'width:10em;') if !md.nil?
      end
      selected = params.blank? ? false : params[form.object_name].blank? ? false : "#{params[form.object_name][name]}"=="#{k}"
      selected = options[:selected].blank? ? false : "#{options[:selected]}"=="#{k}"
      radio_w = force_tag.blank? ? form.radio_button(name, k, options) :
        radio_button_tag("#{form.object_name}[#{name}]", k, selected, options)
      html_a.push "#{radio_w}" +
        "<label for=\"#{form.object_name}_#{name}_#{k.to_s}\">#{_v}</label>#{_text}#{br}\n"
    }
#
    br = options[:br].nil? ? '' : '<br />'
    if list.class == Array
#      list.each {|v, k| radio_1line.call}
      list.each do |v, k|
        radio_1line.call(v,k)
      end
    else
#      list.each {|k, v| radio_1line.call}
      list.each do |k, v|
        radio_1line.call(v,k)
      end
    end
    return !opt_return_array.blank? ? html_a : "#{options[:prefix]}#{Gw.join(html_a, options[:delim])}#{options[:suffix]}".html_safe
  end

  def date_picker3(f, name, value=nil, options={})
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    options[:id] = Gw.name_to_id(tag_name)
    options[:format] = :db
    options[:image] = '/_common/themes/gw/files/icon/ic_act_calendar.gif'
    options[:embedded] = false if options[:embedded].blank?
    options[:time] = true if options[:time].nil?
    options[:style] = 'width:10em; ime-mode: disabled;' if options[:style].blank?
    this_year = Date.today.year
    options[:year_range] = (((this_year - 5)..(this_year + 5))).to_a if options[:year_range].blank?
    err_flg = options[:errors].nil? ? nil : options[:errors][name].first
    options.delete :errors
    ret = calendar_date_select_tag tag_name, value, options
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret
  end

  def check_boxes(form, name, list, _options = {})
    options = HashWithIndifferentAccess.new(_options)
    mode = nz(options[:form_type])
    options.delete :form_type
    delim = nz(options[:delim], ':')
    selected = nz(options[:selected_str], '').split(delim)
    options.delete :selected_str
    options.delete :check_with_to_s
    a_cbs = []
    form_name = mode.blank? ? form.object_name : form
    list.each_with_index do |item,idx|
      id = "#{form_name}[#{name}][#{idx}]"
      check_ind = !selected.index(item[1]).nil? || !selected.index(item[1].to_s).nil?
      a_cbs.push check_box_tag(id, "#{item[1]}", check_ind, options) +
        label_tag(id, "#{item[0]}", options)
    end
    a_cbs.join '&nbsp;'
  end

  def check_boxes2(form, name, list, _options = {})
    _options[:check_with_to_s] = 1
    check_boxes form, name, list, _options
  end

  def date_picker(f, name, value=nil, options={})
    ret = f.text_field(name, :value=>value, :style => 'width:10em; ime-mode: disabled;') rescue text_field_tag(name, value, :style => 'width:10em; ime-mode: disabled;')
    tag_name = "#{f.object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    ret += %Q(<button type="button" id="#{tag_id}_bt" onclick="showCalendar('#{tag_id}_bt','#{tag_id}')" class="show_cal_bt"></button>)
    ret
  end

  def date_picker4(f, name, value=nil, options={})
    begin
      ret = f.text_field name, :value=>value, :style => 'width:10em; ime-mode: disabled; vertical-align: top;'
    rescue
      ret = text_field_tag name, value, :style => 'width:10em; ime-mode: disabled; vertical-align: top;'
    end
    tag_name = "#{f.object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    ret += %Q(<button type="button" id="#{tag_id}_bt" onclick="showCalendar('#{tag_id}_bt','#{tag_id}')" class="show_cal_bt" style="vertical-align: middle;"></button>)
    ret
  end

  def date_picker3(f, name, value=nil, options={})
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    options[:id] = Gw.name_to_id(tag_name)
    options[:format] = :db
    options[:image] = '/_common/themes/gw/files/icon/ic_act_calendar.gif'
    options[:embedded] = false if options[:embedded].blank?
    options[:time] = true if options[:time].nil?
    options[:style] = 'width:10em; ime-mode: disabled;' if options[:style].blank?
    this_year = Date.today.year
    options[:year_range] = (((this_year - 5)..(this_year + 5))).to_a if options[:year_range].blank?
    err_flg = options[:errors].nil? ? nil : options[:errors][name].first
    options.delete :errors
    ret = calendar_date_select_tag tag_name, value, options
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret
  end

  def date_picker5(f, name, value=nil, _options={})
    options = HashWithIndifferentAccess.new(_options)
    err_flg =  options[:errors][name].first
    options.delete :errors

    tag_name = "#{f.object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)

    ret = "#{options[:caption]}"
    ret += f.text_field(name, :value=>value, :style => 'width:10em; ime-mode: disabled;') rescue text_field_tag(name, value, :style => 'width:10em; ime-mode: disabled;')
    ret += %Q(<button type="button" id="#{tag_id}_bt" onclick="showCalendar('#{tag_id}_bt','#{tag_id}')" class="show_cal_bt"></button>)
    if !options[:time].nil?
      #ret += f.select(:category_id, Gw.yaml_to_array_for_select('gw_todos_category'), :selected=>@item.category_id)
      ret += %Q( #{select_tag("item[schedule_props][prop_type_id]",Gw.options_for_select((0..23).to_a.collect{|x| [x,x]}, :include_blank=>1))} 時) +
        %Q( #{select_tag("item[schedule_props][prop_type_id]",Gw.options_for_select([0,15,30,45].collect{|x| [x,x]}, :include_blank=>1))} 分)
    end
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret = %Q(<div class="fieldDatetime2">#{ret}</div>)
    ret
  end

  def date_picker6(f, name, _options={})
    options_org = HashWithIndifferentAccess.new(_options)
    options = options_org
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    err_flg = options[:errors].nil? ? nil : options[:errors][name].first
    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0

    captions_default = ['','年','月','日','－','時','分', '']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]
    captions_caption = [captions[0], captions[4], captions[7]]

    ret = ''

    options_calendar_date_select = {
      :hidden => 1, :id=>tag_id, :time=> !%w(time datetime).index(mode).nil?, :minute_interval=>minute_interval,
      :onchange => "update_#{tag_id}_from_calendar();",
      :image=>'/_common/themes/gw/files/icon/ic_act_calendar.gif',
    }
    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name), :onchange=> "update_#{tag_id}();") +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
#{captions_caption[0]}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, years_a, value.year
      ret += datetime_part.call 2, 1..12, value.month
      ret += datetime_part.call 3, 1..31, value.day
    end
    ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour
      _selected_min_flg = false
      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        _selected_min_flg = true if _min_cnt == _selected_min
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end
      unless _selected_min_flg
        _selected_min = 0
        value = Time.local(value.year, value.month, value.day, value.hour, _selected_min, value.sec)
      end
      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += captions_caption[2]

    ret += !%w(date datetime).index(mode).nil? ?
      calendar_date_select_tag(tag_name, value, options_calendar_date_select) :
      hidden_field_tag(tag_name, Gw.time_str(value))
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret += <<-EOL
<script type="text/javascript">
//<![CDATA[
var update_#{tag_id} = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  if (mode == 'datetime' || mode == 'date')
    ymd = $('#{Gw.idize("#{tag_name}_1i")}').value + '-' + $('#{Gw.idize("#{tag_name}_2i")}').value + '-' + $('#{Gw.idize("#{tag_name}_3i")}').value;
EOL
    if tag_id == 'item_st_at'
      ret += <<-EOL
  if (mode == 'datetime' || mode == 'time') {
    hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
    var hne = $('#{Gw.idize("#{tag_name}_4i")}').value;
    hne-=0;
    hne = hne + 1;
    hne+"";
    var hned = hne + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
  }
  var sta;
  var stb;
  sta = $('item_st_at_4i').value;
  stb = $('item_st_at_5i').value;
  $('item_ed_at_4i').value = sta;
  $('item_ed_at_5i').value = stb;
  sta-=0;
  stb-=0;
  if (sta < 23) {
    $('item_ed_at_4i').selectedIndex = sta + 1;
  }
//  if (stb == 0) {
//    $('item_ed_at_5i').selectedIndex = 0;
//  } else if (stb == 30) {
//    $('item_ed_at_5i').selectedIndex = 1;
//  }
  sty = $('item_st_at_1i').value;
  stm = $('item_st_at_2i').value;
  std = $('item_st_at_3i').value;
  sty-=0;
  stm-=0;
  std-=0;
  sty = sty - 2005;
  stm = stm - 1;
  std = std - 1;
  $('item_ed_at_1i').selectedIndex = sty;
  $('item_ed_at_2i').selectedIndex = stm;
  $('item_ed_at_3i').selectedIndex = std;

EOL
    elsif tag_id == 'item_repeat_st_time_at'

      ret += <<-EOL
  if (mode == 'datetime' || mode == 'time') {
    hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
    var hne = $('#{Gw.idize("#{tag_name}_4i")}').value;
    hne-=0;
    hne = hne + 1;
    hne+"";
    var hned = hne + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
  }
  var sta;
  var stb;
  sta = $('item_repeat_st_time_at_4i').value;
  stb = $('item_repeat_st_time_at_5i').value;
  $('item_repeat_ed_time_at_5i').value = stb;
  sta-=0;
  stb-=0;
  if (sta < 23) {
    $('item_repeat_ed_time_at_4i').selectedIndex = sta + 1;
  }
//  if (stb == 0) {
//     $('item_repeat_ed_time_at_5i').selectedIndex = 0;
//  } else if (stb == 30) {
//     $('item_repeat_ed_time_at_5i').selectedIndex = 1;
//  }
EOL
    elsif tag_id == 'item_repeat_st_date_at'

      ret += <<-EOL

  sty = $('item_repeat_st_date_at_1i').value;
  stm = $('item_repeat_st_date_at_2i').value;
  std = $('item_repeat_st_date_at_3i').value;
  sty-=0;
  stm-=0;
  std-=0;
  sty = sty - 2005;
  stm = stm - 1;
  std = std - 1;
  $('item_repeat_ed_date_at_1i').selectedIndex = sty;
  $('item_repeat_ed_date_at_2i').selectedIndex = stm;
  $('item_repeat_ed_date_at_3i').selectedIndex = std;

EOL
    else
    ret += <<-EOL
  if (mode == 'datetime' || mode == 'time')
    hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
EOL
    end

    if tag_id == 'item_st_at'

    ret += <<-EOL
  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
  case 'date': ret = ymd; reted = ymd; break;
  case 'time': ret = hn; reted = hned; break;
  }
  $('item_ed_at').value = reted;

EOL

    elsif tag_id == 'item_repeat_st_time_at'

    ret += <<-EOL
  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
  case 'date': ret = ymd; reted = ymd; break;
  case 'time': ret = hn; reted = hned; break;
  }
  $('item_repeat_ed_time_at').value = reted;
EOL

    elsif tag_id == 'item_repeat_st_date_at'

    ret += <<-EOL
  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
  case 'date': ret = ymd; reted = ymd; break;
  case 'time': ret = hn; reted = hned; break;
  }
  $('item_repeat_ed_date_at').value = reted;
EOL
    else
    ret += <<-EOL
  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; break;
  case 'date': ret = ymd; break;
  case 'time': ret = hn; break;
  }
EOL
    end

    ret += <<-EOL
  $('#{tag_id}').value = ret;

}
var update_#{tag_id}_from_calendar = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  value = $('#{tag_id}').value;
  // pp('onchanged. ' + value);
  // $('#{tag_id}').value = this.value;
  switch(mode) {
  case 'datetime':
    var match = value.match(/^\\s*(\\d{4})-(\\d{1,2})-(\\d{1,2}) +(\\d{1,2}):(\\d{1,2})\\s*$/);
    for (var i=1; i<=5; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));
EOL
    if tag_id == 'item_st_at'

    ret += <<-EOL
    if (mode == 'datetime' || mode == 'time') {
      ymd = $('#{Gw.idize("#{tag_name}_1i")}').value + '-' + $('#{Gw.idize("#{tag_name}_2i")}').value + '-' + $('#{Gw.idize("#{tag_name}_3i")}').value;
      hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
      var hne = $('#{Gw.idize("#{tag_name}_4i")}').value;
      hne-=0;
      hne = hne + 1;
      hne+"";
      var hned = hne + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
    }
    switch(mode) {
    case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
    case 'date': ret = ymd; reted = ymd; break;
    case 'time': ret = hn; reted = hned; break;
    }

    $('item_ed_at').value = reted;
    $('item_ed_at_1i').value= $('item_st_at_1i').value;
    $('item_ed_at_2i').value= $('item_st_at_2i').value;
    $('item_ed_at_3i').value= $('item_st_at_3i').value;
    var sta;
    var stb;
    sta = $('item_st_at_4i').value;
    stb = $('item_st_at_5i').value;
    $('item_ed_at_4i').value = sta;
    $('item_ed_at_5i').value = stb;
    sta-=0;
    stb-=0;
    if (sta < 23) {
      $('item_ed_at_4i').selectedIndex = sta + 1;
    }
    if (stb == 0) {
      $('item_ed_at_5i').selectedIndex = 0;
    } else if (stb == 30) {
      $('item_ed_at_5i').selectedIndex = 1;
    }

EOL
    else
    ret += <<-EOL
    switch(mode) {
    case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
    case 'date': ret = ymd; reted = ymd; break;
    case 'time': ret = hn; reted = hned; break;
    }
    $('item_ed_at').value = reted;
EOL

    end

    ret += <<-EOL
    break;
  case 'date':
    var match = value.match(/^\\s*(\\d{4})-(\\d{1,2})-(\\d{1,2})\\s*$/);
    for (var i=1; i<=3; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));
    break;
  case 'time':
    // this route is naver called.
    var match = value.match(/^\\s*(\\d{1,2}):(\\d{1,2})\\s*$/);
    $('#{tag_id}_4i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_4i'), match[1].sub(/^0/, ''));
    $('#{tag_id}_5i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_5i'), match[1].sub(/^0/, ''));
    break;
  }
  if (mode == 'datetime' || mode == 'date')
  if (mode == 'datetime' || mode == 'time') {
  }
}
//]]>
</script>
EOL
    ret
  end

  def date_picker_mobile(f, name, _options={})
    options_org = HashWithIndifferentAccess.new(_options)
    options = options_org
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    tag_id_ed = if tag_id == 'item_st_at'
        "item_ed_at"
      elsif tag_id == 'item_st_at_noprop'
        "item_ed_at_noprop"
      elsif tag_id == 'item_repeat_st_date_at'
        "item_repeat_ed_date_at"
      elsif tag_id == 'item_repeat_st_date_at_noprop'
        "item_repeat_ed_date_at_noprop"
      elsif tag_id == 'item_repeat_st_date_at'
        'item_repeat_ed_date_at'
      elsif tag_id == 'item_repeat_ed_date_at_noprop'
        'item_repeat_ed_date_at_noprop'
      end
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    err_flg = options[:errors].nil? ? nil : options[:errors][name].first
    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0

    captions_default = ['','年','月','日','<br />','時','分', '']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]
    captions_caption = [captions[0], captions[4], captions[7]]

    ret = ''

    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name)) +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
#{captions_caption[0]}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, years_a, value.year
      ret += datetime_part.call 2, 1..12, value.month
      ret += datetime_part.call 3, 1..31, value.day
    end
    ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour

      _selected_min_flg = false
      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        _selected_min_flg = true if _min_cnt == _selected_min
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end

      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += captions_caption[2]
    ret += !%w(date datetime).index(mode).nil? ?
     ""  : hidden_field_tag(tag_name, Gw.time_str(value))
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret.html_safe
  end


  def date_picker_smartphone(f, name, _options={})
    options_org = HashWithIndifferentAccess.new(_options)
    options = options_org
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    tag_id_ed = if tag_id == 'item_st_at'
        "item_ed_at"
      elsif tag_id == 'item_st_at_noprop'
        "item_ed_at_noprop"
      elsif tag_id == 'item_repeat_st_date_at'
        "item_repeat_ed_date_at"
      elsif tag_id == 'item_repeat_st_date_at_noprop'
        "item_repeat_ed_date_at_noprop"
      elsif tag_id == 'item_repeat_st_date_at'
        'item_repeat_ed_date_at'
      elsif tag_id == 'item_repeat_ed_date_at_noprop'
        'item_repeat_ed_date_at_noprop'
      end
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    err_flg = options[:errors].nil? ? nil : options[:errors][name].first
    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0
    captions_default = ['','年','月','日','<br />','時','分', '']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]               # 個別枠後挿入文字列
    captions_caption = [captions[0], captions[4], captions[7]] # 全体枠挿入文字列(日時の前、日時の間、日時の後)
    ret = ''
    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name), :onchange=> "update_#{tag_id}();") +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, years_a, value.year
      ret += datetime_part.call 2, 1..12, value.month
      ret += datetime_part.call 3, 1..31, value.day
    end
    ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour
      _selected_min_flg = false
      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        _selected_min_flg = true if _min_cnt == _selected_min
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end
      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += captions_caption[2]
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret.html_safe
  end

  def date_picker_prop(f, name, _options={})
    options = HashWithIndifferentAccess.new(_options)
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    err_flg = options[:errors].nil? ? nil : options[:errors][name].first
    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0

    captions_default = ['','年','月','日','－','時','分', '']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]
    captions_caption = [captions[0], captions[4], captions[7]]

    ret = ''

    options_calendar_date_select = {
      :hidden => 1, :id=>tag_id, :time=> !%w(time datetime).index(mode).nil?, :minute_interval=>30,
      :onchange => "update_#{tag_id}_from_calendar();",
      :image=>'/_common/themes/gw/files/icon/ic_act_calendar.gif',
      :clear_button => false
    }
    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name), :onchange=> "update_#{tag_id}();") +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
#{captions_caption[0]}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, years_a, value.year
      ret += datetime_part.call 2, 1..12, value.month
      ret += datetime_part.call 3, 1..31, value.day
    end
    ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour

      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end

      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += captions_caption[2]
    ret += !%w(date datetime).index(mode).nil? ?
      "<span id=\"#{tag_id}_calendar\">" + calendar_date_select_tag(tag_name, value, options_calendar_date_select) + "</span>" :
      hidden_field_tag(tag_name, Gw.time_str(value))
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret
  end

  def date_picker7(f, name, _options={})
    options_org = HashWithIndifferentAccess.new(_options)
    options = options_org
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    err_flg = options[:errors].nil? ? nil : options[:errors].has_key?(name)
    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0

    captions_default = ['','年','月','日','－','時','分', '']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]
    captions_caption = [captions[0], captions[4], captions[7]]

    ret = ''

    options_calendar_date_select = {
      :hidden => 1, :id=>tag_id, :time=> !%w(time datetime).index(mode).nil?, :minute_interval=>minute_interval,
      :onchange => "update_#{tag_id}_from_calendar();",
      :image=>'/_common/themes/gw/files/icon/ic_act_calendar.gif',
      :year_range => years_a
    }
    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name), :onchange=> "update_#{tag_id}();") +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
#{captions_caption[0]}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, years_a, value.year
      ret += datetime_part.call 2, 1..12, value.month
      ret += datetime_part.call 3, 1..31, value.day
    end
    ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour

      _selected_min_flg = false
      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        _selected_min_flg = true if _min_cnt == _selected_min
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end
      unless _selected_min_flg
        _selected_min = 0
        value = Time.local(value.year, value.month, value.day, value.hour, _selected_min, value.sec)
      end
      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += captions_caption[2]

    ret += !%w(date datetime).index(mode).nil? ?
      calendar_date_select_tag(tag_name, value, options_calendar_date_select) :
      hidden_field_tag(tag_name, Gw.time_str(value))
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret += <<-EOL
<script type="text/javascript">
//<![CDATA[
var update_#{tag_id} = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  if (mode == 'datetime' || mode == 'date')
    ymd = $('#{Gw.idize("#{tag_name}_1i")}').value + '-' + $('#{Gw.idize("#{tag_name}_2i")}').value + '-' + $('#{Gw.idize("#{tag_name}_3i")}').value;
  if (mode == 'datetime' || mode == 'time')
    hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;

  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; break;
  case 'date': ret = ymd; break;
  case 'time': ret = hn; break;
  }

  $('#{tag_id}').value = ret;
}
var update_#{tag_id}_from_calendar = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  value = $('#{tag_id}').value;
  // pp('onchanged. ' + value);
  // $('#{tag_id}').value = this.value;
  switch(mode) {
  case 'datetime':
    var match = value.match(/^\\s*(\\d{4})-(\\d{1,2})-(\\d{1,2}) +(\\d{1,2}):(\\d{1,2})\\s*$/);
    for (var i=1; i<=5; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));

    switch(mode) {
    case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
    case 'date': ret = ymd; reted = ymd; break;
    case 'time': ret = hn; reted = hned; break;
    }
    $('item_ed_at').value = reted;

    break;
  case 'date':
    var match = value.match(/^\\s*(\\d{4})-(\\d{1,2})-(\\d{1,2})\\s*$/);
    for (var i=1; i<=3; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));
    break;
  case 'time':
    // this route is naver called.
    var match = value.match(/^\\s*(\\d{1,2}):(\\d{1,2})\\s*$/);
    $('#{tag_id}_4i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_4i'), match[1].sub(/^0/, ''));
    $('#{tag_id}_5i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_5i'), match[1].sub(/^0/, ''));
    break;
  }
  if (mode == 'datetime' || mode == 'date')
  if (mode == 'datetime' || mode == 'time') {
  }
}
//]]>
</script>
EOL
    ret
  end

  def form_text_area(form, name, options = {})
    opt = options.dup
    opt[:style] = 'width: 30em; ime-mode: active;' if opt[:style].blank?
    opt[:cols] = 60 if opt[:cols].blank?
    opt[:rows] = 5 if opt[:rows].blank?
    form.text_area name, opt
  end

  def link_check(form_name, elm_name, item = nil)
    link = tag(:input, { :type => "submit", :name => "check[link]", :value => "リンク/ALT属性チェック" })
    return link
  end

  def checker_messages(checker)
    return '' unless checker
    html = '<div id="checkerMessage"><h2>リンク/ALT属性チェック</h2>'
    checker.results.each do |r|
      html += "<p>#{r[0]}</p>"
      html += '<ul>'
      r[1].each do |k, v|
        bool = (v == true ? 'OK' : 'NG')
        html += "<li><span class=\"#{bool.downcase}\">#{bool}</span> #{h(k)}</li>"
      end
      html += '</ul>'
    end
    html += '</div>'
  end

  def uri_import(form_name, elm_name)
    uri = '/_admin/cms/tool/form/uri_import'
    js  = "var uri = window.prompt('URL', 'http://');" +
      " if (uri) {" +
      " window.open('#{uri}?elm=#{form_name}_#{elm_name}&amp;uri=' + uri, '_blank');" +
      " }" +
      " return false;"
    link  = '<a href="#" onclick="' + js + '">［ URL取り込み ］</a>'
    link  = '<input type="button" onclick="' + js + '" value="URL取り込み" />'
  end

  def file_import(form_name, elm_name)
    uri = "/_admin/cms/tool/form/file_import?elm=#{form_name}_#{elm_name}"
    js  = ""
    link  = '<a target="_blank" href="' + uri + '" onclick="' + js + '">［ HTML取り込み ］</a>'
    js  = "window.open('#{uri}');"
    link  = '<input type="button" onclick="' + js + '" value="HTML取り込み" />'
  end

  def toggle_editor(form_name, elm_name)
    js = "tinyMCE.toggleEditor('#{form_name}_#{elm_name}'); return false;"
    link  = '<a href="#" onclick="' + js + '">［ エディタON/OFF ］</a>'
    link  = '<input type="button" onclick="' + js + '" value="エディタON/OFF" />'
  end

  def image_button(name, alt, options = {})
    #<img class="button" src="blank.gif" alt="選択" onclick="alert('clicked.');" />
  end

  def image_submit(name, alt, options = {})
    #'<input type="image" src="blank.gif" alt="選択" />'
  end
end
