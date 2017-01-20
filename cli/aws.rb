require 'thor'
require_relative '../core/elastic_beanstalk'

module Cli
  class Aws < Thor
    desc "create_eb_application project", "creates an Elastic Beanstalk application"
    option :profile
    option :region
    option :services
    option :solution_stack_name, required: true
    def create_backend(project)
      puts "Creating backend for #{project} with services: #{options[:services].split(',').join(' ')}"
      Core::Backend.new.create
    end

    def show_backend_stacks
      Core::Backend.new.show_stacks
    end
  end

  Aws.start(ARGV)
end
