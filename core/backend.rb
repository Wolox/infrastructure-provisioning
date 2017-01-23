require_relative './parameters'
require_relative './elastic_beanstalk/builder'
require_relative './rds/builder'

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
      database = create_rds_instance
      allow_access_to_db(database, environment)
    end

    def show_stacks
      ElasticBeanstalk::Builder.new(parameters).show_stacks
    end

    private

    def allow_access_to_db(database, environment)
    end

    def create_rds_instance
      database = Rds::Builder.new(parameters).create
      puts "Database created: #{database.to_h}"
      database
    end

    def create_beanstalk_environment
      environment = Core::ElasticBeanstalk::Builder.new(parameters).create
      puts "Beanstalk created: #{environment.to_h}"
      environment
    end
  end
end
