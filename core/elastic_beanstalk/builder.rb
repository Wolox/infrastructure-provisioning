require 'aws-sdk'
require_relative './application'
require_relative './environment'
require 'byebug'

module Core
  module ElasticBeanstalk
    class Builder

      attr_reader :client, :project, :options, :application_client, :environment_client

      def initialize(project, options)
        @project = project
        @options = options
        set_default_options
        init_client
      end

      def create
        application = create_application
        environment = create_environment
        security_group = fetch_instance_security_group
        { environment: environment.to_h, security_group: security_group }
      end

      def create_environment
        environment_client.create
        wait_for_environment('Ready')
      end

      def create_application
        application_client.create
      end

      def show_stacks
        client.list_available_solution_stacks.solution_stacks
      end

      private

      def fetch_instance_security_group
        instance = environment_client.fetch_instance
        instance.security_groups.first
      end

      def wait_for_environment(status)
        environment = environment_client.fetch_environment
        if environment.status != status
          puts "Wating for environment status: #{status}. Current status: #{environment.status}"
          sleep 5
          wait_for_environment(status)
        end
        environment
      end

      def set_default_options
        options[:application_name] ||= project
        options[:environment_name] ||= options[:application_name].gsub(' ', '-')
        options[:region] ||= DEFAULT_REGION
        options[:profile] ||= project
      end

      def init_client
        @environment_client = ElasticBeanstalk::Environment.new(options)
        @application_client = ElasticBeanstalk::Application.new(options)
      end
    end
  end
end
