module Core
  class Parameters
    DEFAULT_REGION = 'us-east-1'
    DEFAULT_STACK = '64bit Amazon Linux 2016.09 v2.3.0 running Ruby 2.3 (Puma)'

    attr_reader :options, :environment, :project

    def initialize(project, options)
      @options = options
      @project = project
      set_default_options
      initialize_clients
    end

    def method_missing(m, *args, &block)
      options[m]
    end

    private

    def set_default_options
      options[:application_name] ||= project
      options[:environment_name] ||= options[:application_name].gsub(' ', '-')
      options[:region] ||= DEFAULT_REGION
      options[:profile] ||= project
      options[:cname_prefix] = options[:environment_name]
      options[:solution_stack_name] ||= DEFAULT_STACK
    end
  end
end
