# -*- encoding: utf-8 -*-
class Gwworkflow::File < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Cms::Model::Base::Content
  include Gwboard::Model::AttachFile
  include Gwboard::Model::AttachesFile
  include Gwworkflow::Model::Systemname

#  belongs_to :status, :foreign_key => :state,     :class_name => 'Sys::Base::Status'
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Gwbbs::Doc'

  before_create :before_create
  after_create :after_create
  after_destroy :after_destroy
  validates_presence_of :filename, :message => "ファイルが指定されていません。"

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'kwd'
        and_keywords v, :filename
      end
    end if params.size != 0

    return self
  end

  def item_path
    return "#{Site.current_node.public_uri.chop}?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end

  def edit_memo_path(title,item)
    return "#{Site.current_node.public_uri}#{self.parent_id}/edit_file_memo/#{self.id}?title_id=#{self.title_id}"
  end

  def item_parent_path
    return "#{Site.current_node.public_uri}#{self.parent_id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}"
  end

  def item_doc_path(title,item)
    return "#{Site.current_node.public_uri}#{self.parent_id}?title_id=#{self.title_id}"
  end

  def delete_path
    return "#{Site.current_node.public_uri}#{self.id}/delete?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end

end
