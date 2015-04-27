class Gw::PropExtraPmRenewalGroup < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  def self.get_present_gids(gid = Core.user_group.id)
    group_ids = Array.new
    items = self.where("incoming_group_id = #{gid}")

    # 1つ前の所属を取得する
    items.each do |item|
      group_ids << item.present_group_id
    end

    # 2つ前の所属を取得する
    group_ids.each do |group_id|
      items = self.where("incoming_group_id = #{group_id}")
      items.each do |item|
        group_ids << item.present_group_id
      end
    end

    return group_ids
  end
end
