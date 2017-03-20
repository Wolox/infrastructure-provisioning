require "erb"

module Winfra
  module PublicWebsite
    class Builder
      attr_reader :path, :domain, :env, :public_website

      RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/s3-resource.tf.erb')
      POLICY_TEMPLATE = Winfra.path_to('winfra/templates/s3-public-website-policy.json.erb')
      MAIN_TEMPLATE = Winfra.path_to('winfra/templates/s3-public-website-main.tf.erb')

      def initialize(domain, path, env, profile)
        @path = path
        @domain = domain
        @env = env
        @public_website = true
        @profile = profile
      end

      def build
        FileUtils.mkdir_p("#{path}/infrastructure/modules/s3")
        render_template(RESOURCE_TEMPLATE, "#{@path}/infrastructure/modules/s3/s3.tf")
        render_template(POLICY_TEMPLATE, "#{@path}/infrastructure/stages/#{env}/#{domain}.tpl")
        render_template(MAIN_TEMPLATE, "#{@path}/infrastructure/stages/#{env}/s3-public-website.tf")
        render_template(CONFIG_TEMPLATE, "#{@path}/infrastructure/stages/#{env}/config.tf")
      end

      def render_template(template_path, dest_path)
        Winfra.logger.debug "Rendering template #{template_path}"
        template = File.read(template_path)
        string = ERB.new(template).result( binding )
        Winfra.logger.debug "Saving template to #{dest_path}"
        File.open(dest_path, 'w') { |file| file.write(string) }
      end
    end
  end
end
