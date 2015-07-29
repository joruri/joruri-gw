class Cms::Lib::Piece::Base < Cms::Lib::Base

  attr_accessor :piece


  def dependent_condition(piece_id)
    where("piece_id = ?", piece_id)
  end

  def condition_to_edit(user_id)
    where("creator_user_id = ?", user_id)
  end

  def condition_in_public
    where("state_no = ?", 1)
  end
end