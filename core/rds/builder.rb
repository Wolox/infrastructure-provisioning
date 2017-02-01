require 'aws-sdk'
require_relative '../security_group'

module Core
  module Rds
    class Builder
      attr_reader :parameters, :client
      VALID_OPTIONS = ['allocated_storage', 'db_instance_identifier', 'engine',
                       'master_user_password', 'master_username', 'db_instance_class',
                       'db_name'].freeze

      def initialize(parameters)
        @parameters = parameters
        init_client
      end

      def create
        create_database unless db_exists?
        wait_db
        fetch_db_instance
      end

      def fetch_db_instance
        identifier = parameters.db_instance_identifier
        resp = client.describe_db_instances(db_instance_identifier: identifier).to_h
        resp[:db_instances].first
      end

      def allow_access_from(environment)
        sg_builder = Core::SecurityGroup.new(parameters)
        sg_id = fetch_db_instance[:vpc_security_groups].first[:vpc_security_group_id]
        source_group = environment[:security_group].group_name
        sg_builder.allow_access(sg_id, source_group, 5432, 5432, 'tcp')
      rescue Aws::EC2::Errors::InvalidPermissionDuplicate
      end

      private

      def db_exists?
        fetch_db_instance
        true
      rescue Aws::RDS::Errors::DBInstanceNotFound
        return false
      end

      def wait_db
        puts 'Wating for db...'
        client.wait_until(:db_instance_available) do |w|
          # disable max attempts
          w.max_attempts = nil

          # poll for 1 hour, instead of a number of attempts
          w.before_wait do |attempts, _response|
            puts "Still waiting for database - #attempts: #{attempts}"
          end
        end
      end

      def create_database
        puts 'Creating database...'
        group_id = create_security_group
        client.create_db_instance(creation_options.merge(vpc_security_group_ids: [group_id]))
      end

      def create_security_group
        sg_builder = Core::SecurityGroup.new(parameters)
        resp = sg_builder.create_security_group('rds')
        resp.group_id
      end

      def creation_options
        parameters.filter(VALID_OPTIONS)
      end

      def init_client
        @client = Aws::RDS::Client.new(region: parameters.region, profile: parameters.profile)
      end
    end
  end
end
