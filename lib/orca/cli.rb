class Orca::Cli < Thor
  include Thor::Actions

  source_root File.join(File.dirname(__FILE__), *%w[.. .. config])

  class_option :demonstrate, :type => :boolean, :desc => "Don't actually run any commands on the group, just pretend."
  class_option :file,        :banner => 'ORCA_FILE', :desc => "path to the orca.rb file to load, defaults to ./orca/orca.rb"
  class_option :throw,       :type => :boolean, :desc => "Don't pretty print errors, raise with a stack trace."
  class_option :sequential,  :type => :boolean, :desc => "Don't run tasks in parrallel across nodes."

  desc "apply PACKAGE_NAME GROUP_OR_NODE_NAME", "apply the given package onto the given named group"
  def apply(package, group)
    run_command(package, group, :apply)
  end

  desc "remove PACKAGE_NAME GROUP_OR_NODE_NAME", "remove the given package onto the given named group"
  def remove(package, group)
    run_command(package, group, :remove)
  end

  desc "validate PACKAGE_NAME GROUP_OR_NODE_NAME", "run validation steps on the given named group"
  def validate(package, group)
    run_command(package, group, :validate)
  end

  desc "init", "initialize the current directory with a orca/orca.rb"
  def init
    directory('template', 'orca')
  end

  private

  def run_command(package, group, cmd)
    begin
      suite = Orca::Suite.new(options)
      suite.load_file(orca_file)
      suite.run(group, package, cmd)
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
