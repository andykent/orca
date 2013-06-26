class Orca::TriggerRunner
  def initialize(node, action_ref)
    @node = node
    @action_ref = action_ref
  end

  def execute(_)
    Orca::ExecutionContext.new(@node).trigger(@action_ref)
  end

  def demonstrate(_)
    Orca::MockExecutionContext.new(@node).trigger(@action_ref)
  end
end