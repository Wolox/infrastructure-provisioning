require "winfra/version"
require 'logger'

module Winfra
  CONFIG_TEMPLATE = File.join(File.dirname(__FILE__), 'winfra/templates/config.tf.erb')

  def self.path_to(path)
    File.join(File.dirname(__FILE__), path)
  end

  def self.logger
    (defined?(@logger) && @logger) || (self.init_logger)
  end

  def self.init_logger(debug)
    @logger = Logger.new(STDOUT)
    @logger.level = debug ? Logger::DEBUG : Logger::WARN
    @logger
  end

  def self.run(args)
    Cli.start(args)
  end
end
require "winfra/cli"
