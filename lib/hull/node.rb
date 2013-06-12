require 'net/ssh'
require 'net/sftp'

class Hull::Node
  attr_reader :name, :host

  def self.find(name)
    @nodes[name]
  end

  def self.register(node)
    @nodes ||= {}
    @nodes[node.name] = node
  end

  def initialize(name, host, options={})
    @name = name
    @host = host
    @options = options
    @connection = nil
    Hull::Node.register(self)
  end

  def upload(from, to)
    log('sftp', "UPLOAD: #{from} => #{to}")
    sftp.upload!(from, to)
  end

  def download(from, to)
    log('sftp', "DOWLOAD: #{from} => #{to}")
    sftp.download!(from, to)
  end

  def remove(path)
    log('sftp', "REMOVE: #{path}")
    sftp.remove!(path)
  end

  def stat(path)
    log('sftp', "STAT: #{path}")
    sftp.stat!(path)
  end

  def setstat(path, opts)
    log('sftp', "SET: #{path} - #{opts.inspect}")
    sftp.setstat!(path, opts)
  end

  def sftp
    @sftp ||= connection.sftp.connect
  end

  def execute(cmd)
    log('execute', cmd.cyan)
    output = ""
    connection.exec! cmd do |channel, stream, data|
      output += data if stream == :stdout
      data.split("\n").each do |line|
        msg = stream == :stdout ? line.green : line.red
        log(stream, msg)
      end
    end
    output
  end

  def sudo(cmd)
    execute("sudo #{cmd}")
  end

  def log(context, msg)
    puts "#{self.to_s} [#{context.to_s.bold}] #{msg}"
  end

  def connection
    return @connection if @connection
    @connetion = Net::SSH.start(@host, (@options[:user] || 'root'), @options)
  end

  def to_s
    "#{name}(#{host})"
  end
end