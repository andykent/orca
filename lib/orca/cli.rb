class Orca::Cli < Thor
  include Thor::Actions

  source_root File.join(File.dirname(__FILE__), *%w[.. .. config])

  class_option :demonstrate, :type => :boolean, :desc => "Don't actually run any commands on the node, just pretend."
  class_option :file,        :banner => 'ORCA_FILE', :desc => "path to the orca.rb file to load, defaults to ./orca/orca.rb"
  class_option :throw,       :type => :boolean, :desc => "Don't pretty print errors, raise with a stack trace."

  desc "apply PACKAGE_NAME NODE_NAME", "apply the given package onto the given named node"
  def apply(package, node)
    run_command(package, node, :apply)
  end

  desc "remove PACKAGE_NAME NODE_NAME", "remove the given package onto the given named node"
  def remove(package, node)
    run_command(package, node, :remove)
  end

  desc "validate PACKAGE_NAME NODE_NAME", "run validation steps on the given named node"
  def validate(package, node)
    run_command(package, node, :validate)
  end

  desc "init", "initialize the current directory with a orca/orca.rb"
  def init
    directory('template', 'orca')
  end

  private

  def run_command(package, node, cmd)
    begin
      suite = Orca::Suite.new
      suite.load_file(orca_file)
      if options[:demonstrate]
        suite.demonstrate(node, package, cmd)
      else
        suite.execute(node, package, cmd)
      end
    rescue => e
      if options[:throw]
        raise e
      else
        puts "!!! ERROR !!! [#{e.class.name}] #{e.message}".red.bold
      end
    end
  end

  def orca_file
    ENV['ORCA_FILE'] ||= (options[:file] || File.join(Dir.pwd, 'orca', 'orca.rb'))
  end
end
