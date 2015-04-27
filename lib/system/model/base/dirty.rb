module System::Model::Base::Dirty
  def changing_attributes
    attributes.slice(*changed)
  end
end
