module Towncrier
  module Workers
    class Sidekiq

      if defined?(::Sidekiq)
        include ::Sidekiq::Worker
      end

      def perform(klass, id, action)
        "#{klass}_crier".classify.constantize.create_cries(id, action)
      end

    end
  end
end