require "erb"

module Winfra
  module RailsStack
    class Builder
      attr_reader :path, :env, :public_website, :app_name, :beanstalk_base, :rds_base

      BEANSTALK_RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/beanstalk-resource.tf.erb')
      BEANSTALK_SG_TEMPLATE = Winfra.path_to('winfra/templates/beanstalk-sg.tf.erb')
      BEANSTALK_OUTPUTS_TEMPLATE = Winfra.path_to('winfra/templates/beanstalk-outputs.tf.erb')

      RDS_RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/rds-resource.tf.erb')
      RDS_SG_TEMPLATE = Winfra.path_to('winfra/templates/rds-sg.tf.erb')

      MAIN_TEMPLATE = Winfra.path_to('winfra/templates/rails-stack-main.tf.erb')

      def initialize(path, env, vpc, app_name, profile)
        @path = path
        @env = env
        @has_vpc = vpc
        @app_name = app_name
        @beanstalk_base = "#{path}/infrastructure/modules/beanstalk"
        @rds_base = "#{path}/infrastructure/modules/rds"
        @profile = profile
      end

      def build
        FileUtils.mkdir_p(beanstalk_base)
        FileUtils.mkdir_p(rds_base)
        generate_beanstalk_templates
        generate_rds_templates
        generate_main_template
      end

      def generate_beanstalk_templates
        render_template(BEANSTALK_RESOURCE_TEMPLATE, "#{beanstalk_base}/beanstalk.tf")
        render_template(BEANSTALK_SG_TEMPLATE, "#{beanstalk_base}/beanstalk-sg.tf")
        render_template(BEANSTALK_OUTPUTS_TEMPLATE, "#{beanstalk_base}/outputs.tf")
      end

      def generate_rds_templates
        render_template(RDS_RESOURCE_TEMPLATE, "#{rds_base}/rds.tf")
        render_template(RDS_SG_TEMPLATE, "#{rds_base}/rds-sg.tf")
      end

      def generate_main_template
        render_template(MAIN_TEMPLATE, "#{@path}/infrastructure/stages/#{env}/main.tf")
        render_template(CONFIG_TEMPLATE, "#{@path}/infrastructure/stages/#{env}/config.tf")
      end

      def render_template(template_path, dest_path)
        puts "Rendering template #{template_path}"
        template = File.read(template_path)
        string = ERB.new(template).result( binding )
        puts "Saving template to #{dest_path}"
        File.open(dest_path, 'w') { |file| file.write(string) }
      end
    end
  end
end
