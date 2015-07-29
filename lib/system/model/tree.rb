# encoding: utf-8
module System::Model::Tree
  def parent_tree(options = {})
    Util::Tree.climb(id, :class => self.class)
  end
end
