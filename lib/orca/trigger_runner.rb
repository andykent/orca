class Orca::TriggerRunner
  def initialize(node, action_ref)
    @node = node
    @action_ref = action_ref
    @log = Orca::Logger.new(@node, @action_ref)
  end

  def execute(_)
    Orca::ExecutionContext.new(@node, @log).trigger(@action_ref)
  end

  def demonstrate(_)
    Orca::MockExecutionContext.new(@node, @log).trigger(@action_ref)
  end
end