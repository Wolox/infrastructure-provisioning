require 'thor'
require 'winfra/directory_setup'
require 'winfra/public_website/builder'
require 'winfra/rails_stack/builder'

module Winfra
  class Cli < Thor

    desc "public-website", "creates an s3 bucket for a public website"
    method_option :path, aliases: "-p", desc: "The path where the files should be created", required: true
    method_option :env, aliases: "-e", desc: "The environment for which this templates will be created for", default: 'dev'
    def public_website(domain)
      puts "Called public_website with path: #{options[:path]}, env: #{options[:env]}"
      DirectorySetup.new.setup(options[:path], options[:env])
      PublicWebsite::Builder.new(domain, options[:path], options[:env]).build
    end

    desc "rails-stack", "creates the infrastructure for a rails stack"
    method_option :path, aliases: "-p", desc: "The path where the files should be created", required: true
    method_option :env, aliases: "-e", desc: "The environment for which this templates will be created for", default: 'dev'
    method_option :vpc, aliases: "-v", desc: "True if the beanstalk should live in a vpc", default: false
    def rails_stack(app_name)
      puts "Called public_website with path: #{options[:path]}, env: #{options[:env]}"
      DirectorySetup.new.setup(options[:path], options[:env])
      RailsStack::Builder.new(options[:path], options[:env], options[:vpc], app_name).build
    end
  end
end
