class Towncry < ActiveRecord::Base

  # Associations
  belongs_to :target, polymorphic: true
  belongs_to :crier, polymorphic: true

  # Serializers
  serialize :payload, JSON

end
