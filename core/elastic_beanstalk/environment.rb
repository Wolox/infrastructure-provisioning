require_relative './instance'
module Core
  module ElasticBeanstalk
    class Environment
      VALID_OPTIONS = [:application_name, :environment_name, :group_name, :description,
                       :cname_prefix, :tier, :tags, :version_label, :template_name,
                       :solution_stack_name, :option_settings, :options_to_remove]
      attr_reader :client, :options

      def initialize(options)
        @options = options
        build_client
        sanitize_options
      end

      def create
        return fetch_environment if environment_exists?
        puts "Creating environment with options: #{options}"
        client.create_environment(options_for_create)
      end

      def fetch_environment
        client.describe_environments(
          application_name: application_name,
          environment_names: [environment_name]
        ).environments.first
      end

      def fetch_instance
        puts "Fetching instance for environment: #{options[:environment_name]}"
        res = client.describe_environment_resources(environment_name: options[:environment_name])
        instance_id = res.environment_resources.instances.first.id
        ElasticBeanstalk::Instance.new(options).fetch_instance(instance_id)
      end

      private

      def build_client
        @client = Aws::ElasticBeanstalk::Client.new(
          profile: options[:profile],
          region: options[:region]
        )
      end

      def options_for_create
        options.select { |k, _v| VALID_OPTIONS.include?(k) }
      end

      def sanitize_options
        options[:environment_name] ||= application_name
        options[:cname_prefix] = options[:environment_name]
        options[:solution_stack_name] ||= DEFAULT_STACK
      end

      def solution_stack_name
        options[:solution_stack_name]
      end

      def environment_exists?
        envs = client.describe_environments(application_name: application_name).environments
        envs = envs.select { |e| e[:status] != 'Terminated' }
        envs.map(&:environment_name).include?(environment_name)
      end

      def application_name
        options[:application_name]
      end

      def cname_prefix
        options[:cname_prefix]
      end

      def environment_name
        options[:environment_name]
      end
    end
  end
end
