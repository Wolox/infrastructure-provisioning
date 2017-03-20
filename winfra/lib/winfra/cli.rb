require 'thor'
require 'winfra/directory_setup'
require 'winfra/public_website/builder'
require 'winfra/rails_stack/builder'

module Winfra
  class Cli < Thor

    desc "public-website domain", "creates an s3 bucket for a public website"
    method_option :profile, desc: 'The aws profile to use', required: true
    method_option :path, aliases: "-p", desc: "The path where the files should be created", required: true
    method_option :env, aliases: "-e", desc: "The environment for which this templates will be created for", default: 'dev'
    method_option :debug, aliases: "-d", desc: "Enable debug logs", default: false, type: 'boolean'
    def public_website(domain)
      Winfra.logger.debug "Called public_website with path: #{options[:path]}, env: #{options[:env]}"
      DirectorySetup.new.setup(options[:path], options[:env])
      PublicWebsite::Builder.new(domain, options[:path], options[:env], options[:profile]).build
    end

    desc "rails-stack app", "creates the infrastructure for a rails stack"
    method_option :profile, desc: 'The aws profile to use', required: true
    method_option :path, aliases: "-p", desc: "The path where the files should be created", required: true
    method_option :env, aliases: "-e", desc: "The environment for which this templates will be created for", default: 'dev'
    method_option :vpc, aliases: "-v", desc: "True if the beanstalk should live in a vpc", default: false, type: 'boolean'
    method_option :debug, aliases: "-d", desc: "Enable debug logs", default: false, type: 'boolean'
    def rails_stack(app_name)
      Winfra.init_logger(options[:debug])
      Winfra.logger.debug "Called public_website with path: #{options[:path]}, env: #{options[:env]}"
      DirectorySetup.new.setup(options[:path], options[:env])
      RailsStack::Builder.new(options[:path], options[:env], options[:vpc], app_name, options[:profile]).build
    end
  end
end
