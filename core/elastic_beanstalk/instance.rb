module Core
  module ElasticBeanstalk
    class Instance
      attr_reader :parameters, :client

      def initialize(parameters)
        @parameters = parameters
        build_client
      end

      def fetch_instance(instance_id)
        reservations = client.describe_instances(instance_ids: [instance_id]).reservations
        reservations.first.instances.first
      end

      private

      def build_client
        @client = Aws::EC2::Client.new(profile: parameters.profile, region: parameters.region)
      end
    end
  end
end
