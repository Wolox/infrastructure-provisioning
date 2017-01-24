require_relative './rds/builder'
require_relative './redis/builder'

module Core
  class ServiceFinder
    VALID_SERVICES = %w(rds redis)

    def load_services(services, project, parameters)
      services = services.select { |s| VALID_SERVICES.include?(services.to_s) }
      services.map(&:capitalize).map do |service|
        Object.const_get("Core::#{service}::Builder").new(project, parameters)
      end
    end
  end
end
