require 'securerandom'
require 'active_support/all'
module Core
  class Parameters
    DEFAULT_REGION = 'us-east-1'.freeze
    DEFAULT_STACK = '64bit Amazon Linux 2016.09 v2.3.1 running Ruby 2.3 (Puma)'.freeze
    DEFAULT_ENGINE = 'postgres'.freeze
    DEFAULT_ALLOCATED_STORAGE = 30
    DEFAULT_DB_INSTANCE_CLASS = 'db.t2.micro'.freeze
    DEFAULT_ENVIRONMENT_NAME = 'stage'.freeze

    attr_reader :options, :environment, :project

    def initialize(project, options)
      @options = HashWithIndifferentAccess.new(options)
      @project = project
      set_default_options
    end

    def method_missing(m, *_args)
      return super if m.to_s.include?('=')
      options[m.to_s]
    end

    def respond_to_missing?
      super
    end

    def to_h
      { project: project }.merge(options)
    end

    def filter(valid_keys)
      filtered = options.select { |k, _v| valid_keys.include?(k) }
      HashWithIndifferentAccess.new(filtered)
    end

    private

    def set_default_options
      options[:region] ||= DEFAULT_REGION
      options[:profile] ||= project
      options[:application_name] ||= project
      options[:services] = options[:services].split(',')
      set_default_beanstalk_params
      set_default_rds_params
      set_redis_params
    end

    def set_default_beanstalk_params
      options[:environment_name] ||= DEFAULT_ENVIRONMENT_NAME
      options[:cname_prefix] = "#{application_name}-#{environment_name}"
      options[:identifier] = options[:cname_prefix]
      options[:solution_stack_name] ||= DEFAULT_STACK
    end

    # rubocop:disable Metrics/AbcSize
    def set_default_rds_params
      options[:engine] ||= DEFAULT_ENGINE
      options[:allocated_storage] ||= DEFAULT_ALLOCATED_STORAGE
      options[:master_user_password] ||= SecureRandom.hex(10)
      options[:db_instance_class] ||= DEFAULT_DB_INSTANCE_CLASS
      options[:db_instance_identifier] ||= "#{application_name}-#{environment_name}"
      options[:master_username] ||= db_instance_identifier.gsub('-', '_')
      options[:db_name] ||= application_name.gsub('-', '_')
    end
    # rubocop:enable Metrics/AbcSize

    def set_redis_params
      options[:cache_node_type] ||= 'cache.t2.small'
    end
  end
end
