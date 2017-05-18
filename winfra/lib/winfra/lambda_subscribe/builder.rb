require "erb"

module Winfra
  module LambdaSubscribe
    class Builder
      attr_reader :path, :env, :public_website, :dest_base_path

      BASE_PATH = "winfra/templates/lambda-subscribe"

      API_TEMPLATE = Winfra.path_to("#{BASE_PATH}/api-gtw.tf.erb")
      API_METHOD_TEMPLATE = Winfra.path_to("#{BASE_PATH}/api-gtw-methods.tf.erb")
      LAMBDA_TEMPLATE = Winfra.path_to("#{BASE_PATH}/lambda-function.tf.erb")
      SIMPLEDB_TEMPLATE = Winfra.path_to("#{BASE_PATH}/simpledb.tf.erb")
      INTEGRATION_TEMPLATE = Winfra.path_to("#{BASE_PATH}/api-gtw-integration.tf.erb")
      IAM_TEMPLATE = Winfra.path_to("#{BASE_PATH}/lambda-iam-role.tf.erb")
      MAIN_TEMPLATE = Winfra.path_to("#{BASE_PATH}/main.tf.erb")

      def initialize(path, env, profile)
        @path = path
        @env = env
        @profile = profile
        @modules_dest_path = "#{@path}/modules/lambda-subscribe"
        @dest_base_path = "#{path}/stages/#{env}"
      end

      def build
        FileUtils.mkdir_p("#{path}/modules/lambda-subscribe")
        create_api
        create_db
        create_iam_role
        enable_method('post')
        enable_method('get')
        Winfra.render_template(MAIN_TEMPLATE, "#{@dest_base_path}/lambda-subscribe.tf", binding)
        Winfra.render_template(CONFIG_TEMPLATE, "#{@dest_base_path}/config.tf", binding)
      end

      private

      def create_iam_role
        Winfra.render_template(IAM_TEMPLATE, "#{@modules_dest_path}/iam-role.tf", binding)
      end

      def create_db
        Winfra.render_template(SIMPLEDB_TEMPLATE, "#{@modules_dest_path}/simpledb.tf", binding)
      end

      def create_api
        Winfra.render_template(API_TEMPLATE, "#{@modules_dest_path}/api-gtw.tf", binding)
      end

      def enable_method(http_method)
        @http_method = http_method.upcase
        @method_name = http_method.downcase
        @lambda_function_name = "subscribe-#{http_method.downcase}"
        create_method(http_method)
        create_lambda_function(@lambda_function_name)
        enable_integration(http_method)
      end

      def enable_integration(http_method)
        Winfra.render_template(INTEGRATION_TEMPLATE, "#{@modules_dest_path}/api-gtw-integration-#{http_method}.tf", binding)
      end

      def create_method(http_method)
        dest_file_name = "#{@modules_dest_path}/api-gtw-#{http_method}.tf"
        Winfra.render_template(API_METHOD_TEMPLATE, dest_file_name, binding)
      end

      def create_lambda_function(lambda_function_name)
        @lambda_function_file = "#{lambda_function_name}.zip"
        dest_file_name = "#{@modules_dest_path}/#{lambda_function_name}.tf"
        Winfra.render_template(LAMBDA_TEMPLATE, dest_file_name, binding)
        node_modules_directory = Winfra.path_to("#{BASE_PATH}/node_modules")
        function_location = Winfra.path_to("#{BASE_PATH}/#{lambda_function_name}.js")
        Winfra.copy_dir(node_modules_directory, "#{@dest_base_path}/#{lambda_function_name}/node_modules")
        Winfra.copy_file(function_location, "#{@dest_base_path}/#{lambda_function_name}/#{lambda_function_name}.js")
      end
    end
  end
end
