class Orca::TriggerRunner
  def initialize(node, action_ref_with_args)
    @node = node
    @action_ref, args = *parse_action_ref(action_ref_with_args)
    @log = Orca::Logger.new(@node, @action_ref)
  end

  def execute(_)
    Orca::ExecutionContext.new(@node, @log).trigger(@action_ref, *args)
  end

  def demonstrate(_)
    Orca::MockExecutionContext.new(@node, @log).trigger(@action_ref, *args)
  end

  private

  def parse_action_ref(action_ref_with_args)
    matches = action_ref_with_args.match(/([\w\:]+?)(\[([\w\,]+?)\])/)
    return [action_ref_with_args,[]] unless matches
    action_ref = matches[1]
    args = matches[3].split(',').map(&:strip)
    throw [action_ref, args]
  end
end