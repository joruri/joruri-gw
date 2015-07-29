class Util::Tree
  @@loop = 0
  
  def self.climb(id, options = {})
    @@loop = 0
    tree = []
    while current = options[:class].find(id)
      tree.unshift(current)
      id = current.parent_id
      @@loop += 1
      raise 'infinite loop' if @@loop > 100
    end
    return tree
  rescue ActiveRecord::RecordNotFound
    return tree
  end
  
  def self.down(id, options = {})
    
  end
end
