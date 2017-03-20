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

  def self.init_logger(debug=false)
    @logger = Logger.new(STDOUT)
    @logger.level = debug ? Logger::DEBUG : Logger::WARN
    @logger
  end

  def self.render_template(template_path, dest_path, a_binding)
    Winfra.logger.debug "Rendering template #{template_path}"
    template = File.read(template_path)
    string = ERB.new(template).result(a_binding)
    Winfra.logger.debug "Saving template to #{dest_path}"
    File.open(dest_path, 'w') { |file| file.write(string) }
  end

  def self.run(args)
    Cli.start(args)
  end
end
require "winfra/cli"
