module Towncrier
  class Cry

    attr_accessor :action, :name, :options, :_object

    def initialize args
      args.each do |key, value|
        send("#{key}=", value)
      end
    end

    def target target
      @target = Array(target).flatten.compact.uniq
    end

    def payload payload
      @payload = payload
    end

    def record?
      !options[:record].nil? ? options[:record] : true
    end

    def official_name
      (options[:as] || name).to_s.classify
    end

    def validate
      if @target.nil?
        raise NotImplementedError, "You forgot to define 'target' in your #{name} crier."
      end

      if @payload.nil?
        raise NotImplementedError, "You forgot to define 'payload' in the #{name} crier."
      end
    end

    def cry
      validate
      @target.each do |t|
        push_notification(t)
        save_notification(t)
      end
    end

    def push_notification target
      PrivatePub.publish_to(target.towncrier_channel, "towncrier.hear('#{official_name}', '#{action}', '#{@payload.to_json}')")
    end

    def save_notification target
      Towncry.create!(
        :name    => official_name,
        :target  => target,
        :crier   => _object,
        :action  => action,
        :payload => @payload
      ) if record?
    end

    def crier_class
      "#{name}_crier".classify.constantize
    end

  end
end