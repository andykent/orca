class Hull::Package
  attr_reader :name, :dependancies, :actions

  def initialize(name)
    @name = name
    @dependancies = []
    @actions = {}
    @commands = {}
    @remove = nil
  end

  def depends_on(*pkg_names)
    pkg_names.each do |pkg_name|
      @dependancies << pkg_name
    end
  end

  def validate(&definition)
    @commands[:validate] = definition
  end

  def apply(&definition)
    @commands[:apply] = definition
  end

  def remove(&definition)
    @commands[:remove] = definition
  end

  def action(name, &definition)
    @actions[name] = definition
  end

  def command(name)
    @commands[name.to_sym]
  end

  def provides_command?(name)
    !command(name).nil?
  end
end