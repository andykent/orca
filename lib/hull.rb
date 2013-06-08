require 'colored'

module Hull
  def root
    File.dirname(ENV['HULL_FILE'])
  end
  module_function :root
end

require_relative "./hull/package"
require_relative "./hull/package_index"
require_relative "./hull/node"
require_relative "./hull/runner"
require_relative "./hull/resolver"
require_relative "./hull/execution_context"
require_relative "./hull/local_file"
require_relative "./hull/remote_file"
require_relative "./hull/file_sync"
require_relative "./hull/dsl"
