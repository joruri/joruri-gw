############################################################################
#
#
############################################################################

module Questionnaire::Admin::EnqueteHelper

  def enquete_link_url(item, is_state_view)
    if is_state_view
      item.enquete_path
    else
      new_enquete_answer_path(item)
    end
  end
end
