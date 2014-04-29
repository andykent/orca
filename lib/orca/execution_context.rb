require "open3"

class Orca::ExecutionContext
  attr_reader :node, :log

  def initialize(node, log)
    @node = node
    @log = log
    @node.log_to(@log)
  end

  def apply(blk)
    instance_eval(&blk)
  end

  def as(user, &blk)
    for_user(user).apply(blk)
  end

  def for_user(user)
    return self if user.nil? || user == node.user
    new_node = @node.for_user(user)
    new_log = @log.clone_for_node(new_node)
    self.class.new(new_node, new_log)
  end

  def run_local(cmd)
    @log.local(cmd)
    stdout, stderr, status = Open3.capture3(cmd)
    @log.stdout(stdout)
    @log.stderr(stderr)
  end

  def run(cmd, opts={})
    @node.execute(cmd, opts)
  end

  def log(msg=nil)
    @log.log(msg) if msg
    @log
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

  def template(path)
    Orca::Template.new(@node, path)
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
    @log.mock_execute(cmd)
    ''
  end

  def sudo(cmd)
    @log.mock_execute "sudo #{cmd}"
    ''
  end

  def upload(from, to)
    @log.mock_execute("UPLOAD: #{from} => #{to}")
  end

  def download(from, to)
    @log.mock_execute("DOWLOAD: #{from} => #{to}")
  end

  def remove(path)
    @log.mock_execute("REMOVE: #{path}")
  end

  def stat(path)
    @log.mock_execute("STAT: #{path}")
  end

  def setstat(path, opts)
    @log.mock_execute("SET: #{path} - #{opts.inspect}")
  end
end