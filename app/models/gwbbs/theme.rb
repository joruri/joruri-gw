class Gwbbs::Theme < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwbbs::Model::Systemname

  belongs_to :board , :foreign_key => :board_id  ,:class_name=>'Gwbbs::Control'
  belongs_to :theme , :foreign_key => :theme_id  ,:class_name=>'Gwboard::Theme'

  def item_path
    return "#{Core.current_node.public_uri}"
  end

  def show_path
    return "#{self.item_path}#{self.id}"
  end

  def edit_path
    return "#{self.item_path}#{self.id}/edit"
  end

  def delete_path
    return "#{self.item_path}#{self.id}"
  end

  def board_css_file_path
    return "#{RAILS_ROOT}/public/_attaches/css/#{self.system_name}"
  end

  def board_css_preview_path
    return "#{RAILS_ROOT}/public/_attaches/css/preview/#{self.system_name}"
  end

  def board_css_preview_url
    return "/_attaches/css/preview/#{self.system_name}"
  end


end
