module Core
  module ElasticBeanstalk
    class Application
      attr_reader :client, :options

      def initialize(options)
        @options = options
        build_client
      end

      def create
        return fetch_application if application_exists?
        puts "Creating application with options: #{options}"
        client.create_application(application_name: application_name,  description: description)
      end

      def fetch_application
        client.describe_applications(application_names: [application_name]).first
      end

      private

      def build_client
        @client = Aws::ElasticBeanstalk::Client.new(
          profile: options[:profile],
          region: options[:region]
        )
      end

      def application_exists?
        apps = client.describe_applications.to_h[:applications]
        apps.map { |a| a[:application_name].downcase }.include?(application_name.downcase)
      end

      def application_name
        options[:application_name]
      end

      def description
        options[:description]
      end
    end
  end
end
