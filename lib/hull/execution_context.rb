class Hull::ExecutionContext
  def initialize(node)
    @node = node
  end

  def apply(blk)
    instance_eval(&blk)
  end

  def run(cmd)
    @node.execute(cmd)
  end

  def sudo(cmd)
    @node.sudo(cmd)
  end

  def upload(from, to)
    @node.upload(from, to)
  end

  def download(from, to)
    @node.download(from, to)
  end

  def local(path)
    Hull::LocalFile.new(path)
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
    Hull::RemoteFile.new(self, path)
  end

  def trigger(action_ref, *args)
    pkg_name, action_name = *action_ref.split(':', 2)
    pkg = Hull::PackageIndex.default.get(pkg_name)
    action = pkg.actions[action_name]
    raise "Action #{action_ref} could not be found." unless action
    instance_exec(*args, &action)
  end

  def binary_exists?(binary)
    run("which #{binary}") =~ /\/#{binary}/
  end
end

class Hull::MockExecutionContext < Hull::ExecutionContext
  def run(cmd)
    @node.log 'mock-execute', cmd
  end

  def sudo(cmd)
    @node.log 'mock-execute', "sudo #{cmd}"
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