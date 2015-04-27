class Gw::UserProperty < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  def options_value
    decoded
  end

  def options_value=(value)
    encode!(value)
  end

  def default_attributes
    {}
  end

  def default_options
    {}
  end

  def defaults
    self.attributes = default_attributes
    self.options_value = default_options
  end

  def self.first_or_new
    self.first || self.new.tap(&:defaults)
  end

  private

  def encode(value)
    if default_options.is_a?(Hash)
      JSON.generate(default_options.deep_stringify_keys.deep_merge(value))
    else
      JSON.generate(value)
    end
  end

  def encode!(value = decoded)
    self.options = encode(value)
    remove_instance_variable(:@decoded) if instance_variable_defined?(:@decoded)
  end

  def decode
    if default_options.is_a?(Hash)
      default_options.deep_stringify_keys.deep_merge(JSON.parse(options)).with_indifferent_access rescue nil
    else
      JSON.parse(options) rescue nil
    end
  end

  def decoded
    return @decoded if defined? @decoded
    @decoded = decode
  end
end
