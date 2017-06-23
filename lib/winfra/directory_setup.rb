require 'fileutils'

module Winfra
  class DirectorySetup
    def setup(path, env)
      create_directory("#{path}/infrastructure/")
      "#{path}/infrastructure"
    end

    private

    def create_directory(path)
      Winfra.logger.debug "Creating directory #{path} if it doesn't exist"
      FileUtils.mkdir_p(path)
    end
  end
end
