module Towncrier
  class Config < ::Rails::Engine

    class_attribute :enabled, :raise_errors, :background_worker
    self.enabled = true
    self.raise_errors = false
    self.background_worker = :sidekiq

    def self.load_config
      YAML.load_file(config_file_path)[Rails.env].each do |key, value|
        if valid_config_values[ key.to_sym ] && valid_config_values[ key.to_sym ].include?(value)
          self.send("#{key}=", value)
        else
          warn "Towncrier WARNING: The key/value specified in towncrier.yml for '#{key}' is an invalid option and is being ignored."
        end
      end
    end

    def self.config_file_path
      File.join(Rails.root, '/config/towncrier.yml')
    end

    def self.config_file_exists?
      File.exist?(config_file_path) &&
      YAML.load_file(config_file_path) &&
      !YAML.load_file(config_file_path)[Rails.env].nil?
    end

    def self.valid_config_values
      {
        :enabled           => [ true, false ],
        :raise_errors      => [ true, false ],
        :background_worker => [ false, :sidekiq, :resque ]
      }
    end

    if config_file_exists?
      load_config
    else
      warn 'Towncrier WARNING: towncrier.yml config file could not be found, or is missing values. Please see wiki to generate config file.'
    end

  end
end