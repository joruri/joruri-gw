require 'memoist'
module System::Model::Base
  extend ActiveSupport::Concern
  include System::Model::Base::ConditionBuilder
  include System::Model::Base::Scope
  include System::Model::Base::Dirty
  include System::Model::Base::ActsAsTreeExtension
  include System::Model::Serializer::Csv

  included do
    self.table_name = self.to_s.underscore.gsub('/', '_').downcase.pluralize unless table_exists?
    extend Memoist
    include System::Model::Base::Validation
  end

  def locale(name)
    self.class.human_attribute_name(name)
  end

  def to_xml(options = {})
    options[:dasherize] = false
    super
  end

  module ClassMethods
    def locale(name)
      human_attribute_name(name)
    end

    def truncate_table
      self.connection.execute("TRUNCATE TABLE #{self.table_name}")
    end

    def optimize_table
      self.connection.execute("OPTIMIZE TABLE #{self.table_name}")
    end

    def analyze_table
      self.connection.execute("ANALYZE TABLE #{self.table_name}")
    end

    def optimize_and_analyze_table
      optimize_table && analyze_table
    end
  end
end
