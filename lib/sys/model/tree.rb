module Sys::Model::Tree
  def parents_tree(options = {})
    climb_parents_tree(id, :class => self.class)
  end
  
private
  def climb_parents_tree(id, options = {})
    tree = []
    while current = options[:class].find_by_id(id)
      tree.unshift(current)
      id = current.parent_id
    end
    return tree
  end
end
