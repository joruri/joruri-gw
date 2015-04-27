module Gw::Model::Cache::EditLinkPiece
  extend ActiveSupport::Concern

  included do
    after_commit :touch_edit_link_pieces # for cache expiration
  end

  private

  def touch_edit_link_pieces
    Gw::EditLinkPiece.where(level_no: 2).update_all(updated_at: Time.now)
  end
end
