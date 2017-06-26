require "erb"

module Winfra
  module Billing
    class Builder
      attr_reader :path, :domain, :env, :public_website

      ES_JS_FILE = Winfra.path_to('winfra/templates/billing/elasticsearch_csv.js')
      INDEX_FILE = Winfra.path_to('winfra/templates/billing/index.js')
      LAMBDA_FUNCTION_TEMPLATE = Winfra.path_to('winfra/templates/billing/lambda-function.tf.erb')
      LAMBDA_ROLE_TEMPLATE = Winfra.path_to('winfra/templates/billing/lambda-iam-role.tf.erb')
      S3_TEMPLATE = Winfra.path_to('winfra/templates/billing/billing-bucket.tf.erb')
      MAIN_TEMPLATE = Winfra.path_to('winfra/templates/billing/main.tf.erb')
      PACKAGE_DIRECTORY = Winfra.path_to('winfra/templates/billing/package.json')

      def initialize(path, bucket_name, options)
        @path = path
        @domain = domain
        @profile = options[:profile]
        @dest_path = "#{path}/billing"
        @function_dest_path = "#{@dest_path}/billing-report-parser"
        @bucket_name = bucket_name
      end

      def build
        FileUtils.mkdir_p("#{@function_dest_path}")
        create_lambda_function
        create_billing_bucket
        Winfra.render_template(MAIN_TEMPLATE, "#{@path}/main.tf", binding)
        Winfra.render_template(CONFIG_TEMPLATE, "#{@path}/config.tf", binding, false)
      end

      private

      def create_billing_bucket
        Winfra.render_template(S3_TEMPLATE, "#{@dest_path}/billing-bucket.tf", binding)
      end

      def create_lambda_function
        Winfra.render_template(LAMBDA_ROLE_TEMPLATE, "#{@dest_path}/lambda-iam-role.tf", binding)
        Winfra.render_template(LAMBDA_FUNCTION_TEMPLATE, "#{@dest_path}/lambda-function.tf", binding)
        Winfra.copy_file(ES_JS_FILE, "#{@function_dest_path}/elasticsearch_csv.js")
        Winfra.copy_file(INDEX_FILE, "#{@function_dest_path}/index.js")
        Winfra.copy_file(PACKAGE_DIRECTORY, "#{@function_dest_path}/package.json")
      end
    end
  end
end
