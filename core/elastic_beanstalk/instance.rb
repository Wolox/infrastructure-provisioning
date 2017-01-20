module Core
  module ElasticBeanstalk
    class Instance
      attr_reader :client, :options

      def initialize(options)
        @options = options
        build_client
      end

      def fetch_instance(instance_id)
        reservations = client.describe_instances(instance_ids: [instance_id]).reservations
        reservations.first.instances.first
      end

      private

      def build_client
        @client = Aws::EC2::Client.new(profile: options[:profile], region: options[:region])
      end
    end
  end
end
