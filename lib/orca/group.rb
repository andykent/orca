class Orca::Group
  class << self
    def register(group)
      @groups ||= {}
      @groups[group.name] = group
    end

    def from_node(node)
      new(node.name, [node])
    end

    def find(name)
      return name if name.is_a?(Orca::Group)
      return nil unless @groups
      @groups[name]
    end
  end

  attr_reader :name, :nodes

  def initialize(name, nodes=[])
    @name = name
    @nodes = nodes
    Orca::Group.register(self)
  end

  def node(name, host, options={})
    add_node( Orca::Node.new(name, host, options) )
  end

  def add_node(node)
    @nodes << node
  end

  def includes(group)
    Orca::Group.find(group).nodes.each {|n| add_node(n) }
  end
end