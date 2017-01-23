#!/usr/bin/env ruby
require "rubygems"
require 'thor'
require_relative '../core/backend'

module Cli
  class Aws < Thor
    desc "create_eb_application project", "creates an Elastic Beanstalk application"
    option :profile, required: true
    option :region
    option :environment_name
    def create_backend(project)
      puts "Creating backend for #{project} with services: #{options[:services]}"
      Core::Backend.new(project, options).create
    end

    desc "Prints available stacks", "Prints available stacks"
    option :profile, required: true
    def show_backend_stacks
      Core::Backend.new('', options).show_stacks
    end
  end

  Aws.start(ARGV)
end
