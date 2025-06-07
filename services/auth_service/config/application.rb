require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module AuthService
  class Application < Rails::Application
    config.load_defaults 8.0

    # Enable lib/ for autoloading and eager loading
    config.autoload_lib(ignore: %w[assets tasks])
    config.eager_load_paths << Rails.root.join("app/lib")

    config.api_only = true
  end
end
