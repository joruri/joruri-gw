# -*- encoding: utf-8 -*-
############################################################################
#
#
############################################################################

module Questionnaire::Admin::OptionsHelper

  def option_form(form, item)
    #return '' unless item.class.include?(System::Model::Unid::Recognition)
    return render :partial => 'questionnaire/admin/menus/form_fields/options/form', :locals => {:f => form, :item => item}
  end

  def option_view(item)
    #return '' unless item.class.include?(System::Model::Unid::Recognition)
    return render :partial => 'questionnaire/admin/menus/form_fields/options/view', :locals => {:item => item}
  end

  def command_addrows(options={})
    link = tag(:input, { :type => "submit", :name => "command[addrow]", :value => "行追加" })
    return link
  end

  def option_list_array(id)
    item = Questionnaire::FormField.find_by_id(id)
    return [] if item.blank?
    return [] if item.option_body.blank?
    return JsonParser.new.parse(item.option_body_json)
  end

  #
  def option_template_list_array(id)
    item = Questionnaire::TemplateFormField.find_by_id(id)
    return [] if item.blank?
    return [] if item.option_body.blank?
    return JsonParser.new.parse(item.option_body_json)
  end

  def result_text_line_display(field_id)
    max_line = 5
    item = Questionnaire::Temporary.new
    item.and :title_id, @title.id
    item.and :field_id, field_id
    items = item.find(:all)
    ret = ''
    return ret if items.blank?
    rec_count = items.count
    i = 0
    for item in items
      i += 1
      ret = ret + %Q[<tr><td style="text-align: left;">#{item.answer_text}</td><tr>]
      if i == max_line
        ret = ret + "<table>"
        ret = ret + %Q[<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td style="text-align: left;"><a href="#" onclick="chageDisp(this,'field_id_#{field_id}');return false;">&nbsp;内容の続き……</a></td><tr>]
        ret = ret + "</table>"

        ret = ret + %Q[<table id="field_id_#{field_id}" class="index" style="display: none;">]
      end if max_line < rec_count
    end
    if max_line <= i
      ret = ret + "</table>"
    end if max_line < rec_count
    return ret
  end

  def result_group_line_display(field_id)
    max_line = 1
    item = Questionnaire::Temporary.new
    item.and :title_id, @title.id
    item.and :field_id, field_id
    items = item.find(:all)
    ret = ''
    return ret if items.blank?
    rec_count = items.count
    i = 0
    for item in items
      i += 1
      ret = ret + %Q[<tr><td style="text-align: left;">#{return_group_table(field_id, item.answer_text)}</td><tr>]
      if i == max_line
        ret = ret + "<table>"
        ret = ret + %Q[<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td style="text-align: left;"><a href="#" onclick="chageDisp(this,'field_id_#{field_id}');return false;">&nbsp;内容の続き……</a></td><tr>]
        ret = ret + "</table>"

        ret = ret + %Q[<table id="field_id_#{field_id}" class="index" style="display: none;">]
      end if max_line < rec_count
    end
    if max_line <= i
      ret = ret + "</table>"
    end if max_line < rec_count
    return ret
  end
  def return_group_table(field_id, answer_text)
    ret = ''
    return ret if answer_text.blank?
    answer_text = answer_text.gsub(/\r\n?/, '\\n')
    field_item = Questionnaire::FormField.find_by_id(field_id)
    return ret if field_item.blank?

    field_groups = answer_group_field_table(field_id)
    ret = %Q[<table class="index" border="0" cellspacing="0" cellpadding="0">]
    ret = "#{ret}#{field_groups[:table_th]}"
    group_values = ''
    group_values = JsonParser.new.parse(answer_text) unless answer_text.blank?
    group_repeat = 0
    group_repeat = field_item.group_repeat unless field_item.group_repeat.blank?
    for i in 1 .. group_repeat
      ret = "#{ret}<tr>"
      for group in field_groups[:groups]
        group_field_name = "#{field_item.field_name}_#{group['field_name']}"
        value = ''
        value = group_values[group_field_name] unless group_values[group_field_name].blank? unless group_values.blank?
        value = value[i-1]
        value = '　' if value.blank?
       ret = "#{ret}<td>#{value}</td>"
      end
      ret = "#{ret}</tr>"
    end if 0 < group_repeat
    ret = "#{ret}</table>"
    return ret.html_safe
  end

  def display_gruff(field_id, question_type)
    ret = ''
    return ret if question_type.index('text')
    return ret if question_type == 'display'

    item = Questionnaire::Result.new
    item.and :title_id, @title.id
    item.and :field_id, field_id
    item.order "option_id"
    items = item.find(:all)
    return ret if items.blank?

    check_total = 0
    ret = %Q[#{ret}<table  class="index" width="800" border="0" cellspacing="1" cellpadding="0">]
    ret = %Q[#{ret}<tr>]
    ret = %Q[#{ret}<th width="800" height="18" align="center" valign="middle">]
    ret = %Q[#{ret}<table width="795" height="16" border="0" cellpadding="0" cellspacing="0">]
    ret = %Q[#{ret}<tr>]

    for item in items
      next if item.answer_ratio == 0
      check_total += item.answer_ratio
      ret = %Q[#{ret}<td width="#{item.answer_ratio}%"  bgcolor="#{item.display_color_code}"></td>]
    end

    ret = %Q[#{ret}</tr>]
    ret = %Q[#{ret}</table></th>]
    ret = %Q[#{ret}</tr>]
    ret = %Q[#{ret}</table>]
    ret = '' if check_total == 0
    return ret
  end

  #通常
  def answer_group_field_table(field_id)
    ret = ''
    item = Questionnaire::FormField.find_by_id(field_id)
    return ret if item.blank?

    groups = []
    groups = JsonParser.new.parse(item.group_body_json) unless item.group_body.blank?
    table_th = ''
    for group in groups
      table_th = %Q[#{table_th}<th>#{group['field_label']}</th>]
    end
    table_th = "<tr>#{table_th}</tr>" unless table_th.blank?
    return {:groups=>groups,:table_th=>table_th.html_safe}
  end

  #template用
  def answer_group_field_table_template(field_id)
    ret = ''
    item = Questionnaire::TemplateFormField.find_by_id(field_id)
    return ret if item.blank?

    groups = []
    groups = JsonParser.new.parse(item.group_body_json) unless item.group_body.blank?
    table_th = ''
    for group in groups
      table_th = %Q[#{table_th}<th>#{group['field_label']}</th>]
    end
    table_th = "<tr>#{table_th}</tr>" unless table_th.blank?
    return {:groups=>groups,:table_th=>table_th.html_safe}
  end
end
