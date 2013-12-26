module Towncrier
  module Workers
    class Resque

      @queue = :default

      def self.perform(klass, id, action)
        "#{klass}_crier".classify.constantize.create_cries(id, action)
      end

    end
  end
end