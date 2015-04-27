class Gwworkflow::File < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::File::Base
  include Gwworkflow::Model::Systemname

  belongs_to :doc, foreign_key: :parent_id
  belongs_to :parent, foreign_key: :parent_id, class_name: 'Gwworkflow::Doc'
  belongs_to :control, :foreign_key => :title_id

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
end
