module GwHelper

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

  def show_group_link(id, options={})
    opt_user_types = AppConfig.gw.schedule_class_types.invert.to_a

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

    if options[:priv] != :edit
      rep = opt_user_types.rassoc '_prop_genre_extras'
      if !rep.blank?
        prop_genre_extras = Gw::ScheduleProp.get_genre_select :key_prefix => 'prop_'
        opt_user_types[opt_user_types.index(rep),1] = prop_genre_extras
      end

      opt_user_types += [ ["週間行事予定表" , "event_week" ] ]
      opt_user_types += [ ["月間行事予定表" , "event_month" ] ]
      opt_user_types += [ ["会議等案内表示" , "meetings_guide" ] ]
    end

    mode = options[:mode]
    options.delete :mode
    case mode
    when :form_schedule
      %w(prop leader).each do |y|
        opt_user_types = opt_user_types.select{|x| %r(#{y}) !~ x[1]}
      end
      include_blank=nil
    when :form_schedule_child
      opt_user_types = System::Group.enabled_group_options.map {|opts| [opts[0], "child_group_#{opts[1]}"] }
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
    ret = %Q(<div class="#{Gw.join(class_a, ' ')}">#{get_form_title _params}</div>)
    return ret.html_safe
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
end
