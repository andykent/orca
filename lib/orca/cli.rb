class Orca::Cli < Thor
  include Thor::Actions

  source_root File.join(File.dirname(__FILE__), *%w[.. .. config])

  class_option :demonstrate, :type => :boolean, :desc => "Don't actually run any commands on the group, just pretend."
  class_option :file,        :banner => 'ORCA_FILE', :desc => "path to the orca.rb file to load, defaults to ./orca/orca.rb"
  class_option :throw,       :type => :boolean, :desc => "Don't pretty print errors, raise with a stack trace."
  class_option :sequential,  :type => :boolean, :desc => "Don't run tasks in parrallel across nodes."
  class_option :verbose,     :type => :boolean, :desc => "print all SSH output, useful for debugging"
  class_option :'skip-dependancies', :type => :boolean, :desc => "Don't validate and run dependancies."

  desc "apply PACKAGE_NAME [GROUP_OR_NODE_NAME]", "apply the given package onto the given named group"
  def apply(package, group=package)
    run_command(package, group, :apply)
  end

  desc "remove PACKAGE_NAME [GROUP_OR_NODE_NAME]", "remove the given package onto the given named group"
  def remove(package, group=package)
    run_command(package, group, :remove)
  end

  desc "validate PACKAGE_NAME [GROUP_OR_NODE_NAME]", "run validation steps on the given named group"
  def validate(package, group=package)
    run_command(package, group, :validate)
  end

  desc "init", "initialize the current directory with a orca/orca.rb"
  def init
    directory('template', 'orca')
  end

  desc "trigger ACTION_REF GROUP_OR_NODE_NAME", "trigger an action directly e.g. `orca trigger nginx:reload web-1`"
  def trigger(action_ref, group)
    run_command(action_ref, group, :trigger)
  end

  private

  def run_command(package, group, cmd)
    Orca.verbose(options[:verbose] || false)
    err = nil
    begin
      suite = Orca::Suite.new(options)
      suite.load_file(orca_file)
      suite.run(group, package, cmd)
    rescue => e
      err = e
    ensure
      $stdout.print "Disconnecting...".green
      suite.cleanup
      $stdout.puts "Done!".green
      exit(0) if err.nil?
      if options[:throw]
        raise err
      else
        $stderr.puts "!!! ERROR !!! [#{e.class.name}] #{e.message}".red.bold
        exit(1)
      end
    end
  end

  def orca_file
    ENV['ORCA_FILE'] ||= (options[:file] || File.join(Dir.pwd, 'orca', 'orca.rb'))
  end
end
