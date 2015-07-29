# encoding: utf-8
module Joruri
  def self.version
    "2.3.1"
  end

  def self.default_config
    { "application" => {
        "sys.login_footer"                       => "",
        "sys.mobile_footer"                      => "",
        "sys.session_expiration"                 => 24,
        "sys.session_expiration_for_mobile"      => 1,
        "sys.force_site"                         => ""
    }}
  end

  def self.config
    $joruri_config ||= {}
    Joruri::Config
  end

  class Joruri::Config
    def self.application
      config = Joruri.default_config["application"]
      file   = "#{Rails.root}/config/application.yml"
      if ::File.exist?(file)
        yml = YAML.load_file(file)
        yml.each do |mod, values|
          values.each do |key, value|
            config["#{mod}.#{key}"] = value unless value.nil?
          end if values
        end if yml
      end
      $joruri_config[:application] = config
    end

    def self.imap_settings
      $joruri_config[:imap_settings]
    end

    def self.imap_settings=(config)
      $joruri_config[:imap_settings] = config
    end

    def self.sso_settings
      $joruri_config[:sso_settings]
    end

    def self.sso_settings=(config)
      $joruri_config[:sso_settings] = config
    end
  end
end