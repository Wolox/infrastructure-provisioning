require_relative './parameters'
require_relative './elastic_beanstalk/builder'
require_relative './rds/builder'
require_relative './service_finder'

module Core
  class Backend
    attr_reader :project, :options, :parameters

    def initialize(project, options)
      @options = options
      @project = project
      @parameters = Core::Parameters.new(project, options)
    end

    def create
      environment = create_beanstalk_environment
      services = Core::ServiceFinder.new.load_services(parameters)
      services.each do |service|
        service.create
        service.allow_access_from(environment)
      end
    end

    def show_stacks
      puts ElasticBeanstalk::Builder.new(parameters).show_stacks
    end

    private

    def create_beanstalk_environment
      environment = Core::ElasticBeanstalk::Builder.new(parameters).create
      environment
    end
  end
end
