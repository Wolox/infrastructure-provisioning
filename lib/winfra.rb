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

  def self.render_template(template_path, dest_path, a_binding, append = true)
    Winfra.logger.debug "Rendering template #{template_path}"
    template = File.read(template_path)
    string = ERB.new(template).result(a_binding)
    Winfra.logger.debug "Saving template to #{dest_path}"
    File.open(dest_path, append ? 'a' : 'w') { |file| file.write(string) }
  end

  def self.copy_file(src, dest)
    Winfra.logger.debug "Copying file from #{src} to #{dest}"
    return if File.exist?(dest)
    FileUtils.copy(src, dest)
  end

  def self.copy_dir(src, dest)
    FileUtils.mkdir_p(File.dirname(dest))
    Winfra.logger.debug "Copying dir from #{src} to #{dest}"
    FileUtils.copy_entry(src, dest)
  end

  def self.run(args)
    Cli.start(args)
  end
end
require "winfra/cli"
