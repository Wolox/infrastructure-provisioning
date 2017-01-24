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
      services = Core::ServiceFinder.new.load_services(%w(rds redis))
      services.each do |service|
        service.create
        service.allow_access_from(environment, ec2_client)
      end
    end

    def show_stacks
      puts ElasticBeanstalk::Builder.new(parameters).show_stacks
    end

    private

    def ec2_client
      @ec2_client ||= Aws::EC2::Client.new(
        region: parameters.region,
        profile: parameters.profile
      )
    end
    
    def create_beanstalk_environment
      environment = Core::ElasticBeanstalk::Builder.new(parameters).create
      puts "Beanstalk created: #{environment.to_h}"
      environment
    end
  end
end
