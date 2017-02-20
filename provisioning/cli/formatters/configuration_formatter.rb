require 'awesome_print'
module Cli
  module Formatters
    class ConfigurationFormatter
      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def print
        configuration_hash = format_configuration
        ap configuration_hash, indent: -2
      end

      private

      def format_configuration
        config_hash = {}
        config_hash[:beanstalk] = add_beanstalk_configuration
        config_hash[:rds] = add_rds_configuration
        config_hash
      end

      def add_beanstalk_configuration
        {
          application: configuration.application_name,
          environment: configuration.environment_name,
          solution_stack_name: configuration.solution_stack_name
        }
      end

      def add_rds_configuration
        {
          engine: configuration.engine,
          username: configuration.master_username,
          password: configuration.master_user_password,
          identifier: configuration.db_instance_identifier,
          database_name: configuration.db_name
        }
      end
    end
  end
end
