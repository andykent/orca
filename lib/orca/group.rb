class Orca::Group
  class << self
    def register(group)
      @groups ||= {}
      @groups[group.name] = group
    end

    def from_node(node)
      new(node.name, {}, [node])
    end

    def find(name)
      return name if name.is_a?(Orca::Group)
      return nil unless @groups
      @groups[name]
    end

    def names
      @groups.keys.sort
    end
  end

  attr_reader :name, :nodes, :config

  def initialize(name, config={}, nodes=[])
    @name = name
    @config = config
    @nodes = nodes
    Orca::Group.register(self)
  end

  def node(name, host, options={})
    add_node( Orca::Node.new(name, host, @config.merge(options)) )
  end

  def add_node(node)
    @nodes << node
  end

  def includes(group)
    Orca::Group.find(group).nodes.each {|n| add_node(n) }
  end

  def set(property, value)
    @config[property.to_sym] = value
  end
end