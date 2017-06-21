require "erb"

module Winfra
  module StackSleepAwake
    class Builder
      attr_reader :path, :domain, :env, :public_website

      CW_RULE_TEMPLATE = Winfra.path_to('winfra/templates/stack-sleep-awake/cloudwatch-rule.tf.erb')
      LAMBDA_TEMPLATE = Winfra.path_to('winfra/templates/stack-sleep-awake/lambda-function.tf.erb')
      LAMBDA_ROLE_TEMPLATE = Winfra.path_to('winfra/templates/stack-sleep-awake/lambda-iam-role.tf.erb')
      MAIN_TEMPLATE = Winfra.path_to('winfra/templates/stack-sleep-awake/main.tf.erb')
      NODE_MODULES_DIRECTORY = Winfra.path_to('winfra/templates/stack-sleep-awake/node_modules/')
      START_CRON_EXPRESSION = '0 11 ? * MON-FRI *'
      STOP_CRON_EXPRESSION = '0 0 ? * TUE-SAT *'

      def initialize(path, options)
        @path = path
        @domain = domain
        @env = options[:env]
        @profile = options[:profile]
        @dest_path = "#{path}/stack-sleep-awake"
      end

      def build
        create_lambda_functions
        create_cloudwatch_rules
      end

      private

      def create_cloudwatch_rules
        create_cloudwatch_rule('start')
        create_cloudwatch_rule('stop')
        Winfra.render_template(CONFIG_TEMPLATE, "#{@path}/config.tf", binding)
      end

      def create_cloudwatch_rule(action)
        @event_name = "#{@env}-#{action}"
        @rule_name = @event_name
        @lambda_function_name = "stack-#{action}"
        @cron_expression = action == 'start' ? START_CRON_EXPRESSION : STOP_CRON_EXPRESSION
        Winfra.render_template(CW_RULE_TEMPLATE, "#{@path}/#{@event_name}-cloudwatch-rule.tf", binding)
      end

      def create_lambda_functions
        Winfra.copy_file(LAMBDA_ROLE_TEMPLATE, "#{@path}/lambda-iam-role.tf")
        create_lambda_function('stack-start')
        create_lambda_function('stack-stop')
        create_lambda_function('start-beanstalk')
        create_lambda_function('start-rds')
        create_lambda_function('stop-beanstalk')
        create_lambda_function('stop-rds')
      end

      def create_lambda_function(function_name)
        FileUtils.mkdir_p("#{@dest_path}/#{function_name}")
        @lambda_function_name = function_name
        @lambda_function_file = "#{@lambda_function_name}.zip"
        function_location = Winfra.path_to("winfra/templates/stack-sleep-awake/#{function_name}.js")
        Winfra.copy_dir(NODE_MODULES_DIRECTORY, "#{@dest_path}/#{function_name}/node_modules")
        Winfra.copy_file(function_location, "#{@dest_path}/#{function_name}/index.js")
        Winfra.render_template(LAMBDA_TEMPLATE, "#{@path}/#{function_name}-lambda.tf", binding)
      end
    end
  end
end
