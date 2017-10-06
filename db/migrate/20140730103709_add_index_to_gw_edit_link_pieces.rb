class AddIndexToGwEditLinkPieces < ActiveRecord::Migration
  def change
    add_index :gw_edit_link_pieces, [:published, :state, :sort_no],
      name: 'idx_gw_edit_link_pieces',
      length: { published: 50, state: 50 }
  end
end