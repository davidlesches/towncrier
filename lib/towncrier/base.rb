module Towncrier
  class Base

    CRIERS = []
    RESERVED_NAMES = %w( Towncry TownCry )

    def self.inherited klass
      model_name = klass.name.gsub('Crier', '')
      if RESERVED_NAMES.include?(model_name)
        warn "#{klass} is a reserved name and cannot be used to define a Crier."
      else
        CRIERS << model_name
        model_name.constantize.class_eval 'has_many :towncries, as: :crier, dependent: :destroy'
      end
    end

    def self.emitters
      @emitters
    end

    def self.on *args, &block
      options = args.extract_options!
      @emitters ||= []
      @emitters << { on: args, options: options, block: block }
    end

    def self.create_cries(id, action)
      emitters.each do |emitter|
        next unless emitter[:on].include?(action.to_sym)
        object = model_class.constantize.find(id)
        cry = Towncrier::Cry.new(action: action, name: model_class, options: emitter[:options], _object: object)
        cry.define_singleton_method(model_class.underscore) do
          object
        end
        cry.instance_eval(&emitter[:block])
        cry.cry
      end
    end

    def self.model_class
      self.name.gsub('Crier', '')
    end

  end
end