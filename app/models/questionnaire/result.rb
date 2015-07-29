class Questionnaire::Result < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Questionnaire::Model::Systemname

  def color_code
    #
    return ['white','red','lime','blue','yellow','aqua','fuchsia','silver','white','gray','maroon','green','navy','olive','teal','purple','black']
  end

  def display_color_code
    i = self.option_id
    i = 0 if 16 < i
    return self.color_code[i]
  end
end
