module Towncrier
  class Engine < Rails::Engine

    initializer "Include Towncrier gem only after Rails boot" do |app|
      require 'towncrier/config'
      require 'towncrier/base'
      require 'towncrier/observer'
      require 'towncrier/targets'
      require 'towncrier/cry'
      require 'towncrier/eagerloader'
      require 'towncrier/active_record_extensions'
      require 'towncrier/workers/resque'
      require 'towncrier/workers/sidekiq'

      ActionDispatch::Callbacks.to_prepare do
        Towncrier::Eagerloader.load_criers
      end
    end

  end
end