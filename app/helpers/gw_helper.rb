# -*- encoding: utf-8 -*-
module GwHelper

  def newline_to_br(text)
    text.to_s.gsub(/\r\n|\r|\n/, "<br />")
  end
  def date_format(format, d)
    Gw.date_format(format, d)
  end

  def mock_for_select(str, _options={})
    options = HashWithIndifferentAccess.new(_options)
    idx = 0
    delim = nz(options[:delim], ':')
    in_a = str.is_a?(Array) ? str : str.split(delim)
    ret = in_a.collect{|x|
      idx+=1
      if !options[:value_as_label].blank?
        [x,x]
      elsif !options[:with_idx].blank?
        [idx,x]
      elsif options[:for_radio].nil?
        ['',x]
      else
        [x, idx]
      end
    }
    return options[:to_s].blank? ? ret : Gw.options_for_select(ret, options[:selected])
  end

  def opt_schedule_week_1st
    mock_for_select '日曜:月曜', :for_radio=>1
  end

  def show_group_link(id, options={})
    opt_user_types = Gw.yaml_to_array_for_select('gw_users_class_types')

    if options[:priv] == :edit
      opt_user_types += [ ["職員選択（他所属）" , "all_group" ] ]
    else
      opt_user_types += [ ["所属検索" , "all_group" ] ]
    end

    g = Core.user.groups
    rep = opt_user_types.rassoc '_belong'
    rep[0] = g[0].name if !rep.blank?

    opt_user_types += [ ["-----------------" , "-" ] ]
    tmp_prefix = ''
    glist = System::CustomGroup.get_my_view( { :priv => options[:priv] } )
    glist.each {|x|
      if options[:mode] == :form_schedule
       if x.is_default == 1 && rep[0] == x.name
         opt_user_types.delete_at(opt_user_types.index(rep)) if !opt_user_types.index(rep).blank?
         options[:selected] = "custom_group_#{x.id}"
       end
      end
      if tmp_prefix == '' && x.sort_prefix != ''
#        opt_user_types += [ ["-----------------" , "-" ] ]
      end
      prefix = (x.sort_prefix == '' ? '' : '個）')
      opt_user_types += [ [ prefix + x.name , 'custom_group_'+x.id.to_s ] ]
      tmp_prefix = x.sort_prefix
    }

    rep = opt_user_types.rassoc '_prop_genre_extras'
    if !rep.blank?
      prop_genre_extras = Gw::ScheduleProp.get_genre_select :key_prefix => 'prop_'
      opt_user_types[opt_user_types.index(rep),1] = prop_genre_extras
    end

    mode = options[:mode]
    options.delete :mode
    case mode
    when :form_memo
      enabled_group = System::Group.find(:all,
        :conditions=>"state='enabled' ",
        :order=>'sort_no, code, name').collect{|x| [x.name, "memo_group_#{x.id.to_s}"]}
      opt_user_types = enabled_group
      options[:selected]="memo_group_#{Core.user_group.id.to_s}"
      include_blank=nil
    when :form_schedule
      %w(prop leader).each do |y|
        opt_user_types = opt_user_types.select{|x| %r(#{y}) !~ x[1]}
      end
      include_blank=nil
    when :form_schedule_child
      opt_user_types = Gwsub.grouplist4(nil, nil , true , nil, nil, {:return_pattern => 3})
      options[:selected]="child_group_#{Core.user_group.id.to_s}"
      include_blank=nil
    else
      %w(_belong).each do |y|
        opt_user_types = opt_user_types.select{|x| %r(#{y}) !~ x[1]}
      end
      include_blank=1
    end

    opt_user_types = Gw.options_for_select(opt_user_types, options[:selected], :include_blank=>include_blank, :to_s=>1, :title=>:n1)
    opt = options.dup
    opt.delete :selected
    ret = select_tag(id, opt_user_types, opt)
    return ret
  end

  def show_all_groups_hidden_popups(d, options={})
    opt_user_types = Gw.yaml_to_array_for_select('gw_users_class_types')
    return '' if opt_user_types.rassoc('all_group').nil?
    ret = '<div id="popup_select_group_2" class="yuimenu"><div class="bd"><ul class="first-of-type">'
    System::Group.find(:all, :conditions=>'level_no=2').each do |x|
      ret += %Q(\n<li class="yuimenuitem"><a class="yuimenuitemlabel" href="\#x#{x.id}">#{x.name}</a>)
      ret += %Q(<div id="x#{x.id}" class="yuimenu"><div class="bd"><ul>)
      System::Group.find(:all, :conditions=>"parent_id=#{x.id}").each do |y|
        ret += %Q(\n<li class="yuimenuitem"><a class="yuimenuitemlabel" href="/gw/schedules?gid=#{y.id}&amp;s_date=#{Gw.date8_str(d)}">#{y.name}</a></li>)
      end
      ret += %Q(</ul></div></div></li>)
    end
    ret += '</ul></div></div>'
    ret += <<-EOL
<script type="text/javascript">
//<![CDATA[
  //var myMenu = new YAHOO.widget.Menu('popup_select_group');
  var oMenu = new YAHOO.widget.Menu("popup_select_group_2");
  /*
  YAHOO.util.Event.onContentReady("productsandservices", function () {
    var oMenu = new YAHOO.widget.Menu("productsandservices", { fixedcenter: true });
    oMenu.render();
  YAHOO.util.Event.addListener("menutoggle", "click", oMenu.show, null, oMenu); */
//]]>
</script>
    EOL
    ret
  end

  def date_time_field(f, field_name)
    return %Q[#{f.text_field field_name, :style => 'width:10em;'}] +
      %Q[<button type="button" id="#{field_name}_bt" onclick="showCalendar('#{field_name}_bt','#{f.object_name}_#{field_name}')" class="show_cal_bt"></button>]
  end

  def get_form_title_div(_params)
    class_a  = %w(formTitle)
    class_a.push case _params[:sender_action] ? _params[:sender_action] : _params[:action]
    when 'new', 'create'
      'new'
    when 'quote'
      'quote'
    when 'edit', 'editlending', 'update', 'edit_1', 'edit_2'
      get_repeat_mode(_params) == 1 ? 'edit' : 'editRepeat'
    else
    end
    %Q(<div class="#{Gw.join(class_a, ' ')}">#{get_form_title _params}</div>)
  end

  def get_form_title(_params)
    act = _params[:sender_action] ? _params[:sender_action] : _params[:action]
    case act
    when 'new', 'create'
      '新規作成'
    when 'quote'
      '引用作成'
    when 'edit', 'editlending', 'update', 'edit_1', 'edit_2'
      get_repeat_mode(_params) == 1 ? '編集' : '繰り返し編集'
    else
    end
  end

  def quote_attrs(_params)
    return (hidden_field_tag :sender_action, (params[:sender_action] ? params[:sender_action] : params[:action])) + 
      (hidden_field_tag :sender_id, params[:id])
  end

  def get_repeat_mode(_params)
    (!_params[:repeat].nil? ? 2 : _params[:init].nil? ? 1 : nz(_params[:init][:repeat_mode], 1)).to_i
  end

  def gw_js_include_full
    return gw_js_include_yui + gw_js_include_popup_calendar
  end

  def gw_js_include_yui
    return <<EOL
<script type="text/javascript" src="/_common/js/yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="/_common/js/yui/build/element/element-min.js"></script>
<script type="text/javascript" src="/_common/js/yui/build/button/button-min.js"></script>
<script type="text/javascript" src="/_common/js/yui/build/container/container-min.js"></script>
<script type="text/javascript" src="/_common/js/yui/build/calendar/calendar-min.js"></script>
EOL
  end

  def gw_js_include_popup_calendar
    return <<EOL
<script type="text/javascript" src="/_common/js/popup_calendar/popup_calendar.js"></script>
EOL
  end

  def gw_js_ind_popup
    return <<EOL
<script type="text/javascript">
//<![CDATA[
  var gw_js_ind_popup = function() {
    YAHOO.namespace("example.container");
    if (!is_ie()) {
      document.body.addClassName('yui-skin-sam');
      tooltips = document.getElementsByClassName('ind');
      for (var i = 0; i < tooltips.length; i++) {
        YAHOO.example.container.tt1 = new YAHOO.widget.Tooltip("tooltip", { context:tooltips[i]['id'] });
      }
    }
  }
  // window.onload = my_load;
//]]>
</script>
EOL
  end

  def memos_tabbox_struct(send_cls, _qsa)
    qsa = _qsa.nil? ? [] : _qsa
    qs_without_send_cls = Gw.qsa_to_qs(qsa.select{|x| x[0] != 's_send_cls'},{:no_entity=>true})
    qs_without_send_cls = qs_without_send_cls.blank? ? '' : "&amp;#{qs_without_send_cls}"
    idx = 0
    tab_captions = %w(受信 送信 ).collect{|x| idx+=1; %Q(<a href="#{gw_memos_path}?s_send_cls=#{idx}#{qs_without_send_cls}">#{x}</a>)}
    ret = tabbox_struct tab_captions, send_cls.to_i
    return ret.html_safe
  end

  def schedule_settings
    get_settings 'schedules'
  end

  def schedule_prop_settings
    get_settings 'schedule_props'
  end

  def get_settings(key, options={})
    Gw::Model::Schedule.get_settings key, options
  end

  def out_form_ind(key, options={})
    item = @item
    if key == 'ssos'
      item = item['pref_soumu']
      item = {} if item.blank?
    end
    styles = nz(options[:styles], {})
    trans_a = Gw.yaml_to_array_for_select("gw_#{key}_settings_ind")
    trans_hash = Gw::NameValue.get('yaml', nil, "gw_#{key}_settings_ind")
    errors = nz(item['errors'], [])
    textarea_fields = nz(trans_hash['_textarea_fields'], [])
    textarea_fields = textarea_fields.split(':') if !textarea_fields.is_a?(Array)
    password_fields = nz(trans_hash['_password_fields'], [])
    password_fields = password_fields.split(':') if !password_fields.is_a?(Array)
    object_name = :item
    content_for :form do
      form_for :item, :url => "/gw/schedules/edit_ind_#{key}", :html => {:method=>:put, :multipart => true} do |f|
        concat nz(Gw.error_div(item['errors']))
        concat hidden_field_tag('key', key)
        concat '<table class="show">'
        trans_a.each do |_trans|
          col = _trans[1]
          split_trans = _trans[0].split(':')
          trans = _trans[0]
          tag_name = "#{object_name}[#{col}]" rescue col
          tag_id = Gw.idize(tag_name)
          field_str, value_str = if textarea_fields.index(col).nil?
            case split_trans[0]
            when 'r'
              [split_trans[1], select_tag(tag_name, Gw.yaml_to_array_for_select(split_trans[2], :to_s=>1, :selected=>item[col]))]
            else
              style = nz(styles[col], 'width:30em;')
                if password_fields.index(col).nil?
                  val = text_field_tag(tag_name, item[col], :style => style)
                else
                  val = item[col]
                  val = val.decrypt if !val.blank?
                  val = password_field_tag(tag_name, val, :style => style)
                end
                trans = col.humanize if trans == ''
                [h(trans), val]
            end
          else
            [h(trans), form_text_area(f, col)]
          end
          value_str = %Q(<div class="fieldWithErrors">#{value_str}</div>) if !errors.assoc(col).nil?
          concat "<tr><th>#{field_str}</th><td>#{value_str}</td></tr>"
        end
        concat '</table>'
        submit_options={}
        submit_options[:id]="item_submit_#{key}"
        case @key
        when 'mobiles'
          submit_options[:caption] = '保存'
        when 'ssos'
          submit_options[:caption] = '保存する'
        else
          if options[:caption].nil?
            submit_options[:caption] = '編集する'
          else
            submit_options[:caption] = options[:caption]
          end
        end
        concat submit_for_update(f, submit_options)
      end
    end
    return @content_for_form
  end
end
