module Core
  class Backend
    attr_reader :project, :options

    def initialize(project, options)
      @options = options
      @project = project
      @parameters = Parameters.new(project, options)
    end

    def create
      create_beanstalk_environment
    end

    def show_stacks
      ElasticBeanstalk::Builder.new(project, {}).show_stacks
    end

    private

    def create_beanstalk_environment
      ElasticBeanstalk::Builder.new(project, options).create
    end
  end
end
