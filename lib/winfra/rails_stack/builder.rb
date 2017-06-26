require "erb"

module Winfra
  module RailsStack
    class Builder
      attr_reader :path, :env, :public_website, :app_name, :beanstalk_base, :rds_base, :has_vpc,
                  :vpc_base

      BEANSTALK_RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/beanstalk-resource.tf.erb')
      BEANSTALK_SG_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/beanstalk-sg.tf.erb')
      BEANSTALK_OUTPUTS_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/beanstalk-outputs.tf.erb')
      BEANSTALK_ROLE_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/beanstalk-role.tf.erb')

      RDS_RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/rds-resource.tf.erb')
      RDS_OUTPUTS_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/rds-outputs.tf.erb')
      RDS_SG_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/rds-sg.tf.erb')

      VPC_RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/vpc-resource.tf.erb')
      VPC_OUTPUTS_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/vpc-outputs.tf.erb')

      MAIN_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/rails-stack-main.tf.erb')
      APP_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack/beanstalk-application.tf.erb')

      def initialize(app_name, path, options)
        @path = path
        @env = options[:env]
        @has_vpc = options[:vpc]
        @app_name = app_name
        @beanstalk_base = "#{path}/#{@env}/beanstalk"
        @rds_base = "#{path}/#{@env}/rds"
        @vpc_base = "#{path}/modules/vpc"
        @profile = options[:profile]
        @aws_authentication = options[:aws_auth]
      end

      def build
        generate_beanstalk_templates
        generate_rds_templates
        generate_vpc_templates if has_vpc
        generate_main_template
      end

      def generate_vpc_templates
        FileUtils.mkdir_p(vpc_base)
        Winfra.render_template(VPC_RESOURCE_TEMPLATE, "#{vpc_base}/vpc.tf", binding)
        Winfra.render_template(VPC_OUTPUTS_TEMPLATE, "#{vpc_base}/outputs.tf", binding)
      end

      def generate_beanstalk_templates
        FileUtils.mkdir_p(beanstalk_base)
        Winfra.render_template(BEANSTALK_RESOURCE_TEMPLATE, "#{beanstalk_base}/beanstalk.tf", binding)
        Winfra.render_template(BEANSTALK_SG_TEMPLATE, "#{beanstalk_base}/beanstalk-sg.tf", binding)
        Winfra.render_template(BEANSTALK_ROLE_TEMPLATE, "#{beanstalk_base}/beanstalk-role.tf", binding)
        Winfra.render_template(BEANSTALK_OUTPUTS_TEMPLATE, "#{beanstalk_base}/outputs.tf", binding)
      end

      def generate_rds_templates
        FileUtils.mkdir_p(rds_base)
        Winfra.render_template(RDS_RESOURCE_TEMPLATE, "#{rds_base}/rds.tf", binding)
        Winfra.render_template(RDS_OUTPUTS_TEMPLATE, "#{rds_base}/outputs.tf", binding)
        Winfra.render_template(RDS_SG_TEMPLATE, "#{rds_base}/rds-sg.tf", binding)
      end

      def generate_main_template
        Winfra.render_template(APP_TEMPLATE, "#{@path}/beanstalk-#{@env}.tf", binding)
        Winfra.render_template(MAIN_TEMPLATE, "#{@path}/main-#{@env}.tf", binding)
        Winfra.render_template(CONFIG_TEMPLATE, "#{@path}/config.tf", binding, false)
      end
    end
  end
end
