class Hull::Runner
  def initialize(node, package)
    @node = node
    @package = package
    @perform = true
  end

  def packages
    resolver = Hull::Resolver.new(@package)
    resolver.resolve
    resolver.packages
  end

  def apply(command_name)
    packages.each do |pkg|
      next unless pkg.provides_command?(command_name)
      @node.log pkg.name, command_name.to_s.yellow
      context = @perform ? Hull::ExecutionContext.new(@node) : Hull::MockExecutionContext.new(@node)
      cmd = pkg.command(command_name)
      context.apply(cmd)
    end
  end

  def demonstrate(command_name)
    @perform = false
    apply(command_name)
    @perform = true
  end
end


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

  def trigger(action, *args)
    pkg_name, action_name = *action.split(':', 2)
    pkg = Hull::PackageIndex.default.get(pkg_name)
    action = pkg.actions[action_name]
    instance_exec(*args, &action)
  end
end

class Hull::MockExecutionContext < Hull::ExecutionContext
  def run(cmd)
    @node.log 'mock-execute', cmd
  end
end


class Hull::Resolver
  attr_reader :packages
  def initialize(package)
    @package = package
    @packages = [@package]
  end

  def resolve
    dependancies = @package.dependancies.map { |d| Hull::PackageIndex.default.get(d) }
    @packages += dependancies.map {|d| Hull::Resolver.new(d).resolve.packages }
    @packages.flatten!
    @packages.reverse!
    @packages.uniq!
    self
  end
end