require 'aws-sdk'
require_relative '../security_group'

module Core
  module Redis
    class Builder
      attr_reader :parameters, :client

      def initialize(parameters)
        @parameters = parameters
        init_client
      end

      def create
        create_cache_cluster unless cache_cluster_exists?
        wait_for_cluster
        fetch_cluster
      end

      def allow_access_from(environment)
        sg_builder = Core::SecurityGroup.new(parameters)
        sg_id = fetch_cluster.security_groups.first.security_group_id
        source_group = environment[:security_group].group_name
        sg_builder.allow_access(sg_id, source_group, 6379, 6379, 'tcp')
      end

      private

      def fetch_cluster
        clusters = client.describe_cache_clusters(cache_cluster_id: parameters.identifier[0..19])
        clusters.cache_clusters.first
      rescue Aws::ElastiCache::Errors::CacheClusterNotFound => e
        puts e
        nil
      end

      def cache_cluster_exists?
        fetch_cluster != nil
      end

      def create_cache_cluster
        puts "Creating redis cluster..."
        sg_id = create_security_group
        client.create_cache_cluster(
          cache_cluster_id: parameters.identifier[0..19],
          cache_node_type: parameters.cache_node_type,
          engine: 'redis',
          num_cache_nodes: 1,
          security_group_ids: [sg_id]
        )
      end

      def create_security_group
        sg_builder = Core::SecurityGroup.new(parameters)
        resp = sg_builder.create_security_group('redis')
        resp.group_id
      end

      def wait_for_cluster
        puts 'Wating for redis cluster...'
        client.wait_until(:cache_cluster_available) do |w|
          # disable max attempts
          w.max_attempts = nil

          # poll for 1 hour, instead of a number of attempts
          w.before_wait do |attempts, _response|
            puts "Still waiting for cluster - #attempts: #{attempts}"
          end
        end
      end

      def init_client
        @client = Aws::ElastiCache::Client.new(
          region: parameters.region,
          profile: parameters.profile
        )
      end
    end
  end
end
