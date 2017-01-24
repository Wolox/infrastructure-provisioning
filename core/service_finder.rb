require_relative './rds/builder'
require_relative './redis/builder'
require 'byebug'

module Core
  class ServiceFinder
    VALID_SERVICES = %w(rds redis)

    def load_services(services, parameters)
      services = services.select { |s| VALID_SERVICES.include?(s.to_s) }
      services.map(&:capitalize).map do |service|
        Object.const_get("Core::#{service}::Builder").new(parameters)
      end
    end
  end
end
