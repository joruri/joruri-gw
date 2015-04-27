class Questionnaire::Result < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Questionnaire::Model::Systemname

  def color_code
    ['white','red','lime','blue','yellow','aqua','fuchsia','silver','white','gray','maroon','green','navy','olive','teal','purple','black']
  end

  def display_color_code
    color_code[option_id%16]
  end
end
