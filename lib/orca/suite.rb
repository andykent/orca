class Orca::Suite

  def initialize(options={})
    @sequential = options[:sequential]
    @demonstrate = options[:demonstrate]
  end

  def load_file(file)
    Orca::DSL.module_eval(File.read(file))
  end

  def run(group_name, pkg_name, command, sequential=false)
    group = Orca::Group.find(group_name)
    pkg = Orca::PackageIndex.default.get(pkg_name)
    runners = group.nodes.map { |node| Orca::Runner.new(node, pkg) }
    if @sequential
      runners.each {|runner| exec(runner, command) }
    else
      threads = runners.map {|runner| Thread.new { exec(runner, command) } }
      threads.each {|t| t.join }
    end
  end

  def exec(runner, command)
    if @demonstrate
      runner.demonstrate(command)
    else
      runner.execute(command)
    end
  end
end