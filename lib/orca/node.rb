require 'net/ssh'
require 'net/sftp'

class Orca::Node
  attr_reader :name, :host

  def self.find(name)
    return name if name.is_a?(Orca::Node)
    @nodes[name]
  end

  def self.register(node)
    @nodes ||= {}
    Orca::Group.from_node(node)
    @nodes[node.name] = node
  end

  def initialize(name, host, options={})
    @name = name
    @host = host
    @options = options
    @connection = nil
    Orca::Node.register(self)
  end

  def get(option)
    @options[option]
  end

  def method_missing(meth, *args)
    get(meth)
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

  def execute(cmd, opts={})
    log('execute', cmd.cyan)
    output = ""
    connection.exec! cmd do |channel, stream, data|
      output += data if stream == :stdout
      data.split("\n").each do |line|
        msg = stream == :stdout ? line.green : line.red
        log(stream, msg) if opts[:log] || Orca.verbose
      end
    end
    output
  end

  def sudo(cmd, opts={})
    execute("sudo #{cmd}", opts)
  end

  def log(context, msg)
    Thread.exclusive { puts "#{self.to_s} [#{context.to_s.bold}] #{msg}" }
    msg
  end

  def connection
    return @connection if @connection
    @connection = Net::SSH.start(@host, (@options[:user] || 'root'), options_for_ssh)
  end

  def disconnect
    @connection.close if @connection && !@connection.closed?
  end

  def to_s
    "#{name}(#{host})"
  end

  private

  def options_for_ssh
    opts = [:auth_methods, :compression, :compression_level, :config, :encryption , :forward_agent , :global_known_hosts_file , :hmac , :host_key , :host_key_alias , :host_name, :kex , :keys , :key_data , :keys_only , :logger , :paranoid , :passphrase , :password , :port , :properties , :proxy , :rekey_blocks_limit , :rekey_limit , :rekey_packet_limit , :timeout , :user , :user_known_hosts_file , :verbose ]
    @options.reduce({}) do |hsh, (k,v)|
      hsh[k] = v if opts.include?(k)
      hsh
    end
  end
end