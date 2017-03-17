require "winfra/version"

module Winfra
  def self.path_to(path)
    File.join(File.dirname(__FILE__), path)
  end
  
  CONFIG_TEMPLATE = Winfra.path_to('winfra/templates/config.tf.erb')

  def self.run(args)
    Cli.start(args)
  end
end
require "winfra/cli"
