module System::Model::Base::Validation
  extend ActiveSupport::Concern

  included do
    if table_exists?
      columns.each do |column|
        validates column.name, length: { maximum: column.limit } if column.type == :string
      end
    end
  end
end
