require_relative './instance'
module Core
  module ElasticBeanstalk
    class Environment
      VALID_OPTIONS = ['application_name', 'environment_name', 'group_name', 'description',
                       'cname_prefix', 'tier', 'tags', 'version_label', 'template_name',
                       'solution_stack_name', 'option_settings', 'options_to_remove'].freeze
      attr_reader :client, :parameters

      def initialize(parameters)
        @parameters = parameters
        build_client
      end

      def create
        return fetch_environment if environment_exists?
        puts "Creating environment with options: #{options_for_create}"
        client.create_environment(options_for_create)
      end

      def fetch_environment
        client.describe_environments(
          application_name: parameters.application_name,
          environment_names: [parameters.environment_name]
        ).environments.first
      end

      def fetch_instance
        puts "Fetching instance for environment: #{parameters.environment_name}"
        res = client.describe_environment_resources(environment_name: parameters.environment_name)
        instance_id = res.environment_resources.instances.first.id
        ElasticBeanstalk::Instance.new(parameters).fetch_instance(instance_id)
      end

      def list_available_solution_stacks
        client.list_available_solution_stacks.solution_stacks
      end

      private

      def build_client
        @client = Aws::ElasticBeanstalk::Client.new(
          profile: parameters.profile,
          region: parameters.region
        )
      end

      def options_for_create
        parameters.filter(VALID_OPTIONS)
      end

      def environment_exists?
        envs = client.describe_environments(
          application_name: parameters.application_name
        ).environments
        envs = envs.select { |e| e[:status] != 'Terminated' }
        envs.map(&:environment_name).include?(parameters.environment_name)
      end
    end
  end
end
