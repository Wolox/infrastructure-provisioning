require "erb"

module Winfra
  module RailsStack
    class Builder
      attr_reader :path, :env, :public_website, :app_name, :beanstalk_base, :rds_base, :has_vpc,
                  :vpc_base

      BEANSTALK_RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/beanstalk-resource.tf.erb')
      BEANSTALK_SG_TEMPLATE = Winfra.path_to('winfra/templates/beanstalk-sg.tf.erb')
      BEANSTALK_OUTPUTS_TEMPLATE = Winfra.path_to('winfra/templates/beanstalk-outputs.tf.erb')
      BEANSTALK_ROLE_TEMPLATE = Winfra.path_to('winfra/templates/beanstalk-role.tf.erb')

      RDS_RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/rds-resource.tf.erb')
      RDS_OUTPUTS_TEMPLATE = Winfra.path_to('winfra/templates/rds-outputs.tf.erb')
      RDS_SG_TEMPLATE = Winfra.path_to('winfra/templates/rds-sg.tf.erb')

      VPC_RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/vpc-resource.tf.erb')
      VPC_OUTPUTS_TEMPLATE = Winfra.path_to('winfra/templates/vpc-outputs.tf.erb')

      MAIN_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack-main.tf.erb')
      APP_TEMPLATE = Winfra.path_to('winfra/templates/beanstalk-application.tf.erb')

      def initialize(path, env, vpc, app_name, profile)
        @path = path
        @env = env
        @has_vpc = vpc
        @app_name = app_name
        @beanstalk_base = "#{path}/modules/beanstalk"
        @rds_base = "#{path}/modules/rds"
        @vpc_base = "#{path}/modules/vpc"
        @profile = profile
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
        Winfra.render_template(CONFIG_TEMPLATE, "#{@path}/stages/common/config.tf", binding)
        Winfra.render_template(APP_TEMPLATE, "#{@path}/stages/common/beanstalk-app.tf", binding)
        Winfra.render_template(MAIN_TEMPLATE, "#{@path}/stages/#{env}/main.tf", binding)
        Winfra.render_template(CONFIG_TEMPLATE, "#{@path}/stages/#{env}/config.tf", binding)
      end
    end
  end
end
