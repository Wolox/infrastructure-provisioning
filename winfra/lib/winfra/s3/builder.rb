require "erb"

module Winfra
  module S3
    class Builder
      attr_reader :path, :domain, :env, :public_website

      RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/s3/s3-resource.tf.erb')
      DEPLOY_GROUP_TEMPLATE = Winfra.path_to('winfra/templates/s3/s3-deploy-group.tf.erb')
      POLICY_TEMPLATE = Winfra.path_to('winfra/templates/s3/s3-public-website-policy.json.erb')
      MAIN_TEMPLATE = Winfra.path_to('winfra/templates/s3/s3-public-website-main.tf.erb')

      def initialize(domain, path, options)
        @path = path
        @domain = domain
        @sanitized_domain = domain.gsub('.', '_')
        @env = options[:env]
        @public_website = options[:public_website]
        @profile = options[:profile]
      end

      def build
        FileUtils.mkdir_p("#{path}/stages/#{env}/s3/#{domain}")
        Winfra.render_template(RESOURCE_TEMPLATE, "#{@path}/stages/#{env}/s3/#{domain}/s3-deploy-group.tf", binding)
        Winfra.render_template(DEPLOY_GROUP_TEMPLATE, "#{@path}/stages/#{env}/s3/#{domain}/s3.tf", binding)
        Winfra.render_template(POLICY_TEMPLATE, "#{@path}/stages/#{domain}.tpl", binding)
        Winfra.render_template(MAIN_TEMPLATE, "#{@path}/stages/s3-#{@domain}-#{@env}.tf", binding)
        Winfra.render_template(CONFIG_TEMPLATE, "#{@path}/stages/config.tf", binding)
      end
    end
  end
end
