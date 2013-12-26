module Towncrier
  module Targets

    def acts_as_towncrier_targets
      has_many :towncries, as: :target, dependent: :destroy
      before_save :set_towncry_token

      include InstanceMethods
    end


    module InstanceMethods

      def set_towncry_token
        unless towncry_token.present?
          begin
            self.towncry_token = SecureRandom.hex
          end while self.class.exists?(towncry_token: towncry_token)
        end
      end

      def towncry_channel
        "/towncry-#{towncry_token}"
      end

    end

  end
end

ActiveRecord::Base.extend(Towncrier::Targets)