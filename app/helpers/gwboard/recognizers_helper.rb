module Gwboard::RecognizersHelper

  def gwboard_recognizer_form(form, item)
    return render(:partial => 'gwboard/admin/recognizers/form', :locals => {:f => form, :item => item})
  end

  def gwboard_recognizer_form_type2(form, item)
    return render(:partial => 'gwboard/admin/recognizers/form_type2', :locals => {:f => form, :item => item})
  end

  def gwboard_state_to_partial_name
    ret = 'show_header_normal'
    case params[:state].to_s
    when "RECOGNIZE"
      ret =  'show_header_recognize'
    when "PUBLISH"
      ret =  'show_header_publish'
    end
    return ret
  end

end
