require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)
require 'web-console-rails3'

# Require pry-rails if the pry shell is explicitly requested.
require 'pry-rails' if ENV['PRY']

module Dummy
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Don't bother with attributes whitelisting. Force strong parameters.
    config.active_record.whitelist_attributes = false

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # When the Dummy application is ran in a docker container, the local
    # computer address is in the 172.16.0.0/12 range. Have it whitelisted.
    config.web_console.whitelisted_ips = %w( 127.0.0.1 172.16.0.0/12 )

    if ENV['LONG_POLLING']
      # You have to explicitly enable the concurrency, as in development mode,
      # the falsy config.cache_classes implies no concurrency support.
      #
      # The concurrency is enabled by removing the Rack::Lock middleware, which
      # wraps each request in a mutex, effectively making the request handling
      # synchronous.
      config.allow_concurrency = true

      # For long-polling 45 seconds timeout seems reasonable.
      config.web_console.timeout = 45.seconds
    end
  end
end

