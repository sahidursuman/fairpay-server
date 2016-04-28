require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/jsonp'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# could be enabled if needed
#Dotenv::Railtie.load

module FairpayServer
  class Application < Rails::Application

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post]
      end
    end


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.


    # Additional paths to autoload
    config.autoload_paths << "#{Rails.root}/lib"


    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.middleware.use Rack::JSONP
    config.middleware.use "Rack::MultiTenantRack"

  end
end

puts "Rails.env: #{Rails.env}"
puts "database: #{FairpayServer::Application.config.database_configuration[::Rails.env]['database']}"  rescue nil
puts "base url: #{ENV['BASE_URL']}"
