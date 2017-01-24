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

      def allow_access_from(environment, ec2_client)
        sg_id = fetch_cluster[:cache_security_groups].first[:vpc_security_group_id]
        ec2_client.authorize_security_group_ingress(
          group_id: sg_id, ip_permissions: [
            {
              ip_protocol: 'tcp', from_port: 6379, to_port: 6379, user_id_group_pairs: [
                { group_name: environment[:security_group].group_name }
              ]
            }
          ]
        )
      end

      private

      def fetch_cluster
        clusters = client.describe_cache_clusters(cache_cluster_id: parameters.identifier).to_h
        clusters['cache_clusters'].first
      end

      def cache_cluster_exists?
        fetch_cluster != nil
      end

      def create_cache_cluster
        puts "Creating redis cluster..."
        client.create_cache_cluster(
          cache_cluster_id: parameters.identifier,
          cache_node_type: parameters.cache_node_type,
          engine: 'redis'
        )
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
