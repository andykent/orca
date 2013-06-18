class Orca::Package
  attr_reader :name, :dependancies, :actions, :children

  def initialize(name)
    @name = name
    @dependancies = []
    @children = []
    @actions = {}
    @commands = {}
    @remove = nil
  end

  def depends_on(*pkg_names)
    pkg_names.each do |pkg_name|
      @dependancies << pkg_name
    end
  end

  def triggers(*pkg_names)
    pkg_names.each do |pkg_name|
      @children << pkg_name
    end
  end

  def validate(&definition)
    command(:validate, &definition)
  end

  def apply(&definition)
    command(:apply, &definition)
  end

  def remove(&definition)
    command(:remove, &definition)
  end

  def action(name, &definition)
    @actions[name] = definition
  end

  def command(name, &definition)
    if block_given?
      (@commands[name.to_sym] ||= []) << definition
    else
      @commands[name.to_sym]
    end
  end

  def provides_command?(name)
    @commands.has_key?(name.to_sym)
  end
end