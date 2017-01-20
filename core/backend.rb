require_relative './parameters'
require_relative './elastic_beanstalk/builder'

module Core
  class Backend
    attr_reader :project, :options, :parameters

    def initialize(project, options)
      @options = options
      @project = project
      @parameters = Core::Parameters.new(project, options)
    end

    def create
      create_beanstalk_environment
    end

    def show_stacks
      ElasticBeanstalk::Builder.new(parameters).show_stacks
    end

    private

    def create_beanstalk_environment
      Core::ElasticBeanstalk::Builder.new(parameters).create
    end
  end
end
