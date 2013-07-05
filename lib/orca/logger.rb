class Orca::Logger
  def initialize(node, package)
    @node = node
    set_package(package)
  end

  def set_package(package)
    @package = package.to_s
  end

  def command(msg)
    say(msg, :yellow)
  end

  def local(cmd)
    say(cmd, :cyan)
  end

  def execute(cmd)
    say(cmd, :cyan)
  end

  def mock_execute(cmd)
    execute(cmd)
  end

  def cached(cmd)
    execute(cmd)
  end

  def sftp(cmd)
    execute(cmd)
  end

  def log(msg)
    say(msg)
  end

  def stdout(msg, force=false)
    say(msg, :green) if force || Orca.verbose
  end

  def stderr(msg, force=false)
    say(msg, :red) if force || Orca.verbose
  end

  def say(msg, color=nil)
    msg.to_s.split("\n").each do |line|
      out = color ? line.send(color) : line
      Thread.exclusive { puts "#{@node.to_s} [#{@package.bold}] #{out}" }
    end
  end
end