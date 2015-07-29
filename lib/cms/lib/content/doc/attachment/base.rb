class Cms::Lib::Content::Doc::Attachment::Base < Cms::Lib::Base

  attr_accessor :content, :doc

  def dependent_condition(doc_id)
    where("doc_id = ?", doc_id)
  end

  def condition_to_edit(user_id)
    where("creator_user_id = ?", user_id)
  end
end