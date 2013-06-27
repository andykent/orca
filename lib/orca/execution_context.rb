class Orca::ExecutionContext
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def apply(blk)
    instance_eval(&blk)
  end

  def run(cmd, opts={})
    @node.execute(cmd, opts)
  end

  def log(msg)
    @node.log('log', msg)
  end

  def sudo(cmd, opts={})
    @node.sudo(cmd, opts)
  end

  def upload(from, to)
    @node.upload(from, to)
  end

  def download(from, to)
    @node.download(from, to)
  end

  def local(path)
    Orca::LocalFile.new(path)
  end

  def remove(path)
    @node.remove(path)
  end

  def stat(path)
    @node.stat(path)
  end

  def setstat(path, opts)
    @node.setstat(path, opts)
  end

  def remote(path)
    Orca::RemoteFile.new(self, path)
  end

  def trigger(action_ref, *args)
    pkg_name, action_name = *action_ref.split(':', 2)
    pkg = Orca::PackageIndex.default.get(pkg_name)
    action = pkg.actions[action_name]
    raise Orca::MissingActionError.new(action_ref) unless action
    instance_exec(*args, &action)
  end

  def binary_exists?(binary)
    run("which #{binary}") =~ /\/#{binary}/
  end
end

class Orca::MissingActionError < StandardError
  def initialize(action_ref)
    @action_ref = action_ref
  end

  def message
    "Action '#{@action_ref}' could not be found."
  end
end

class Orca::MockExecutionContext < Orca::ExecutionContext
  def run(cmd)
    @node.log 'mock-execute', cmd
    ''
  end

  def sudo(cmd)
    @node.log 'mock-execute', "sudo #{cmd}"
    ''
  end

  def upload(from, to)
    @node.log('mock-sftp', "UPLOAD: #{from} => #{to}")
  end

  def download(from, to)
    @node.log('mock-sftp', "DOWLOAD: #{from} => #{to}")
  end

  def remove(path)
    @node.log('mock-sftp', "REMOVE: #{path}")
  end

  def stat(path)
    @node.log('mock-sftp', "STAT: #{path}")
  end

  def setstat(path, opts)
    @node.log('mock-sftp', "SET: #{path} - #{opts.inspect}")
  end
end