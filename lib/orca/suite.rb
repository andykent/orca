class Orca::Suite

  def initialize(options={})
    @sequential = options[:sequential]
    @demonstrate = options[:demonstrate]
    @skip_dependancies = options[:'skip-dependancies'] || false
    @nodes = []
  end

  def load_file(file)
    Orca::DSL.module_eval(File.read(file))
  end

  def run(group_name, pkg_name, command, sequential=false)
    group = Orca::Group.find(group_name)
    raise Orca::MissingGroupError.new(group_name) if group.nil?
    runners = group.nodes.map do |node|
      @nodes << node
      if command == :trigger
        Orca::TriggerRunner.new(node, pkg_name)
      else
        pkg = Orca::PackageIndex.default.get(pkg_name)
        Orca::Runner.new(node, pkg, @skip_dependancies)
      end
    end
    if @sequential
      runners.each {|runner| exec(runner, command) }
    else
      threads = runners.map {|runner| Thread.new { exec(runner, command) } }
      threads.each {|t| t.join }
    end
  end

  def cleanup
    @nodes.each(&:disconnect)
  end

  private

  def exec(runner, command)
    if @demonstrate
      runner.demonstrate(command)
    else
      runner.execute(command)
    end
  end
end

class Orca::MissingGroupError < StandardError
  def initialize(group_name)
    @group_name = group_name
  end

  def message
    "No Group or Node exists with the name '#{@group_name}'. Try one of: #{Orca::Group.names.join(', ')}"
  end
end