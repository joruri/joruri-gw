module System::Model::Base::ActsAsTreeExtension
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_tree(options = {})
      super(options)
      # fix order
      define_singleton_method :default_tree_order do
        order(options[:order] || nil)
      end
      # fix traverse order
      define_method :descendants do |arr = []|
        children.each { |child| arr << child; child.descendants(arr) }
        arr
      end
    end
  end
end
