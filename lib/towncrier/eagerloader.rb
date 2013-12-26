module Towncrier
  class Eagerloader

    def self.load_criers
      if Towncrier::Base.descendants.empty? && criers_directory_exists?
        Dir[Rails.root.join("app/criers/*.rb")].each do |file|
          require_dependency file
        end
      end
    end

    def self.criers_directory_exists?
      File.directory?(Rails.root.join("app/criers"))
    end

  end
end