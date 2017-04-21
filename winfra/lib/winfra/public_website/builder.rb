require "erb"

module Winfra
  module PublicWebsite
    class Builder
      attr_reader :path, :domain, :env, :public_website

      RESOURCE_TEMPLATE = Winfra.path_to('winfra/templates/s3/s3-resource.tf.erb')
      DEPLOY_GROUP_TEMPLATE = Winfra.path_to('winfra/templates/s3/s3-deploy-group.tf.erb')
      POLICY_TEMPLATE = Winfra.path_to('winfra/templates/s3/s3-public-website-policy.json.erb')
      MAIN_TEMPLATE = Winfra.path_to('winfra/templates/s3/s3-public-website-main.tf.erb')

      def initialize(domain, path, env, profile)
        @path = path
        @domain = domain
        @env = env
        @public_website = true
        @profile = profile
      end

      def build
        FileUtils.mkdir_p("#{path}/modules/s3")
        Winfra.render_template(RESOURCE_TEMPLATE, "#{@path}/modules/s3/s3-deploy-group.tf", binding)
        Winfra.render_template(DEPLOY_GROUP_TEMPLATE, "#{@path}/modules/s3/s3.tf", binding)
        Winfra.render_template(POLICY_TEMPLATE, "#{@path}/stages/#{env}/#{domain}.tpl", binding)
        Winfra.render_template(MAIN_TEMPLATE, "#{@path}/stages/#{env}/s3-public-website.tf", binding)
        Winfra.render_template(CONFIG_TEMPLATE, "#{@path}/stages/#{env}/config.tf", binding)
      end
    end
  end
end
