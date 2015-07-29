# -*- encoding: utf-8 -*-
############################################################################
#
#
############################################################################

module Questionnaire::Admin::EnqueteHelper

  def show_enquete_help(help_no, array_help=nil)
    array_help = get_enquete_help if array_help.blank?
    ret = array_help[help_no]
    unless ret.blank?
      ret = ret[0].html_safe
    end
    return ret
  end


  def get_enquete_help
    item = Gw::UserProperty.new
    item.and :class_id, 3
    item.and :name, 'enquete'
    item.and :type_name, 'help_link'
    help = item.find(:first)
    array_help = Array.new(10, "")
    array_help = JsonParser.new.parse(help.options) unless help.blank?
    return array_help
  end

end
