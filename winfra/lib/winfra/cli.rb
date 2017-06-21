require 'thor'
require 'winfra/directory_setup'
require 'winfra/s3/builder'
require 'winfra/rails_stack/builder'
require 'winfra/lambda_subscribe/builder'

module Winfra
  class Cli < Thor

    desc "s3_bucket domain", "creates an s3 bucket for a public website"
    method_option :profile, desc: 'The aws profile to use', required: true
    method_option :path, aliases: "-p", desc: "The path where the files should be created", required: true
    method_option :env, aliases: "-e", desc: "The environment for which this templates will be created for", default: 'dev'
    method_option :debug, aliases: "-d", desc: "Enable debug logs", default: false, type: 'boolean'
    method_option :public_website, aliases: "-a", desc: "Enables public website", default: false, type: 'boolean'
    def s3_bucket(domain)
      Winfra.logger.debug "Called s3_bucket with path: #{options[:path]}, env: #{options[:env]}"
      path = DirectorySetup.new.setup(options[:path], options[:env])
      S3::Builder.new(domain, path, options).build
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
      path = DirectorySetup.new.setup(options[:path], options[:env])
      RailsStack::Builder.new(path, options[:env], options[:vpc], app_name, options[:profile]).build
    end

    desc "lambda-subscribe name", "creates an endpoint in AWS to store user information"
    method_option :profile, desc: 'The aws profile to use', required: true
    method_option :path, aliases: "-p", desc: "The path where the files should be created", required: true
    method_option :env, aliases: "-e", desc: "The environment for which this templates will be created for", default: 'dev'
    method_option :debug, aliases: "-d", desc: "Enable debug logs", default: false, type: 'boolean'
    def lambda_subscribe(name)
      Winfra.logger.debug "Called lambda_subscribe with path: #{options[:path]}, env: #{options[:env]}"
      path = DirectorySetup.new.setup(options[:path], options[:env])
      LambdaSubscribe::Builder.new(path, name, options[:env], options[:profile]).build
    end
  end
end
