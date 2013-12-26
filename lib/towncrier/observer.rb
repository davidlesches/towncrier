module Towncrier
  class Observer

    attr_reader :payload

    ActiveSupport::Notifications.subscribe('towncry') do |_, _, _, _, payload|
      new(payload)
    end

    def initialize payload
      @payload = payload
      setup_cries if create_cries?
    end

    def create_cries?
      Towncrier::Config.enabled && Towncrier::Base::CRIERS.include?(payload[:class])
    end

    def setup_cries
      send("setup_#{async_type}_cries")
    rescue
      raise if Towncrier::Config.raise_errors
    end

    def async_type
      Towncrier::Config.background_worker
    end

    def setup_sidekiq_cries
      Towncrier::Workers::Sidekiq.perform_async(payload[:class], payload[:id], payload[:action])
    end

    def setup_resque_cries
      Resque.enqueue(Towncrier::Workers::Resque, payload[:class], payload[:id], payload[:action])
    end

    def setup_false_cries
      "#{payload[:class]}_crier".classify.constantize.create_cries(payload[:id], payload[:action])
    end

  end
end