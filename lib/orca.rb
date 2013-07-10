require 'rubygems'
require 'colored'

module Orca
  def verbose(val=nil)
    @verbose = val unless val.nil?
    @verbose || false
  end
  module_function :verbose

  def root
    File.dirname(ENV['ORCA_FILE'])
  end
  module_function :root

  def add_package(name)
    package = Orca::Package.new(name)
    yield(package) if block_given?
    Orca::PackageIndex.default.add(package)
    package
  end
  module_function :add_package

  def extension(&blk)
    Orca::DSL.class_eval(&blk)
  end
  module_function :extension

  class MissingExtensionError < StandardError
    def initialize(extension_name)
      @extension_name = extension_name
    end

    def message
      "The extension '#{@extension_name}' is not available."
    end
  end
end

require_relative "./orca/logger"
require_relative "./orca/package"
require_relative "./orca/package_index"
require_relative "./orca/node"
require_relative "./orca/group"
require_relative "./orca/runner"
require_relative "./orca/trigger_runner"
require_relative "./orca/resolver"
require_relative "./orca/template"
require_relative "./orca/execution_context"
require_relative "./orca/local_file"
require_relative "./orca/remote_file"
require_relative "./orca/dsl"
require_relative "./orca/suite"
require_relative "./orca/cli"