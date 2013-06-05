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

  def execute(command_name)
    @node.log command_name, packages.map(&:name).join(', ').yellow
    packages.each do |pkg|
      next unless should_run?(pkg, command_name)
      exec(pkg, command_name)
      validate!(pkg) if command_name == :apply
    end
  end

  def should_run?(pkg, command_name)
    return false unless pkg.provides_command?(command_name)
    return true unless @perform
    return true unless command_name == :apply || command_name == :remove
    return true unless pkg.provides_command?(:validate)
    is_present = exec(pkg, :validate)
    return !is_present if command_name == :apply
    return is_present
  end

  def validate!(pkg)
    return true unless @perform
    return unless pkg.provides_command?(:validate)
    return if exec(pkg, :validate)
    raise "Package #{pkg.name} failed validation"
  end

  def demonstrate(command_name)
    @perform = false
    execute(command_name)
    @perform = true
  end

  def exec(pkg, command_name)
    @node.log pkg.name, command_name.to_s.yellow
    context = @perform ? Hull::ExecutionContext.new(@node) : Hull::MockExecutionContext.new(@node)
    cmd = pkg.command(command_name)
    context.apply(cmd)
  end
end