class Orca::Runner
  def initialize(node, package, skip_dependancies=false)
    @node = node
    @package = package
    @perform = true
    @skip_dependancies = skip_dependancies
    @log = Orca::Logger.new(@node, package)
  end

  def packages
    return [@package] if @skip_dependancies
    resolver = Orca::Resolver.new(@package)
    resolver.resolve
    resolver.packages
  end

  def execute(command_name)
    pkgs = packages
    pkgs.reverse! if command_name.to_sym == :remove
    @log.say pkgs.map(&:name).join(', ').yellow
    pkgs.each do |pkg|
      send(:"execute_#{command_name}", pkg)
    end
  end

  def execute_apply(pkg)
    return unless should_run?(pkg, :apply)
    exec(pkg, :apply)
    validate!(pkg)
  end

  def execute_remove(pkg)
    return unless should_run?(pkg, :remove)
    exec(pkg, :remove)
  end

  def execute_validate(pkg)
    validate!(pkg)
  end

  def should_run?(pkg, command_name)
    return false unless pkg.provides_command?(command_name)
    return true unless @perform
    return true unless command_name == :apply || command_name == :remove
    return true unless pkg.provides_command?(:validate)
    is_present = is_valid?(pkg)
    return !is_present if command_name == :apply
    return is_present
  end

  def validate!(pkg)
    return true unless @perform
    return unless pkg.provides_command?(:validate)
    return if is_valid?(pkg)
    raise ValidationFailureError.new(@node, pkg)
  end

  def is_valid?(pkg)
    results = exec(pkg, :validate)
    results.all?
  end

  def demonstrate(command_name)
    @perform = false
    execute(command_name)
    @perform = true
  end

  def exec(pkg, command_name)
    context = @perform ? Orca::ExecutionContext.new(@node, @log) : Orca::MockExecutionContext.new(@node, @log)
    cmds = pkg.command(command_name)
    context = context.for_user(pkg.user) if pkg.user
    context.log.set_package(pkg)
    context.log.command(command_name)
    cmds.map {|cmd| context.apply(cmd) }
  end

  class ValidationFailureError < StandardError
    def initialize(node, package)
      @node = node
      @package = package
    end

    def message
      "Package #{@package.name} failed validation on #{@node.to_s}"
    end
  end
end