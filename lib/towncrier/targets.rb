module Towncrier
  module Targets

    def acts_as_towncrier_targets
      has_many :towncries, as: :target, dependent: :destroy
      before_save :set_towncrier_token

      include InstanceMethods
    end


    module InstanceMethods

      def set_towncrier_token
        unless towncrier_token.present?
          begin
            self.towncrier_token = SecureRandom.hex
          end while self.class.exists?(towncrier_token: towncrier_token)
        end
      end

      def towncrier_channel
        "/towncrier-#{towncrier_token}"
      end

    end

  end
end

ActiveRecord::Base.extend(Towncrier::Targets)