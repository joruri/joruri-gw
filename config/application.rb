require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JoruriGw
  class Application < Rails::Application
    require "#{Rails.root}/lib/joruri"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :ja
    Dir::entries("#{Rails.root}/config/modules").each do |mod|
      next if mod =~ /^\./
      Dir::glob("#{Rails.root}/config/modules/#{mod}/locales/*.yml").each do |file|
        config.i18n.load_path << file if FileTest.exist?(file)
      end
    end
    config.x = ActiveSupport::OrderedOptions.new
    Dir::entries("#{Rails.root}/config/modules").each do |mod|
      next if mod =~ /^\./
      config.x[mod] = ActiveSupport::OrderedOptions.new
      Dir::glob("#{Rails.root}/config/modules/#{mod}/settings/*.yml").each do |file|
        next unless FileTest.exist?(file)
        YAML.load_file(file)[Rails.env].each do |k, v|
          config.x[mod][k] = v.is_a?(Hash) ? v.with_indifferent_access : v
        end
      end
    end
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]


    config.action_view.sanitized_allowed_tags = ActionView::Base.sanitized_allowed_tags.to_a | %w(table caption tr th td iframe)
    config.action_view.sanitized_allowed_attributes = ActionView::Base.sanitized_allowed_attributes.to_a | %w(style class href src alt title colspan rowspan target id)


    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types

    # config.active_record.schema_format = :sql
    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = false
  end
end

AppConfig = Rails.application.config.x
