require 'colored'

module Hull
  def root
    File.dirname(ENV['HULL_FILE'])
  end
  module_function :root

  def add_package(name)
    package = Hull::Package.new(name)
    yield(package) if block_given?
    Hull::PackageIndex.default.add(package)
    package
  end
  module_function :add_package

  def extension(name, &blk)
    @extensions ||= {}
    @extensions[name.to_sym] = blk
  end
  module_function :extension

  def load_extension(name)
    raise MissingExtensionError.new(name) unless @extensions && @extensions[name.to_sym]
    Hull::DSL.class_eval(&@extensions[name.to_sym])
    true
  end
  module_function :load_extension

  class MissingExtensionError < StandardError
    def initialize(extension_name)
      @extension_name = extension_name
    end

    def message
      "The extension '#{@extension_name}' is not available."
    end
  end
end

require_relative "./hull/package"
require_relative "./hull/package_index"
require_relative "./hull/node"
require_relative "./hull/runner"
require_relative "./hull/resolver"
require_relative "./hull/execution_context"
require_relative "./hull/local_file"
require_relative "./hull/remote_file"
require_relative "./hull/dsl"

require_relative "./hull/extensions/apt"
require_relative "./hull/extensions/file_sync"
require_relative "./hull/extensions/gem"
